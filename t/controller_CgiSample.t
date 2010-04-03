use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'Catalyst::Test', 'Siva' }
BEGIN { use_ok 'Siva::Controller::CgiSample' }

ok( request('/cgisample')->is_success, 'Request should succeed' );
done_testing();
