package Syncthing::Cli::Cmd::Override;

use Moo;
with 'Syncthing::Cli::Role';
use MooX::Cmd;
use feature 'say';

sub execute {
	my ($self) = @_;
	my $config = $self->get('system/config');
	my @folders = sort map { $_->{id} } grep { $_->{readOnly} } @{$config->{folders}};
	say "Overring $_ ..." for @folders;
	$self->post(map { 'db/override?folder=' . $_ } @folders);
}

1;
