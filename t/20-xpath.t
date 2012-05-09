use common::sense;

use FindBin qw($Bin);
use HTML::TreeBuilder::XPath;
use Path::Class;
use Test::More;

use_ok(q(HTML::Linear));

my $file = q...file($Bin, q(cpan.html));

my $xpath = HTML::TreeBuilder::XPath->new;
isa_ok($xpath, q(HTML::TreeBuilder::XPath));
can_ok($xpath, qw(parse_file findvalue));
ok($xpath->parse_file($file), q(HTML::TreeBuilder::XPath::parse_file));

my $hl = HTML::Linear->new;
$hl->set_strict;

ok($hl->parse_file($file), q(HTML::Linear::parse_file));

my %hash;
for my $el ($hl->as_list) {
    my $hash = $el->as_hash;
    for (keys %{$hash}) {
        if (m{/text\(\)$}sx) {
            $hash{$_} .= $hash->{$_};
        } else {
            $hash{$_} = $hash->{$_};
        }
    }
}

my $n = 0;
for my $expr (keys %hash) {
    my $content = $hash{$expr};
    $content =~ s/^\s+|\s+$//gsx;

    my $value = $xpath->findvalue($expr);
    $value =~ s/^\s+|\s+$//gsx;

    ok(
        $value eq $content,
        qq($expr\t"$value"\t"$content"),
    );

    ++$n;
}

done_testing(5 + $n);
