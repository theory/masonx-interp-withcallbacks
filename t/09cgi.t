#!perl -w

# $Id: 09cgi.t,v 1.1 2003/08/21 05:19:37 david Exp $

use strict;
use Cwd;
use File::Spec::Functions qw(catdir catfile);
use Test::More tests => 19;
use CGI qw(-no_debug);
use HTML::Mason::CGIHandler;

BEGIN {
    unshift @INC, catdir qw(t lib);
}
use TieOut;

BEGIN { use_ok('MasonX::Interp::WithCallbacks') }

my $key = 'myCallbackTester';
my $cbs = [];
$ENV{PATH_INFO} = '/dhandler';
$ENV{REQUEST_METHOD} = 'GET';

# This will tie off STDOUT so that it doesn't print do the terminal during
# tests.
my $stdout = tie *STDOUT, 'TieOut' or die "Cannot tie STDOUT: $!\n";
my $outbuf;

##############################################################################
# We'll use this subroutine to clear out various buffers between each test.
sub clear_bufs {
    $outbuf = '';
    CGI::initialize_globals();
    $stdout->read;
}

##############################################################################
# Set up callback functions.
##############################################################################
# Simple callback.
sub simple {
    my $cb = shift;
    isa_ok( $cb, 'Params::Callback' );
    isa_ok( $cb->cb_request, 'Params::CallbackRequest' );
    my $params = $cb->params;
    $params->{result} = 'Success';
}

push @$cbs, { pkg_key => $key,
              cb_key  => 'simple',
              cb      => \&simple
            };

##############################################################################
# Abort callbacks.
sub test_abort {
    my $cb = shift;
    isa_ok( $cb, 'Params::Callback');
    $cb->abort($cb->value);
}

push @$cbs, { pkg_key => $key,
              cb_key  => 'test_abort',
              cb      => \&test_abort
            };

##############################################################################
# Check the aborted value.
sub test_aborted {
    my $cb = shift;
    isa_ok( $cb, 'Params::Callback');
    my $params = $cb->params;
    my $val = $cb->value;
    eval { $cb->abort(1) } if $val;
    $params->{result} = $cb->aborted($@) ? 'yes' : 'no';
}

push @$cbs, { pkg_key => $key,
              cb_key  => 'test_aborted',
              cb      => \&test_aborted
            };

##############################################################################
# Set up a redirection callback.
my $url = 'http://example.com/';
sub redir {
    my $cb = shift;
    my $val = $cb->value;
    $cb->redirect($url, $val);
}
push @$cbs, { pkg_key => $key,
              cb_key  => 'redir',
              cb      => \&redir
            };

##############################################################################
# Set up Mason objects.
##############################################################################
ok( my $cgih = HTML::Mason::CGIHandler->new
    ( comp_root    => catdir(cwd, qw(t comp)),
      callbacks    => $cbs,
      interp_class => 'MasonX::Interp::WithCallbacks',
      out_method   => \$outbuf ),
    "Construct CGIHandler object" );
isa_ok($cgih, 'HTML::Mason::CGIHandler');
(ok my $interp = $cgih->interp, "Get Interp object" );
isa_ok($interp, 'MasonX::Interp::WithCallbacks');
isa_ok($interp, 'HTML::Mason::Interp');

##############################################################################
# Try a simple callback.
$ENV{QUERY_STRING} = "$key|simple_cb=1";
ok( $cgih->handle_request, "Handle simple callback request" );
is( $outbuf, 'Success', "Check simple result" );
clear_bufs;

##############################################################################
# Make sure that abort works properly. For Mason 1.22 and earlier, we need
# to catch the exception ourselves.
$ENV{QUERY_STRING} = "$key|simple_cb=1" .
  "&$key|test_abort_cb0=500";
ok( $cgih->handle_request, "Handle abort callback request" );
is( $outbuf, '', "Check abort result" );
clear_bufs;

##############################################################################
# Test the aborted method.
$ENV{QUERY_STRING} = "$key|test_aborted_cb=1";
ok( $cgih->handle_request, "Handle aborted callback request" );
is( $outbuf, 'yes', "Check aborted result" );
clear_bufs;

##############################################################################
# Test redirect.
$ENV{QUERY_STRING} = "$key|redir_cb=0";
ok( $cgih->handle_request, "Handle redirection request" );
is( $outbuf, '', "Check redirection result" );
like( $stdout->read, qr/Status: 302 Moved\s+Location: $url/,
    "Check redirection header" );
clear_bufs;

__END__
