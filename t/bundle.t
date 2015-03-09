use Test::More;
use strict;
use FindBin;
require File::Spec;
use File::Path;
use PPM::Make::Bundle;
use Config;
ok(1); # If we made it this far, we're ok.

#########################

# Insert your test code below, the Test module is use()ed here so read
# its man page ( perldoc Test ) for help writing this test script.

my @ppds = qw(AppConfig.ppd File-HomeDir.ppd
	     Win32-TieRegistry.ppd Win32API-Registry.ppd);
my @tgz_base = qw(AppConfig-1.63 File-HomeDir-0.58
		 Win32-TieRegistry-0.25 Win32API-Registry-0.27);
my %exts = ('MSWin32-x86-multi-thread-5.8' => 'PPM58',
	    'MSWin32-x86-multi-thread' => 'PPM56');

my $rep = File::Spec->catdir($FindBin::Bin, 'ppms');
ok(-d $rep);
foreach my $arch (keys %exts) {
  my $bundle = PPM::Make::Bundle->new(no_cfg => 1, 
				      reps => [($rep)],
				      dist => 'AppConfig',
				      arch => $arch);
  ok($bundle);
  is(ref($bundle), 'PPM::Make::Bundle');
  $bundle->make_bundle();
  my $build_dir = $bundle->{build_dir};
  ok(-d $build_dir);
  for my $ppd (@ppds) {
    my $remote = File::Spec->catfile($build_dir, "$ppd.orig");
    my $local = File::Spec->catfile($cwd, 't', 'ppms', $ppd);
    ok(-f $remote);
    is(-s $remote, -s $local);
  }
  for my $tgz (@tgz_base) {
    my $ar = $tgz . '-' . $exts{$arch} . '.tar.gz';
    my $remote = File::Spec->catfile($build_dir, $ar);
    my $local = File::Spec->catfile($cwd, 't', 'ppms', $ar);
    ok(-f $remote);
    is(-s $remote, -s $local);
  }
  my $zipdist = File::Spec->catfile($cwd, 'Bundle-AppConfig.zip');
  ok(-f $zipdist);
  unlink ($zipdist);
  rmtree($build_dir, 1, 1) if (defined $build_dir and -d $build_dir);
}

done_testing;
