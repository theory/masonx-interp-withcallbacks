#!perl -w

use strict;
use ExtUtils::MakeMaker;
use File::Spec::Functions qw(catfile catdir);
use constant HAS_APACHE_TEST => eval {require Apache::Test};

# Set up the test suite.
if (HAS_APACHE_TEST) {
    require Apache::TestMM;
    require Apache::TestRunPerl;
    Apache::TestMM->import(qw(test clean));
    Apache::TestMM::filter_args();
    Apache::TestRunPerl->generate_script();
} else {
    print "Skipping Apache test setup.\n";
}

my $clean = join ' ', map { catfile('t', $_) }
  qw(mason TEST logs);

WriteMakefile(
    NAME		=> 'MasonX::Interp::WithCallbacks',
    VERSION_FROM	=> 'lib/MasonX/Interp/WithCallbacks.pm',
    PREREQ_PM		=> { 'HTML::Mason'             => '1.23',
                             'Test::Simple'            => '0.17',
                             'Class::Container'        => '0.09',
                             'Params::CallbackRequest' => '1.11' },
    clean               => { FILES => $clean },
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM    => 'lib/MasonX/Interp/WithCallbacks.pm',
       AUTHOR           => 'David Wheeler <david@kineticode.com>') : ()),
);
