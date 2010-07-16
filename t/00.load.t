use Test::More tests => 3;

BEGIN {
    use_ok( 'WWW::Notifo' );
    use_ok( 'WWW::Notifo::Friend' );
    use_ok( 'WWW::Notifo::Message' );
}

diag( "Testing WWW::Notifo $WWW::Notifo::VERSION" );
