package WWW::Notifo;

use warnings;
use strict;

use Carp;
use JSON;
use Data::Dumper;
use LWP::UserAgent;
use MIME::Base64;

=head1 NAME

WWW::Notifo - Unoffical notifo.com API

=head1 VERSION

This document describes WWW::Notifo version 0.02

=cut

our $VERSION = '0.02';

=head1 SYNOPSIS

    use WWW::Notifo;
    my $notifo = WWW::Notifo->new( username => 'foo', secret => 'xabc123' );
   
    # Subscribe a user...
    my $status = $notifo->subscribe_user( username => 'bar' );
    
    # Send a notification
    my $status = $notifo->send_notification(
       to    => 'someone',
       msg   => 'Hello!',
       label => 'JAPH',
       title => 'Boo',
       url   => 'http://example.com/'
    );

=head1 DESCRIPTION

Notifo (L<http://notifo.com/>) is a web based notification service that
can send push messages to mobile deviceas.

From L<http://notifo.com/>:

  What Can I Do With Notifo?

  If you are a User, you can subscribe to receive notifications from
  your favorite services that integrate with Notifo. On Notifo's site
  you can set timers, send yourself messages, set stock alerts, and
  Google Voice SMS alerts. More built-in services will be released in
  the near future.

  If you are a Service, you can integrate with Notifo's API and start
  sending mobile notifications to your users within a few hours. No need
  to spend time or resources developing mobile applications just so you
  can reach your users!

=cut

use constant API => 'https://api.notifo.com/v1';

use accessors::ro qw( username secret );

BEGIN {
  my @meth = qw( subscribe_user send_notification );
  for my $m ( @meth ) {
    no strict 'refs';
    *{$m} = sub { shift->api( $m, @_ ) };
  }
}

sub _need {
  my ( $need, @args ) = @_;
  croak "Expected a number of key => value pairs"
   if @args % 2;
  my %args = @args;
  my @missing = grep { !defined $args{$_} } @$need;
  croak "Missing options: ", join( ', ', sort @missing )
   if @missing;
  return %args;
}

=head2 C<< new >>

Create a new C<WWW::Notifo> object. In common with all methods exposed
by the module accepts a number of key => value pairs. The C<username>
and C<secret> options are mandatory:

  my $notifo = WWW::Notifo->new(
    username => 'alice',
    secret   => 'x3122b4c4d3bad5e8d7397f0501b617ce60afe5d'
  );

=cut

sub new {
  my $class = shift;
  return bless { _need( [ 'secret', 'username' ], @_ ) }, $class;
}

=head2 API Calls

API calls provide access to the Notifo API. On success they return a
reference to a hash containing the response from notifo.com. On API
errors the hash will contain information about the error. On HTTP errors
an exception will be thrown.

=head3 C<< subscribe_user >>

Service providers must call this method when users want to subscribe to
notifo alerts. This method will send a confirmation message to the user
where they can complete the opt-in process. The service provider will
not be able to send notifications to the user until this subscribe/opt-
in process has been completed.

Users sending notifications to themselves with their User account do not
need to use this method. Since a User account can only send
notifications to itself, it is already implicitly subscribed. Only
Service accounts need to use this method to subscribe other users.

  my $resp = $notifo->subscribe_user(
    username => 'hexten'
  );

=head3 C<< send_notification >>

Once a user has subscribed to notifo alerts, service providers can call
this method to send notifications to specific users. The C<to> and
C<msg> parameters are required. The C<title> parameter is optional, and
can be thought of as a description of the type of notification being
sent (almost like the subject of an email). The C<uri> parameter is used
to specify what URI (web address, app uri, etc) will be loaded when the
user opens the notification. If omitted, the default service provider
URL is used.

  my $resp = $notifo->send_notification(
    to    => 'hexten',
    msg   => 'Testing...',
    label => 'Test',
    title => 'Hoot',
    url   => 'http://hexten.net/'
  );

=head3 C<< api >>

API entry points other than C<subscribe_user> and C<send_notification>
(of which there are currently none) can be accessed directly by
calling C<api>. For example, the above send_notification example can also be written as:

  my $resp = $notifo->api(
    'send_notification',
    to    => 'hexten',
    msg   => 'Testing...',
    label => 'Test',
    title => 'Hoot',
    url   => 'http://hexten.net/'
  );

=cut

sub api {
  my ( $self, $method, @args ) = @_;
  croak "Expected a number of key => value pairs"
   if @args % 2;
  my $resp
   = $self->_ua->post( join( '/', API, $method ), Content => \@args );
  croak $resp->status_line if $resp->is_error;
  return JSON->new->decode( $resp->content );
}

sub _make_ua {
  my $self = shift;
  my $ua   = LWP::UserAgent->new;
  $ua->agent( join ' ', __PACKAGE__, $VERSION );
  $ua->add_handler(
    request_send => sub {
      shift->header( 'Authorization' => $self->_auth_header );
    }
  );
  return $ua;
}

sub _auth_header {
  my $self = shift;
  return 'Basic '
   . MIME::Base64::encode( join( ':', $self->username, $self->secret ),
    '' );
}

sub _ua {
  my $self = shift;
  return $self->{_ua} ||= $self->_make_ua;
}

1;
__END__

=head1 AUTHOR

Andy Armstrong  C<< <andy@hexten.net> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2010, Andy Armstrong  C<< <andy@hexten.net> >>.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.
