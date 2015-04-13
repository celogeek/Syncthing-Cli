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
syncthing-cli [-h host] [-p port] [-s] command options

  * -h: set the host, default 127.0.0.1
  * -p: set the port, default 8888
  * -s: ssl protocol

  * list: list all directory id and path
  	-p: list path only
	-i: list id only
  * status: get status
        * [ directory ] [ directory ] ...
        * -a: only active one
  * version: get current client version
  * checkupdate: check if a new version is available
