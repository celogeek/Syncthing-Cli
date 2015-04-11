package Syncthing::Cli;

# ABSTRACT: Syncthing client

use strict;
use warnings;
# VERSION

use DDP;
use Moo;
use MooX::Options;
use Config::Fast;
use Path::Class;
use feature 'say';
use JSON::MaybeXS;

my $config_file = file($ENV{HOME}, '.syncthingclirc')->stringify;
my %config;
eval { %config = fastconfig($config_file); 1 };

option remote => (is => 'ro', short => 'r', format => 's', doc => 'remote url (default: ' . ($config{remote}//'') . ')');
option cmd => (is => 'ro', short => 'c', format => 's', doc => 'command look_like : get_system_config or set_system_config [file]');

sub BUILDARGS {
	my $self = shift;
	my $args = @_ == 1 ? $_[0] : {@_};

	$args->{remote} //= $config{remote};
	$args->{cmd} //= 'get_system_version';

	return $args;
}

sub run {
	my ($self) = @_;
	say "Remote: ", $self->remote;
	say "Command: ", $self->cmd;

}

1;
