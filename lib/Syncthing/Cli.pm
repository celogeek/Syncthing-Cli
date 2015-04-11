package Syncthing::Cli;

# ABSTRACT: Syncthing client

use strict;
use warnings;
# VERSION

use Moo;
with 'Syncthing::Cli::Role';
use MooX::Cmd;
use feature 'say';

sub execute {
	my ($self) = @_;
	say "Remote: ", $self->config->{remote};
}

1;
