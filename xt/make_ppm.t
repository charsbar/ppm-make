use strict;
use warnings;
use FindBin;
use Test::More;
use WorePAN;
use File::pushd;
use CPAN::DistnameInfo;
use Path::Tiny;

my @test_files = (
  'MAUKE/Switch-Plain-0.03.tar.gz',
  'ANDK/File-Rsync-Mirror-Recent-0.4.3.tar.bz2',
  'INGY/boolean-0.46.tar.gz',
);

my $tmpdir = "$FindBin::Bin/tmp";

for my $file (@test_files) {
  my $dist = CPAN::DistnameInfo->new($file)->dist;
  my $worepan = WorePAN->new(
    root => "$tmpdir/mirror",
    files => [$file],
    no_network => 0,
    no_indices => 1,
    cleanup => 1,
    use_backpan => 1,
  );

  $worepan->walk(callback => sub {
    my $dir = shift;
    my $guard = pushd $dir;
    ok !system("cpanm -L$tmpdir/local --installdeps ."), "installed dependencies for $dist";
    ok !system("$^X -I$tmpdir/local -I$FindBin::Bin/../lib $FindBin::Bin/../bin/make_ppm"), "made ppm files for $dist";
    my $ppd_file = path("$dir/$dist.ppd");
    my $tarball = path("$dir/$dist.tar.gz");
    ok -f $ppd_file, "$dist.ppd exists";
    ok -f $tarball, "$dist.tar.gz exists";
    my $ppd = $ppd_file->slurp_utf8;
    unlike $ppd => qr/\P{ascii}/, "contains no non-ascii chars";
  });

  $worepan->root->rmtree;
}

done_testing;
