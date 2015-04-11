package Syncthing::Cli::Cmd::Status;

use Moo;
with 'Syncthing::Cli::Role';
use MooX::Cmd;
use feature 'say';
use Carp;
use DDP;
use Number::Bytes::Human qw(format_bytes);

sub execute {
	my ($self, $args) = @_;

	# missing specific directory, list all
	if(!@$args) {
		my $config = $self->get('system/config');
		@$args = map { $_->{id} } @{$config->{folders}};
	}

	my @responses = $self->get(map {'db/status?folder=' . $_} @$args);
	
	for my $config(@responses) {
		my $directory = shift @$args;
		$self->display($directory, $config);
		say "";
	}
}

sub display {
	my ($self, $directory, $config) = @_;
	say $directory,': ';
	say "    state: ", $config->{state} || 'unknown';

	return if !$config->{version};

	my $progress = '???';
	if ($config->{globalBytes}) {
		$progress = $config->{inSyncBytes} * 100.000 / $config->{globalBytes};
	}
	say "    progress: ", sprintf("%.2f", $progress),"%";
	if ($config->{state} eq 'syncing') {
		say "    fetching: ", $config->{needFiles}, " file(s), ", format_bytes($config->{needBytes}); 
	}
	say "    local: ", $config->{localFiles}, " file(s), ", format_bytes($config->{localBytes}); 
	say "    global: ", $config->{globalFiles}, " file(s), ", format_bytes($config->{globalBytes}); 
}

1;
