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
	say <DATA>;
}

1;
__DATA__
syncthing-cli command options

  * list: list all directory id and path
  * version: get current client version
  * checkupdate: check if a new version is available

Remote url need to be set in ~/.syncthingrc

remote: http://localhost:8888
