package Syncthing::Cli::Role;

use Config::Fast;
use Path::Class;
use HTTP::Async;
use HTTP::Request;
use HTTP::Headers;
use JSON::MaybeXS;
use Getopt::Long qw(:config pass_through);
use Moo::Role;

my $host = '127.0.0.1';
my $port = 8888;
my $ssl = 0;

before _initialize_from_cmd => sub {
	GetOptions('host|h=s' => \$host, 'port|p=i' => \$port, 'ssl|s' => \$ssl);
};

has 'remote' => (is => 'ro', lazy => 1, default => sub {
		my $self = shift;
	    return 'http' . ($ssl ? 's' : '') . '://' . $host . ':' . $port . '/rest/';
});

has 'api' => (is => 'ro', lazy => 1, default => sub {
		my $self = shift;
		return HTTP::Async->new;
});

sub get {
	shift->async('GET', {}, @_);
}

sub post {
	my $self = shift;
	my $config = $self->get('system/config');
	my $apiKey = $config->{gui}{apiKey};
	return $self->async('POST', { 'X-API-Key' => $apiKey }, @_);
}

sub async {
	my $self = shift;
	my $method = shift;
	my $header = shift // {};
	my @request;
	
	while(my $path = shift) {
		my $id = $self->api->add(
			HTTP::Request->new(
				$method => $self->remote . $path,
				HTTP::Headers->new(%$header)
			)
		);
		push @request, $id;
	}
	my %responses;
	while(my ($response, $id) = $self->api->wait_for_next_response) {
		my $json;
		if ($response->is_success && eval{$json = decode_json($response->decoded_content); 1}) {
			$responses{$id} = $json; 
		} else {
			$responses{$id} = {};
		}
	}
	my @ordered_response = map { $responses{$_} } @request; 
	return wantarray ? @ordered_response : $ordered_response[-1];
}

1;
