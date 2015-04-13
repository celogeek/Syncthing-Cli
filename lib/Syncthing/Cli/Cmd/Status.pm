package Syncthing::Cli::Cmd::Status;

use Moo;
with 'Syncthing::Cli::Role';
use MooX::Cmd;
use feature 'say';
use Carp;
use Number::Bytes::Human qw(format_bytes);
use Getopt::Long qw(:config pass_through);

sub execute {
	my ($self, $args) = @_;

	my $skip_idle;
	{
		local @ARGV = @$args;
		GetOptions('active|a' => \$skip_idle);
		@$args = @ARGV;
	}

	# missing specific directory, list all
	if(!@$args) {
		my $config = $self->get('system/config');
		@$args = map { $_->{id} } @{$config->{folders}};
	}

	my @responses = $self->get(map {'db/status?folder=' . $_} @$args);
	
	for my $config(@responses) {
		my $directory = shift @$args;
		$self->display($directory, $config, $skip_idle);
	}
}

sub display {
	my ($self, $directory, $config, $skip_idle) = @_;
	$config->{state} ||= 'unknown';

	return if $skip_idle && $config->{state} eq 'idle';

	say $directory,': ';
	say "    state: ", $config->{state};

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
	say "";
}

1;
