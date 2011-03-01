use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::More;
use Path::Extended;
use Parse::CPAN::Meta;

require PPM::Make;
my $main_ver = $PPM::Make::VERSION;

my $yaml;
my $meta_yml = file("$FindBin::Bin/../META.yml");
if ($meta_yml->exists) {
  ($yaml) = Parse::CPAN::Meta::LoadFile("$meta_yml");
  is $yaml->{version} => $main_ver, "META.yml has correct version";

  my %provides = %{ $yaml->{provides} };
  for my $package (keys %provides) {
    eval "use $package";
    die $@ if $@;
    my $pkg_ver = $package->VERSION;
    is $pkg_ver => $main_ver, "$package has correct VERSION";
    is $provides{$package}{version} => $main_ver, "$package has correct VERSION in META.yml";
  }
}

my $manifest = file("$FindBin::Bin/../MANIFEST");
$manifest->slurp(callback => sub {
  my $line = shift;
  if ($line =~ m{^lib/(.+)\.pm$}) {
    my $package = $1;
    $package =~ s{/}{::}g;
    ok $yaml->{provides}{$package}, "$package is listed in MANIFEST";
  }
});

done_testing;
