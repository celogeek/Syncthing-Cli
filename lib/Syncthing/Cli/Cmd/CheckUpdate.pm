package Syncthing::Cli::Cmd::CheckUpdate;

use strict;
use warnings;
# VERSION

use Moo;
with 'Syncthing::Cli::Role';
use MooX::Cmd;
use feature 'say';
use Carp;

sub execute {
	my ($self) = @_;
	my $config = $self->get('system/upgrade');
	say "Running: ", $config->{running};
	if ($config->{newer}) {
		say "New version available: ", $config->{latest};
	} else {
		say "No new version available";
	}
}

1;
