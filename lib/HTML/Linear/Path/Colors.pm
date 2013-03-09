package HTML::Linear::Path::Colors;
# ABSTRACT: color schemes to render HTML::Linear::Path
use strict;
use utf8;
use warnings qw(all);

use HTML::Entities;
use Term::ANSIColor qw(:constants :constants256);

## no critic (ProhibitPackageVars)

# VERSION

=head1 SYNOPSIS

    use HTML::Linear::Path;
    use HTML::Linear::Path::Colors;

    (%HTML::Linear::Path::xpath_wrap) = (%{$HTML::Linear::Path::Colors::scheme{terminal}})

=head1 DESCRIPTION

Pre-defined stuff for the fancy XPath highlights.

=head1 GLOBALS

=head2 %HTML::Linear::Path::Colors::scheme

=for :list
* C<default> - empty
* C<terminal> - ANSI colors
* C<html> - HTML markup re-wrapper

=cut

our %scheme = (
    default => {
        array       => ['' => ''],
        attribute   => ['' => ''],
        equal       => ['' => ''],
        number      => ['' => ''],
        separator   => ['' => ''],
        sigil       => ['' => ''],
        tag         => ['' => ''],
        value       => ['' => ''],
    },
    terminal => {
        array       => [BOLD . CYAN,            RESET],
        attribute   => [BOLD . BRIGHT_YELLOW,   RESET],
        equal       => [BOLD . YELLOW,          RESET],
        number      => [BOLD . BRIGHT_GREEN,    RESET],
        separator   => [BOLD . RED,             RESET],
        sigil       => [BOLD . MAGENTA,         RESET],
        tag         => [BOLD . BRIGHT_BLUE,     RESET],
        value       => [BOLD . BRIGHT_WHITE,    RESET],
    },
    terminal256 => {
        array       => [BOLD . RGB155,          RESET],
        attribute   => [BOLD . RGB551,          RESET],
        equal       => [BOLD . RGB110,          RESET],
        number      => [BOLD . RGB151,          RESET],
        separator   => [BOLD . RGB511,          RESET],
        sigil       => [BOLD . RGB515,          RESET],
        tag         => [BOLD . RGB115,          RESET],
        value       => [BOLD . RGB555,          RESET],
    },
    html => {
        array       => [q(<span class="arr">) => q(</span>)],
        attribute   => [q(<span class="att">) => q(</span>)],
        equal       => [q(<span class="eql">) => q(</span>)],
        number      => [q(<span class="num">) => q(</span>)],
        separator   => [q(<span class="sep">) => q(</span>)],
        sigil       => [q(<span class="sig">) => q(</span>)],
        tag         => [q(<span class="tag">) => q(</span>)],
        value       => [q(<span class="val">) => q(</span>)],
    },
);

=head2 @HTML::Linear::Path::Colors::html

Default HTML header/footer.

=cut

our @html = (<<'BOILERPLATE_HTML_HEADER',
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN">
<html>
<head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<link rel="stylesheet" href="http://creaktive.github.com/HTML-Untemplate/highlight.css" type="text/css">
<link rel="stylesheet" href="highlight.css" type="text/css">
</head>
<body>
<table summary="">
BOILERPLATE_HTML_HEADER
<<'BOILERPLATE_HTML_FOOTER');
</table>
</body>
</html>
BOILERPLATE_HTML_FOOTER

=func wrap_xpath($xpath)

Wraps C<$xpath> with HTML.
Returns wrapped C<$xpath>.

=cut

sub wrap_xpath {
    my ($xpath) = @_;

    $xpath =~ s{
        (<[^>]+>)(.*?)(</[^>]+>)
    }{
        $1 . encode_entities($2) . $3
    }egsx;

    return $xpath;
}

=func wrap_content($content, $html)

Wraps C<$content> with ANSI colors or HTML if C<$html> flag is true.
Returns wrapped C<$content>.

=cut

sub wrap_content {
    my ($content, $html) = @_;

    if ($html // 0) {
        $content = encode_entities($content);
        $content =~ s{
            (^\s+|(?<=\n)\s+|\s+(?=\n)|\s+$)
        }{
            my $s = $1;
            $s =~ s/\s/&nbsp;/gsx;
            qq(<u>$s</u>)
        }egsx;
        $content =~ s{\r?\n}{<br>}gsx;
        $content =~ s{\s}{&nbsp;}gsx;
    } else {
        $content =~ s{
            (^\s+|(?<=\n)\s+|\s+(?=\n)|\s+$)
        }{
            ON_RED . $1 . RESET
        }egsx;
    }

    return $content;
}

1;
