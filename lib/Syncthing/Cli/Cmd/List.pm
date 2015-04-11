package Syncthing::Cli::Cmd::List;

use Moo;
with 'Syncthing::Cli::Role';
use MooX::Cmd;
use feature 'say';
use Carp;
use DDP;

sub execute {
	my ($self) = @_;
	my $config = $self->get('system/config');
	croak "cant connect to remote" if !scalar keys %$config;
	for my $folder(sort { $a->{id} cmp $b->{id} } @{$config->{folders}}) {
		say $folder->{id}, ': ', $folder->{path};
	}
}

1;
