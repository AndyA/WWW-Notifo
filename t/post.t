use strict;
use warnings;
use Test::More tests => 1;

# TODO: Need to figure out how to test a post without actually
# posting...

package Fake::Notifo;
use strict;
use warnings;
use base qw( WWW::Notifo );

package main;

ok 1, 'is OK';
