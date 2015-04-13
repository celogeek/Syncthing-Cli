package Syncthing::Cli::Cmd::Download;

use Moo;
with 'Syncthing::Cli::Role';
use MooX::Cmd;
use feature 'say';
use Number::Bytes::Human qw(format_bytes);
use JSON;
use Term::Screen;
use Term::ANSIColor qw(:constants);
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
		my @events =  @{$self->get('events?since='.$since)//[]};
		next if !@events;
		$since = $events[-1]->{id};
		$scr->at(2,0)->puts("last event: $since");

		my @downloadsData = map { $_->{data } } grep { $_->{type} eq 'DownloadProgress' } @events;
		next if !@downloadsData;
		my %downloads;
		for my $download(@downloadsData) {
			for my $id(keys %$download) {
				my $files = $download->{$id};
				for my $file(keys %$files) {
					my $done = $files->{$file}{bytesDone};
					my $total = $files->{$file}{bytesTotal};
					$downloads{$id}{$file} = [$done, $total];
				}
			}
		}

		my $pos = 4;
		for my $id(sort keys %downloads) {
			$scr->at($pos++,0)->puts("[" . $id . "]")->clreol();
			my $files = $downloads{$id};
			for my $file(sort keys %$files) {
				$self->display($scr, $pos, $file, $files->{$file});
				$pos++;
			}
			$scr->at($pos++,0)->clreol();
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

sub display {
	my ($self, $scr, $pos, $file, $data) = @_;
	my ($done, $total) = @$data;

	my $cols = $scr->cols;
	my $hcols = int($cols / 2);
	
	my $progress_str = sprintf("(%s of %s)", format_bytes($done), format_bytes($total));
	my $max_file_len = $hcols - 3 - length($progress_str);
	my $file_str = substr($file, -$max_file_len);
	substr($file_str, 0, 3) = '...' if $file_str ne $file;

	$scr->at($pos,0)->puts(sprintf("%-" . $max_file_len . "s %s", $file_str, $progress_str));
	
	my $max_progress_bar_size = $cols - $hcols - 2;
	my $progress_bar_size = $max_progress_bar_size;
	$total and
	$progress_bar_size = int($done / $total * $max_progress_bar_size);
	
	$scr
	->at($pos,$hcols)->puts("[")
	->at($pos,$hcols+1)->puts(sprintf(ON_WHITE . '%' . $progress_bar_size . 's' . RESET, ''))
	->at($pos,$cols)->puts("]")
	;
	

}

1;
