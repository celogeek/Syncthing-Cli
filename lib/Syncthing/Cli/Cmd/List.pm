package Syncthing::Cli::Cmd::List;

use Moo;
with 'Syncthing::Cli::Role';
use MooX::Cmd;
use feature 'say';
use Carp;

sub execute {
	my ($self) = @_;
	my $config = $self->get('system/config');
	croak "cant connect to remote" if !scalar keys %$config;
	my %devices = map { $_->{deviceID} => $_->{name} } @{$config->{devices}};
	for my $folder(sort { $a->{id} cmp $b->{id} } @{$config->{folders}}) {
		say $folder->{id}, ':';
		say "    path: ", $folder->{path};
		say "    devices:";
		for my $device(sort map { $devices{$_->{deviceID}} // $_->{deviceID} } @{$folder->{devices}}) {
			say "        * ", $device;
		}
		say "";
	}
}

1;
