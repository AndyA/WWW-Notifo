use strict;
use warnings;
use WWW::Notifo;
use Test::More;
use Test::Deep;

if ( my $notifo_env = $ENV{PLURK_TEST_ACCOUNT} ) {
    plan tests => 11;
    my ( $user, $pass ) = split /:/, $notifo_env, 2;

    my $notifo = WWW::Notifo->new;
    eval { $notifo->login( $user, $pass ) };
    ok !$@, "login: no error" or diag "$@";

    # use Data::Dumper;
    # diag Dumper( $notifo );

    is $notifo->nick_name, $user, "nick name";

    my @friends = eval { $notifo->friends };
    ok !$@, "friends: no error" or diag "$@";
    cmp_deeply [@friends],
      array_each(
        all( isa( 'WWW::Notifo::Friend' ), methods( notifo => $notifo ) )
      ),
      "friends";

    my @notifos = eval { $notifo->notifos };
    ok !$@, "messages: no error" or diag "$@";
    cmp_deeply [@notifos],
      array_each(
        all( isa( 'WWW::Notifo::Message' ), methods( notifo => $notifo ) )
      ),
      "messages";

    if ( @notifos ) {
        my $message = $notifos[0];
        {
            my @responses = eval { $message->responses };
            ok !$@, "responses: no error" or diag "$@";
            cmp_deeply [@responses],
              array_each(
                all(
                    isa( 'WWW::Notifo::Message' ),
                    methods( notifo => $notifo )
                )
              ),
              "responses";
        }
        {
            my $link = $message->permalink;
            ok can_fetch( $notifo->_ua, $link );
        };
    }
    else {
        pass "no responses" for 1 .. 2;
    }

    my @unread = eval { $notifo->unread_notifos };
    ok !$@, "unread: no error" or diag "$@";
    cmp_deeply [@unread],
      array_each(
        all( isa( 'WWW::Notifo::Message' ), methods( notifo => $notifo ) )
      ),
      "unread";
}
else {
    plan skip_all =>
      'Set $ENV{PLURK_TEST_ACCOUNT} to "user:pass" to run these tests';
}

sub can_fetch {
    my ( $ua, $uri ) = @_;
    my $resp = $ua->get( $uri );
    return $resp->is_success;
}
