package Syncthing::Cli::Cmd::Version;

use strict;
use warnings;
# VERSION

use Moo;
with 'Syncthing::Cli::Role';
use MooX::Cmd;
use feature 'say';

sub execute {
	my ($self) = @_;
	say $self->get('system/version')->{version} // "???";
}

1;
