package MasonX::Interp::WithCallbacks;

use strict;
use HTML::Mason qw(1.10);
use HTML::Mason::Interp;
use HTML::Mason::Exceptions ();
use Params::CallbackRequest;

use vars qw($VERSION @ISA);
@ISA = qw(HTML::Mason::Interp);
$VERSION = '1.10';

Params::Validate::validation_options
  ( on_fail => sub { HTML::Mason::Exception::Params->throw( join '', @_ ) } );


# We'll use this code reference to eval arguments passed in via httpd.conf
# PerlSetVar directives.
my $eval_directive = { convert => sub {
    return 1 if ref $_[0]->[0];
    for (@{$_[0]}) { $_ = eval $_ }
    return 1;
}};

__PACKAGE__->valid_params
  ( default_priority =>
    { type      => Params::Validate::SCALAR,
      parse     => 'string',
      default   => 5,
      descr     => 'Default callback priority'
    },

    default_pkg_key =>
    { type      => Params::Validate::SCALAR,
      parse     => 'string',
      default   => 'DEFAULT',
      descr     => 'Default package key'
    },

    callbacks =>
    { type      => Params::Validate::ARRAYREF,
      parse     => 'list',
      optional  => 1,
      callbacks => $eval_directive,
      descr     => 'Callback specifications'
    },

    pre_callbacks =>
    { type      => Params::Validate::ARRAYREF,
      parse     => 'list',
      optional  => 1,
      callbacks => $eval_directive,
      descr     => 'Callbacks to be executed before argument callbacks'
    },

    post_callbacks =>
    { type      => Params::Validate::ARRAYREF,
      parse     => 'list',
      optional  => 1,
      callbacks => $eval_directive,
      descr     => 'Callbacks to be executed after argument callbacks'
    },

    cb_classes =>
    { type      => Params::Validate::ARRAYREF | Params::Validate::SCALAR,
      parse     => 'list',
      optional  => 1,
      descr     => 'List of calback classes from which to load callbacks'
    },

    ignore_nulls =>
    { type      => Params::Validate::BOOLEAN,
      parse     => 'boolean',
      default   => 0,
      descr     => 'Execute callbacks with null values'
    },

    cb_exception_handler =>
    { type      => Params::Validate::CODEREF,
      parse     => 'code',
      optional  => 1,
      descr     => 'Callback execution exception handler'
    },
  );


sub new {
    my $class = shift;
    my $self = $class->SUPER::new(@_);
    # This causes everything to be validated twice, but it shouldn't matter
    # much, since interp objects won't be created very often.
    my $exh = delete $self->{cb_exception_handler};
    $self->{cb_request} = Params::CallbackRequest->new
      ( ($exh ? (exception_handler => $exh) : ()),
       map { $self->{$_} ? ($_ => delete $self->{$_}) : () }
        keys %{ __PACKAGE__->valid_params }
    );
    $self;
}

sub make_request {
    my ($self, %p) = @_;
    # We have to grab the parameters and copy them into a hash.
    my %params = @{$p{args}};

    my $apache_req = $p{apache_req}
      || $self->delayed_object_params('request', 'apache_req')
      || $self->delayed_object_params('request', 'cgi_request');

    # Execute the callbacks.
    my $ret =  $self->{cb_request}->request(\%params, $apache_req ?
                                            (apache_req => $apache_req) :
                                            ());

    # Abort the request if that's what the callbacks want.
    HTML::Mason::Exception::Abort->throw
      ( error         => 'Callback->abort was called',
        aborted_value => $ret )
      unless ref $ret;

    # Copy the parameters back and continue. Too much copying!
    $p{args} = [%params];
    $self->SUPER::make_request(%p);
}

1;
__END__
