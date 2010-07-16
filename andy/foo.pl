#!/usr/bin/env perl

use strict;
use warnings;

use lib qw( lib lwp );

use WWW::Notifo;

my $no = WWW::Notifo->new(
  username => 'hexten',
  secret   => 'x3badd90afe51b617ce62b45e8d73650c43127f0d'
);

$no->send_notification(
  to    => 'hexten',
  msg   => 'Testing...',
  label => 'Test',
  title => 'Hoot',
  url   => 'http://hexten.net/'
);

# vim:ts=2:sw=2:sts=2:et:ft=perl

