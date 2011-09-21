#!/usr/bin/env perl
use common::sense;

use HTML::Linear;

my $hl = HTML::Linear->new_from_file($ARGV[0]);

for my $el ($hl->as_list) {
    my $xpath = $el->as_xpath;

    for my $key (sort keys $el->attributes) {
        next if $key =~ m{^(?:class|id)$}i;
        say "${xpath}/\@${key}\t" . $el->attributes->{$key}
            unless $el->attributes->{$key} =~ m{^\s*$}s;
    }

    unless ($el->content =~ m{^\s*$}s) {
        say "${xpath}/text()\t${_}" for split m{\r?\n}, $el->content;
    }
}
