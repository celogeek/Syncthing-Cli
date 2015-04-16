package Syncthing::Cli::Cmd::List;

use strict;
use warnings;
# VERSION

use Moo;
with 'Syncthing::Cli::Role';
use MooX::Cmd;
use feature 'say';
use Getopt::Long qw(:config pass_through);

sub execute {
	my ($self, $args) = @_;
	my ($listFolder, $listPath, $filterReadOnly);
	{
		local @ARGV = @$args;
		GetOptions('folder|f' => \$listFolder, 'path|p', \$listPath, 'readonly|r' => \$filterReadOnly);
		@$args = @ARGV;
	}
	my $config = $self->get('system/config');
	my %devices = map { $_->{deviceID} => $_->{name} } @{$config->{devices}};
	for my $folder(sort { $a->{id} cmp $b->{id} } @{$config->{folders}}) {
		next if $filterReadOnly && !$folder->{readOnly};
		if ($listFolder) {
			say $folder->{id};
		} elsif($listPath) {
			say $folder->{path};
		} else {
			say $folder->{id}, ':';
			say "    path: ", $folder->{path};
			say "    readOnly: ", $folder->{readOnly} ? 'true' : 'false';
			say "    devices:";
			for my $device(sort map { $devices{$_->{deviceID}} // $_->{deviceID} } @{$folder->{devices}}) {
				say "        * ", $device;
			}
			say "";
		}
	}
}

1;
