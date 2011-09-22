#!/usr/bin/env perl
use common::sense;

use HTML::Linear;

my %elem;
for my $file (@ARGV) {
    my $hl = HTML::Linear->new;
    #$hl->set_strict;
    $hl->parse_file($file)
        or die "Can't parse $file: $!";

    push @{$elem{$_}}, [ $_ => $file ]
        for $hl->as_list;
}

my %xpath;
while (my ($key, $list) = each %elem) {
    for (@{$list}) {
        my ($el, $file) = @{$_};
        my $hash = $el->as_hash;
        $xpath{$_}->{$hash->{$_}} = $file
            for keys %{$hash};
    }
}

for my $xpath (sort keys %xpath) {
    next if 1 == scalar keys %{$xpath{$xpath}};
    next if $xpath =~ m{/\@(?:class|id)$};

    my %file;
    push @{$file{$xpath{$xpath}->{$_}}}, $_
        for keys %{$xpath{$xpath}};

    if (1 < scalar keys %file) {
        say $xpath;
        for my $file (sort keys %file) {
            say "<$file>\t$_" for @{$file{$file}};
        }
        say '';
    }
}
