#!/usr/bin/env perl
use common::sense;

use HTML::Linear;

my $hl = HTML::Linear->new_from_file($ARGV[0]);

for my $el ($hl->_list) {
    say '<![CDATA[' . join(',', $el->path) . ']]>';
    say "<!-- $el -->";
    say $el->content if $el->content;
    say '';
}
