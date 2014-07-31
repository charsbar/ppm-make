use ExtUtils::MakeMaker;
use warnings;
use strict;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
use Config;
require File::Spec;
use constant WIN32 => $^O eq 'MSWin32';

my %prereqs = (
  'Archive::Tar' => 1.08,
  'Archive::Zip' => 1.02,
  'Compress::Zlib' => 1.0,
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
