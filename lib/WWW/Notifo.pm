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

This document describes WWW::Notifo version 0.01

=cut

our $VERSION = '0.01';

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

sub new {
  my ( $class, @args ) = @_;
  croak "Expected a number of key => value pairs"
   if @args % 2;
  return bless {@args}, $class;
}

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
