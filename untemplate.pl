#!/usr/bin/env perl
use common::sense;

use HTML::Linear;
use Term::ANSIColor qw(:constants);
use Tie::IxHash;

my $color = -t *STDOUT ? 1 : 0;

if ($color) {
    # ugly in the morning
    %HTML::Linear::Path::xpath_wrap = (
        array       => [BOLD . CYAN,            RESET],
        attribute   => [BOLD . BRIGHT_YELLOW,   RESET],
        equal       => [BOLD . YELLOW,          RESET],
        number      => [BOLD . BRIGHT_GREEN,    RESET],
        separator   => [BOLD . RED,             RESET],
        sigil       => [BOLD . MAGENTA,         RESET],
        tag         => [BOLD . BRIGHT_BLUE,     RESET],
        value       => [BOLD . BRIGHT_WHITE,    RESET],
    );
}

tie my %elem, 'Tie::IxHash';
for my $file (@ARGV) {
    my $hl = HTML::Linear->new;
    #$hl->set_strict;
    $hl->parse_file($file)
        or die "Can't parse $file: $!";

    push @{$elem{$_}}, [ $_ => $file ]
        for $hl->as_list;
}

tie my %xpath, 'Tie::IxHash';
while (my ($key, $list) = each %elem) {
    for (@{$list}) {
        my ($el, $file) = @{$_};
        my $hash = $el->as_hash;
        $xpath{$_}->{$hash->{$_}} = $file
            for keys %{$hash};
    }
}

for my $xpath (keys %xpath) {
    next if 1 == scalar keys %{$xpath{$xpath}};
    next if $xpath =~ m{/\@(?:class|id)$};

    my %file;
    push @{$file{$xpath{$xpath}->{$_}}}, $_
        for keys %{$xpath{$xpath}};

    if (1 < scalar keys %file) {
        say $xpath;
        for my $file (sort keys %file) {
            for (@{$file{$file}}) {
                if ($color) {
                    print GREEN . $file . RESET;
                } else {
                    print $file;
                }
                say "\t${_}";
            }
        }
        say '';
    }
}
