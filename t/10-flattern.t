use common::sense;

use Data::Dumper;
use FindBin qw($Bin);
use Path::Class;
use Test::More;

use_ok(q(HTML::Linear));

my $hl = HTML::Linear->new;
isa_ok($hl, q(HTML::Linear));
can_ok($hl, qw(
    eof
    set_strict
    parse_file
    as_list
));

ok(
    $hl->set_strict,
    q(set_strict),
);

ok(
    $hl->parse_file(q...file($Bin, q(test.html))),
    q(parse_file),
);

my $n = 0;
my %hash;

for my $el ($hl->as_list) {
    isa_ok($el, q(HTML::Linear::Element));
    can_ok($el, qw(as_hash));

    my $hash = $el->as_hash;
    $hash{$_} .= $hash->{$_}
        for keys %{$hash};

    ++$n;
}

my $expect = {
    '/html/body/h1/text()' => 'test 2',
    '/html/body/p[1]/text()' => ' Lorem ipsum dolor sit amet, consectetur adipiscing elit.  Ut sed scelerisque nulla.  Nam sit amet massa ac justo lacinia cursus. Et harum quidem rerum facilis est et expedita distinctio. ',
    '/html/body/p[1]/ul/li[1]/@id' => 'li1',
    '/html/body/p[1]/ul/li[1]/text()' => 'Vestibulum ullamcorper eleifend justo.',
    '/html/body/p[1]/ul/li[2]/text()' => 'Sed id sapien tortor.',
    '/html/body/p[1]/ul/li[3]/text()' => ' Fusce et volutpat mi. ',
    '/html/body/p[1]/ul/li[4]/text()' => 'Quisque ullamcorper mauris lacus.',
    '/html/body/p[1]/ul/li[5]/text()' => 'Nunc in erat sit amet nisi vulputate pharetra.',
    '/html/body/p[2]/text()' => ' Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur? ',
    '/html/head/title/text()' => 'test 1',
};

ok(
    scalar keys %hash == scalar keys %{$expect},
    q(result length match),
);

my $err = 0;
ok(
    $hash{$_} eq $expect->{$_},
    qq(XPath $_)
) or ++$err for keys %$expect;

$Data::Dumper::Sortkeys = 1;
$err and diag(Dumper \%hash);

done_testing(6 + $n * 2 + keys %{$expect});
