package Syncthing::Cli::Cmd::Download;

use Moo;
with 'Syncthing::Cli::Role';
use MooX::Cmd;
use feature 'say';
use Number::Bytes::Human qw(format_bytes);
use JSON;
use Term::Screen;
use DDP;

sub execute {
	my ($self) = @_;

	my $scr = Term::Screen->new or die "cant setup screen";
	$scr->clrscr();
	$scr->noecho();
	$scr->at(0,0)->puts("Download progress of " . $self->remote);
	$scr->at(1,0)->puts("Press q to exit");
	$scr->at(2,0);

	my $since = 0;
	while(1) {
		last if ($scr->key_pressed && $scr->getch eq 'q');
		my @events = @{$self->get('events?since='.$since)//[]};
		next if !@events;
		$since = $events[-1]->{id};

		my @de = grep {$_->{type} eq 'DownloadProgress'} @events;
		next if !@de;

		my $pos = 3;
		my $download = $de[-1]->{data};
		for my $id(sort keys %$download) {
			my $files = $download->{$id};
			for my $file(sort keys %$files) {
				my $done = $files->{$file}{bytesDone};
				my $total = $files->{$file}{bytesTotal};
				my $cols = $scr->cols - 2;
				my $progress = sprintf("[%-".$cols."s]", "#" x ($total ? int($done / $total * $cols) : $cols));

				$scr
				->at($pos++,0)->puts(sprintf("%-20s: %s (%s of %s), %.2f %%", $id, $file,format_bytes($done), format_bytes($total), $total ? $done * 100.000 / $total : 100))->clreol()
				->at($pos++,0)->puts($progress);
				$pos++;
			}
		}
		while($pos < $scr->cols) {
			$scr->at($pos++, 0)->clreol;
		}
		$scr->at(2,0);
	} continue {
		sleep(5);
	}
	$scr->flush_input;
	$scr->clrscr();
}

1;
