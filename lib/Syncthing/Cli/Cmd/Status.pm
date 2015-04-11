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
	my ($directory) = @$args; 
	croak "Missing directory_id" if !defined $directory;
	my $config = $self->get('db/status?folder=' . $directory);
	croak "nothing found for $directory" if !$config->{version};
	say $directory,': ';
	say "    state: ", $config->{state};
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
