use strict;
use warnings;
use Test::More tests => 12;
use WWW::Notifo;

my %URIS = (
    login     => 'http://www.notifo.com/Users/login?redirect_page=main',
    add_notifo => 'http://www.notifo.com/TimeLine/addNotifo',
    notifications => 'http://www.notifo.com/Notifications',
    accept_friend => 'http://www.notifo.com/Notifications/allow',
    deny_friend   => 'http://www.notifo.com/Notifications/deny',
    get_friends   => 'http://www.notifo.com/Users/getFriends',
    get_notifos    => 'http://www.notifo.com/TimeLine/getNotifos',
    add_response  => 'http://www.notifo.com/Responses/add',
    get_responses => 'http://www.notifo.com/Responses/get2',
    get_unread_notifos =>
      'http://www.notifo.com/TimeLine/getUnreadNotifos',
    get_completion => 'http://www.notifo.com/Users/getCompletion',
);

my $notifo = WWW::Notifo->new;

while ( my ( $key, $uri ) = each %URIS ) {
    is $notifo->_uri_for( $key ), $uri, "uri for $key";
}

is_deeply $notifo->_decode_json(
    q{[ new Date("Sun, 05 Apr 1964 00:00:00 GMT"), "\"Q\"" ]} ),
  [ -181180800, '"Q"' ],
  'json';
