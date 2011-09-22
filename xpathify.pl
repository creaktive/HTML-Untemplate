#!/usr/bin/env perl
use common::sense;

use HTML::Linear;

my $hl = HTML::Linear->new;
#$hl->set_strict;
$hl->parse_file($ARGV[0])
    or die "Can't parse $ARGV[0]: $!";

for my $el ($hl->as_list) {
    my $hash = $el->as_hash;
    say $_ . "\t" . ($hash->{$_} =~ s/\s+/ /grs)
        for sort grep { not m{/\@(?:class|id)$} } keys %{$hash};
}