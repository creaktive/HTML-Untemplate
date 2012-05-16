use common::sense;

use Set::CrossProduct;
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

my $n = 0;
my $iterator = Set::CrossProduct->new([
    [qw[set_strict unset_strict]],
    [qw[set_shrink unset_shrink]],
]);

for my $tuple ($iterator->combinations) {
    my $hl = HTML::Linear->new;
    for my $opt (@{$tuple}) {
        diag($opt . q(()));
        $hl->$opt();
    }
    next if $tuple->[0] eq q(unset_strict);

    ok($hl->parse_file($file), q(HTML::Linear::parse_file));
    ++$n;

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

    for my $expr (keys %hash) {
        my $content = $hash{$expr};
        $content =~ s/^\s+|\s+$//gsx;

        my $value = $xpath->findvalue($expr);
        $value =~ s/^\s+|\s+$//gsx;

        ok(
            $value eq $content,
            qq(\n$expr\n"$value"\n"$content"),
        );

        ++$n;
    }
}

done_testing(4 + $n);
