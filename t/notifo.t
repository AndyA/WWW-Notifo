#!perl

use strict;
use warnings;

use lib qw( t/lib );

use Test::More tests => 20;
use JSON;
use MIME::Base64;
use WWW::Notifo;

sub want_error(&$;$) {
  my ( $cb, $re, $msg ) = @_;
  $msg = 'error' unless $msg;
  eval { $cb->() };
  ok $@, "$msg: threw error";
  like $@, $re, "$msg: error matches";
}

{
  my $HR;

  sub patch_ua {
    my $not = shift;
    $not->_ua->add_handler( request_send => sub { $HR->( @_ ) } );
  }

  sub handle_request(&) { $HR = shift }
}

sub check_request {
  my ( $req, $not ) = @_;
  is $req->method, 'POST', 'method is POST';
  my $auth = $req->header( 'Authorization' );
  like $auth, qr{^Basic\s+\S+$}, 'auth header';
  my ( $cred ) = $auth =~ m{^Basic\s+(\S+)};    # like tramples on $1
  my ( $username, $secret ) = split /:/, MIME::Base64::decode( $cred ),
   2;
  is $username, $not->username, 'username';
  is $secret,   $not->secret,   'secret';
}

sub response($) {
  my $cont = shift;
  my $resp = HTTP::Response->new;
  $resp->content_type( 'application/json' );
  $resp->content( JSON->new->encode( $cont ) );
  $resp->code( 200 );
  return $resp;
}

sub decode_uri {
  my $str = shift;
  $str =~ s/\+/%20/g;
  $str =~ s/%([0-9a-f]{2})/chr hex $1/eig;
  return $str;
}

sub decode_form {
  my $cont = shift;
  my $vars = {};
  for my $arg ( split /&/, $cont ) {
    die "Bad arg: $arg" unless $arg =~ /(.+?)=(.+)/;
    $vars->{ decode_uri( $1 ) } = decode_uri( $2 );
  }
  return $vars;
}

want_error { WWW::Notifo->new } qr{missing}i, 'missing args';
want_error { WWW::Notifo->new( 'foo' ) } qr{a number}i,
 'odd number of args';

ok my $not = WWW::Notifo->new(
  username => 'alice',
  secret   => 's3kr1t'
 ),
 'new';

isa_ok $not, 'WWW::Notifo';
patch_ua( $not );

handle_request {
  my $req = shift;
  check_request( $req, $not );
  is $req->uri, 'https://api.notifo.com/v1/subscribe_user', 'uri';
  is_deeply decode_form( $req->content ), { username => 'bob' },
   'content';
  return response {
    status           => 'success',
    response_code    => 2201,
    response_message => 'OK'
  };
};

is_deeply $not->subscribe_user( username => 'bob' ),
 {
  status           => 'success',
  response_code    => 2201,
  response_message => 'OK'
 },
 'subscribe_user';

handle_request {
  my $req = shift;
  check_request( $req, $not );
  is $req->uri, 'https://api.notifo.com/v1/send_notification', 'uri';
  is_deeply decode_form( $req->content ),
   {
    to    => 'hexten',
    msg   => 'Testing...',
    label => 'Test',
    title => 'Hoot',
    uri   => 'http://hexten.net/'
   },
   'content';
  return response {
    status           => 'success',
    response_code    => 2201,
    response_message => 'OK'
  };
};

is_deeply $not->send_notification(
  to    => 'hexten',
  msg   => 'Testing...',
  label => 'Test',
  title => 'Hoot',
  uri   => 'http://hexten.net/'
 ),
 {
  status           => 'success',
  response_code    => 2201,
  response_message => 'OK'
 },
 'send_notification';

# vim:ts=2:sw=2:et:ft=perl

