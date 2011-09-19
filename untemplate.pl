#!/usr/bin/env perl
use common::sense;

use HTML::Linear;

my $hl = HTML::Linear->new_from_file($ARGV[0]);

for my $el ($hl->as_list) {
    #say '<![CDATA[' . join(',', $el->path) . ']]>';
    #say "<!-- $el -->";
    say $el->as_xpath;
    say $el->content if $el->content;
}
