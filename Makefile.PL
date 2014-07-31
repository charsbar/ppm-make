use ExtUtils::MakeMaker;
use warnings;
use strict;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
use Config;
require File::Spec;
use constant WIN32 => $^O eq 'MSWin32';

my %prereqs = (
  'Config::IniFiles' => 0,
  'CPAN::DistnameInfo' => 0,
  'File::HomeDir' => 0.52,
  'File::Spec' => 0,
  'Getopt::Long' => 2.33,
  'HTML::Entities' => 0,
  'LWP' => 0,
  'Pod::Find' => 0.23,
  'Pod::Usage' => 1,
  'XML::Parser' => 2,
  'YAML' => 0,
  'version'  => 0,
);

my $home = $ENV{HOME};
my $has_myconfig = 0;
if ($home) {
  eval 
    {require File::Spec->catfile($home, '.cpan', 'CPAN', 'MyConfig.pm');};
  $has_myconfig = 1 unless $@;
}

unless ($has_myconfig) {
  eval {require CPAN::HandleConfig;};
  eval {require CPAN::Config;};
}

if ($@) {
  warn <<'WARN';
    
It appears you have yet to configure the CPAN.pm module.
PPM::Make would use this to map module to distribution names
in the event that a call to a remote soap server fails.
You can configure CPAN.pm by typing

    C:\> perl -MCPAN -e shell

and following through the dialogue.

WARN
}
my $sys_config = $INC{'CPAN/Config.pm'};
if (not $has_myconfig and not WIN32 and not -w $sys_config) {
  die <<"WARN";

You do not have the right permissions to use the settings 
in $sys_config. I would suggest 
creating a CPAN::MyConfig module under $home,
in a .cpan/CPAN/ directory. See the CPAN.pm documentation
for details.

WARN
}

my @path_ext = ();
path_ext();

eval {require Archive::Tar; require Compress::Zlib};
if ($@) {
  my $tar = $Config{tar} || which('tar') || $CPAN::Config->{tar} ;
  my $gzip = $Config{gzip} || which('gzip') || $CPAN::Config->{gzip};
  if ($tar and $gzip) {
    print "Will use $tar and $gzip for .tar.gz archives\n";
  }
  else {
    print <<'WARN';

I could not find software to create .tar.gz archives.
I can add Compress::Zlib and Archive::Tar to the list 
of prerequisites to install, if you like.

WARN
    my $ans = prompt('Add Compress::Zlib and Archive::Tar?', 'yes');
    if ($ans =~ /^y/i) {
      $prereqs{'Archive::Tar'} = 1.08;
      $prereqs{'Compress::Zlib'} = 1.0;
    }
    else {
      die <<'DEATH';

Software to handle .tar.gz could not be found. Please
reconsider either the Compress::Zlib and Archive::Tar modules,
or else external programs.

DEATH
    }
  }
}
else {
  my $atv = mod_version('Archive::Tar');
  if ($atv < 1.08 and WIN32) {
    print <<'AT';

Archive::Tar version 1.08 or greater is needed.
I can add this to the list of prerequisites, if you like.

AT
    my $ans = prompt('Add Archive::Tar?', 'yes');
    if ($ans =~ /^y/i) {
      $prereqs{'Archive::Tar'} = 1.08;
    }
  }
  print "Will use Archive::Tar and Compress::Zlib for .tar.gz archives\n";
}

eval {require Archive::Zip;};
if ($@) {
  my $zip = $Config{zip} || which('zip') || $CPAN::Config->{zip};
  my $unzip = $Config{unzip} || which('unzip') || $CPAN::Config->{unzip};
  if ($zip and $unzip) {
    print "Will use $zip and $unzip for .zip archives\n";
  }
  else {
    print <<'WARN';

I could not find software to handle .zip archives.
I can add Archive::Zip to the list of prerequisites to 
install, if you like.

WARN
    my $ans = prompt('Add Archive::Zip?', 'yes');
    if ($ans =~ /^y/i) {
      $prereqs{'Archive::Zip'} = 1.02;
    }
    else {
      print <<'WARN';

The package will still be able to function in creating
tar.gz archives, but not zip archives.

WARN
    }
  }
}
else {
  my $zipv = mod_version('Archive::Zip');
  if ($zipv < 1.02) {
    print <<'ZIP';

Archive::Zip version 1.02 or greater is needed.
I can add this to the list of prerequisites, if you like.

ZIP
    my $ans = prompt('Add Archive::Zip?', 'yes');
    if ($ans =~ /^y/i) {
      $prereqs{'Archive::Zip'} = 1.02;
    }
    else {
      print <<'WARN';

The package will still be able to function in creating
tar.gz archives, but not zip archives.

WARN
    }
  }
  else {
    print "Will use Archive::Zip for .zip archives\n";
  }
}

eval{require Module::Build; };
if ($@) {
  print <<'WARN';

I could not find Module::Build, which is necessary to
install (a growing number of) packages. I can add this
to the list of prerequisites to install, if you like.

WARN
  my $ans = prompt('Add Module::Build?', 'yes');
  if ($ans =~ /^y/i) {
    $prereqs{'Module::Build'} = 0;
  }
  else {
    print <<'WARN';

The package is still usable, but will not be able to handle
distributions requiring Module::Build.

WARN

  }
}

my @exe_files = map{"bin/$_"} qw(make_ppm ppm_install rep_summary
                                 make_ppm_bundle make_ppm_install);
#push @exe_files, 'tk-ppm' if WIN32;

my $eu_version = mod_version('ExtUtils::MakeMaker');
my %opts;
if ($eu_version >= 5.43) {
  $opts{ABSTRACT_FROM} = q{lib/PPM/Make.pm};
  $opts{AUTHOR} = 'Randy Kobes <r.kobes@uwinnipeg.ca>';
}

$opts{test} = {TESTS => "t/*.t xt/*.t"} if -d "xt";

if ($eu_version >= 6.31) {
  $opts{LICENSE} = 'perl';
}
if ($eu_version >= 6.46) {
  $opts{META_MERGE}{resources} = {
    license => 'http://dev.perl.org/licenses/',
    homepage => 'https://github.com/charsbar/ppm-make',
    repository => 'https://github.com/charsbar/ppm-make',
    bugtracker => 'http://rt.cpan.org/NoAuth/Bugs.html?Dist=PPM-Make',
    AnnoCPAN => 'http://annocpan.org/dist/PPM-Make',
    CPANForum => 'http://www.cpanforum.com/dist/PPM-Make',
    CPANTS => 'http://cpants.perl.org/dist/PPM-Make',
    Rating => 'http://cpanratings.perl.org/d/PPM-Make',
    SearchCPAN => 'http://search.cpan.org/~ISHIGAKI/PPM-Make/',
    Testers => 'http://cpantesters.perl.org/show/PPM-Make.html',
    UWinnipeg => 'http://cpan.uwinnipeg.ca/dist/PPM-Make',
  };
}

WriteMakefile(
              NAME         => 'PPM::Make',
              VERSION_FROM => 'lib/PPM/Make.pm',
              EXE_FILES    => [@exe_files],
              dist         => {COMPRESS => 'gzip', SUFFIX => 'gz'},
              PREREQ_PM    => \%prereqs,
              %opts,
             );

sub path_ext {
  if ($ENV{PATHEXT}) {
    push @path_ext, split ';', $ENV{PATHEXT};
    for my $ext (@path_ext) {
      $ext =~ s/^\.*(.+)$/$1/;
    }
  }
  else {
    #Win9X: doesn't have PATHEXT
    push @path_ext, qw(com exe bat);
  }
}

sub mod_version {
  my $mod = shift;
  eval "require $mod";
  return if $@;
  my $mv = eval "$mod->VERSION";
  return 0 if $@;
  $mv =~ s/_.*$//x;
  $mv += 0;
  return $mv;
}

sub which {
  my $program = shift;
  return undef unless $program;
  my @results = ();
  for my $base (map { File::Spec->catfile($_, $program) } File::Spec->path()) {
    if ($ENV{HOME} and not WIN32) {
      # only works on Unix, but that's normal:
      # on Win32 the shell doesn't have special treatment of '~'
      $base =~ s/~/$ENV{HOME}/o;
    }
    return $base if -x $base;

    if (WIN32) {
      for my $ext (@path_ext) {
        return "$base.$ext" if -x "$base.$ext";
      }
    }
  }
}
