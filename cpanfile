requires 'Archive::Tar' => 1.08;
requires 'Archive::Zip' => 1.02;
requires 'Compress::Zlib' => 1.0;
requires 'Config::IniFiles' => 0;
requires 'CPAN::DistnameInfo' => 0;
requires 'CPAN::Meta::YAML' => 0;
requires 'File::HomeDir' => 0.52;
requires 'File::Spec' => 0;
requires 'Getopt::Long' => 2.33;
requires 'HTTP::Tiny' => 0;
requires 'Pod::Find' => 0.23;
requires 'Pod::Usage' => 1;
requires 'XML::Parser' => 2;
requires 'XML::Writer' => 0;
requires 'version'  => 0;

on test => sub {
  requires 'Test::More' => 0.88;
};
