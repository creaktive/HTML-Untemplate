use common::sense;

use Test::More tests => 1;

BEGIN {
    use_ok(q(HTML::Linear));
};

diag(qq(Testing HTML::Linear v$HTML::Linear::VERSION, Perl $], $^X));
