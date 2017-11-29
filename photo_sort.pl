use strict;
use warnings;

use Path::Tiny;
use Image::ExifTool;
use Getopt::Kingpin;
use Data::Dumper;
use Time::Piece;
use Image::EXIF::DateTime::Parser;

my $kingpin = Getopt::Kingpin->new();
my $src = $kingpin->arg('src', 'source dir of photo')->required->existing_dir();
my $dst = $kingpin->arg('dst', 'destination dir of sorted photo')->required->existing_dir();
my $dry_run = $kingpin->flag('dry', 'dry run - only print from to')->bool();
$kingpin->parse();

my $exifTool = Image::ExifTool->new();

my %stats;
$src->value->visit(
    sub {
        my ($path) = @_;

        return if $path->is_dir();

        if ($exifTool->ExtractInfo($path->canonpath())) {
            my $info = $exifTool->GetInfo('CreateDate', 'Orientation', 'MediaDuration');

            my $type = 'photo';
            if (exists $info->{MediaDuration}) {
                $type = 'video';
            }

            my $mtime;
            if (exists $info->{CreateDate}) {
                my $parser = Image::EXIF::DateTime::Parser->new();
                $mtime = Time::Piece->new($parser->parse($info->{CreateDate}));
            }
            else {
                $mtime = Time::Piece->new($path->stat->mtime);
            }

            my $orientation = "";
            if (exists $info->{Orientation} && $info->{Orientation} =~ /^(\w)/) {
                $orientation = lc "-$1";
            }

            my $filename = sprintf "%02d-%02d%s-%s", $mtime->mday, $mtime->hour, $orientation, $path->basename();

            $stats{found}{size} += -s $path;
            $stats{found}{count}++;

            my $dst_path = path($dst, $type, $mtime->year, sprintf("%02d", $mtime->mon), $filename);
            print "$path -> $dst_path\n";
            if (!$dry_run) {
                $dst_path->parent->mkpath();
                $path->copy($dst_path);
                $stats{copied}{size} += -s $dst_path;
                $stats{copied}{count}++;
            }
        }
    },
    {recurse => 1}
);

print Dumper \%stats;

if (!$dry_run ) {
    if ($stats{found}{count} == $stats{copied}{count} && $stats{found}{size} == $stats{copied}{size}) {
        print "Copy done\n";
        exit 0;
    }
    else {
        print "Copy problem\n";
        exit 1;
    }
}
