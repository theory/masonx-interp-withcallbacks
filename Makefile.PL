#!perl -w

use strict;
use ExtUtils::MakeMaker;
use File::Spec::Functions qw(catfile catdir);

my $clean = join ' ', map { catfile('t', $_) }
  qw(data TEST logs);

WriteMakefile(
    NAME		=> 'MasonX::Interp::WithCallbacks',
    VERSION_FROM	=> 'lib/MasonX/Interp/WithCallbacks.pm',
    PREREQ_PM		=> { 'HTML::Mason'             => '1.10',
                             'Apache::Test'            => '1.03',
                             'Test::Simple'            => '0.17',
                             'Params::CallbackRequest' => '1.10',
                             'mod_perl'                => '1.22' },
    clean               => { FILES => $clean },
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'lib/MasonX/Interp/WithCallbacks.pm',
       AUTHOR     => 'David Wheeler <david@kineticode.com>') : ()),
);

sub make_data_dir {
    # Create the data directory if it doesn't exist.
    my $data_dir = catdir('t', 'data');
    mkdir $data_dir, 0777 or die "Can't make dir '$data_dir': $!\n"
      unless -d $data_dir;

    # Allow anyone to write files to the data directory.
    chmod 0777, $data_dir or die "Can't chmod '$data_dir': $!\n";
}
