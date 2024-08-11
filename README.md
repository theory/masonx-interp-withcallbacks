MasonX/Interp/WithCallbacks version 1.20
========================================

[![🧅 CPAN version](https://badge.fury.io/pl/MasonX-Interp-WithCallbacks.svg)](https://badge.fury.io/pl/MasonX-Interp-WithCallbacks)
[![✅ Build Status](https://github.com/theory/masonx-interp-withcallbacks/actions/workflows/ci.yml/badge.svg)](https://github.com/theory/masonx-interp-withcallbacks/actions/workflows/ci.yml)

MasonX::Interp::WithCallbacks subclasses HTML::Mason::Interp in order to
provide a [Mason] callback system built on [Params::CallbackRequest].
Callbacks may be either code references provided to the `new()` constructor,
or methods defined in subclasses of [Params::Callback]. Callbacks are triggered
either for every request or by specially named keys in the Mason request
arguments, and all callbacks are executed at the beginning of a request, just
before Mason creates and executes the request component stack.

This module brings support for a sort of plugin architecture based on
Params::CallbackRequest to Mason. Mason then executes code before executing
any components. This approach allows you to carry out logical processing of
data submitted from a form, to affect the contents of the Mason request
arguments (and thus the `%ARGS` hash in components), and even to redirect or
abort the request before Mason handles it.

Installation
------------

To install this module type the following:

    perl Build.PL
    ./Build
    ./Build test
    ./Build install

Dependencies
------------

This module requires these other modules and libraries:

* Params::CallbackRequest 1.10 or later
* HTML::Mason 1.23 or later
* Params::Validate 0.59 or later
* Exception::Class 1.10 or later

The object-oriented callback interface requires Perl 5.6 or later and
these other modules and libraries:

* Attribute::Handlers 0.77 or later
* Clas::ISA

The test suite requires:

* Test::Simple 0.17 or later

Testing of this module with HTML::Mason::ApacheHandler requires:

* Apache::Test 1.03 or later
* mod_perl 1.22 or later
* LWP

Copyright and License
---------------------

Copyright (c) 2003-2024 David E. Wheeler. Some Rights Reserved.

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

  [HTML::Mason::Interp]: https://metacpan.org/pod/HTML::Mason::Interp
  [Mason]: https://metacpan.org/dist/HTML-Mason
  [Params::CallbackRequest]: https://metacpan.org/pod/Params::CallbackRequest
  [Params::Callback]: https://metacpan.org/pod/Params::Callback
