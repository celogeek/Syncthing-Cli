package Syncthing::Cli::Cmd::Live;

use Moo;
with 'Syncthing::Cli::Role';
use MooX::Cmd;
use feature 'say';
use Number::Bytes::Human qw(format_bytes);
use JSON;
use Term::ANSIColor qw(:constants);

has 'devices' => (is => 'lazy');
sub _build_devices {
	my ($self) = @_;
	my $config = $self->get('system/config');
	my %devices = map { $_->{deviceID} => $_->{name} } @{$config->{devices}//[]};
	return \%devices;
}

sub execute {
	my ($self) = @_;

	my $since = 0;
	while(1) {
		my $events = $self->get('events?since='.$since);
		if (ref $events ne 'ARRAY') {
			$since = 0;
			next;
		}
		for my $event(@$events) {
			$since = $event->{id};
			$self->display($event);
		}
	}
}

sub display {
	my ($self, $event) = @_;
	my $meth =  $self->can("display" . $event->{type} // "unknown")
		or return $self->displayUnknown($event->{type}, $event->{data});
	$meth->($self, $event->{data});
}

sub displayDownloadProgress {
	my ($self, $download) = @_;
	for my $id(sort keys %$download) {
		my $files = $download->{$id};
		for my $file(sort keys %$files) {
			my $done = $files->{$file}{bytesDone};
			my $total = $files->{$file}{bytesTotal};
			say BOLD WHITE, sprintf("[%-20s] %-15s: %s (%s on %s) (%.2f %%)", "DownloadProgress", $id, $file, format_bytes($done), format_bytes($total), ($total ? $done * 100.000 / $total : 100)), RESET;
		}
	}
}

sub displayStateChanged {
	my ($self, $state) = @_;
	say BLUE, sprintf("[%-20s] %-15s: %s -> %s ( %.2f s)", "StateChanged", $state->{folder}, $state->{from}, $state->{to}, $state->{duration}), RESET;
}

sub displayFolderSummary {
	my ($self, $data) = @_;
	my $summary = $data->{summary};

	say BOLD YELLOW, sprintf("[%-20s] %-15s: %d files left, %s (%.2f %% completed)", "FolderSummary", $data->{folder}, $summary->{needFiles}, format_bytes($summary->{needBytes}), $summary->{globalBytes} ? $summary->{inSyncBytes} * 100.000 / $summary->{globalBytes} : 100), RESET;
}

sub displayRemoteIndexUpdated {
	my ($self, $update) = @_;

	say BLUE, sprintf("[%-20s] %-15s: %s -> %s item(s)", "RemoteIndexUpdated", $update->{folder}, $self->devices->{$update->{device}} // $update->{device}, $update->{items}), RESET;
}

sub displayLocalIndexUpdated {
	my ($self, $update) = @_;
	say BLUE, sprintf("[%-20s] %-15s: %d item(s)", "LocalIndexUpdated", $update->{folder}, $update->{numFiles} // 1), RESET;
}

sub displayFolderCompletion {
	my ($self, $completed) = @_;

	say BOLD GREEN, sprintf("[%-20s] %-15s: %s (%.2f %%)", "FolderCompletion", $completed->{folder}, $self->devices->{$completed->{device}} // $completed->{device}, $completed->{completion}), RESET;
}

sub displayItemStarted {}
sub displayItemFinished {}
sub displayPing {}

sub displayUnknown {
	my ($self, $type, $data) = @_;
	$data = {} if !ref $data;
	say RED, sprintf("[%-20s] %s", $type, encode_json($data)), RESET;
}
1;
