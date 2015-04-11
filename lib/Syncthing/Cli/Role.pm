package Syncthing::Cli::Role;

use Config::Fast;
use Path::Class;
use REST::Client;
use Carp;
use JSON::MaybeXS;
use Moo::Role;

has 'config' => (is => 'lazy', default => sub{
	my $config_file = file($ENV{HOME}, '.syncthingclirc')->stringify;
	my %config;
	eval { %config = fastconfig($config_file); 1 };
	return \%config;
});

has 'api' => (is => 'lazy', default => sub {
		my $self = shift;
		my $remote = $self->config->{remote} or croak "Please set 'remote' in '.syncthingclirc'";
		my $client = REST::Client->new(host => $remote . '/rest');
		return $client;
});

sub get {
	my $self = shift;
	my $path = shift;
	my $content;
	eval { $content = decode_json($self->api->GET($path)->responseContent());1 }
		or $content = {};
	return $content;
}
1;
