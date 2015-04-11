package Syncthing::Cli::Role;

use Config::Fast;
use Path::Class;
use REST::Client;
use Carp;
use JSON::MaybeXS;
use DDP;
use Getopt::Long;
use Moo::Role;

my $host = '127.0.0.1';
my $port = 8888;
my $ssl = 0;

before _initialize_from_cmd => sub {
	GetOptions('host|h=s' => \$host, 'port|p=i' => \$port, 'ssl|s' => \$ssl);
};

has 'remote' => (is => 'ro', lazy => 1, default => sub {
		my $self = shift;
	    return 'http' . ($ssl ? 's' : '') . '://' . $host . ':' . $port;
});

has 'api' => (is => 'lazy', default => sub {
		my $self = shift;
		my $client = REST::Client->new(host => $self->remote . '/rest');
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
