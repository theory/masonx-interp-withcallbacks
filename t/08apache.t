#!perl -w

# $Id: 08apache.t,v 1.2 2003/08/24 22:59:20 david Exp $

use strict;
use Test::More;
my $key = 'myCallbackTester';
my $cbs = [];

BEGIN {
    plan skip_all => 'Testing of apache_req requires Apache::FakeRequest'
      unless eval { require Apache::FakeRequest };
    plan tests => 1;
    use_ok('Params::CallbackRequest');
}



1;
__END__
