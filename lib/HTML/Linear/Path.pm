package HTML::Linear::Path;
# ABSTRACT: represent paths inside HTML::Tree
use strict;
use utf8;
use warnings qw(all);

use JSON::XS;
use Moo;
use MooX::Types::MooseLike::Base qw(:all);

use HTML::Linear::Path::Colors;

## no critic (ProhibitPackageVars)

# VERSION

=head1 SYNOPSIS

    use HTML::Linear::Path;

    my $level = HTML::Linear::Path->new({
        address     => q(0.1.1.3.0),
        attributes  => {
            id  => q(li1),
        },
        strict      => 0,
        tag         => q(li),
    });

=attr json

Lazy L<JSON::XS> instance.

=cut

has json        => (
    is          => 'ro',
    isa         => InstanceOf['JSON::XS'],
    default     => sub { JSON::XS->new->ascii->canonical },
    lazy        => 1,
);

=attr address

Location inside L<HTML::TreeBuilder> tree.

=attr attributes

Element attributes.

=attr key

Stringified path representation.

=attr strict

Strict mode disables grouping by tags/attributes listed in L</%HTML::Linear::Path::groupby>.

=attr tag

Tag name.

=cut

has address     => (is => 'rw', isa => Str, required => 1);
has attributes  => (is => 'ro', isa => HashRef[Str], required => 1);
has is_groupable=> (is => 'rw', isa => Bool, default => sub { 0 });
has key         => (is => 'rw', isa => Str, default => sub { '' });
has strict      => (is => 'ro', isa => Bool, default => sub { 0 });
has tag         => (is => 'ro', isa => Str, required => 1);

use overload '""' => \&as_string, fallback => 1;

=head1 GLOBALS

=head2 %HTML::Linear::Path::groupby

Tags/attributes significant as XPath filters.
C<@class>/C<@id> are the most obvious; we also use C<meta/@property>, C<input/@name> and several others.

=cut

our %groupby = (
    class       => [qw(*)],
    id          => [qw(*)],
    name        => [qw(input meta)],
    'http-equiv'=> [qw(meta)],
    property    => [qw(meta)],
    rel         => [qw(link)],
);

=head2 %HTML::Linear::Path::tag_weight

Table of HTML tag weights.
Borrowed from L<TexNet32 - WWW filters|http://publish.uwo.ca/~craven/texnet32/wwwnet32.htm>.

=cut

our %tag_weight = (
    title       => 15,
    h1          => 10,
    h2          => 9,
    h3          => 8,
    h4          => 7,
    h5          => 6,
    h6          => 5,
    center      => 3,
    strong      => 2,
    b           => 2,
    u           => 1,
    em          => 1,
    a           => 1,
    sup         => -1,
    sub         => -1,
    samp        => -1,
    pre         => -1,
    kbd         => -1,
    code        => -1,
    blockquote  => -1,
);

=head2 %HTML::Linear::Path::xpath_wrap

Wrap XPath components to produce fancy syntax highlight.

The format is:

    (
        array       => ['' => ''],
        attribute   => ['' => ''],
        equal       => ['' => ''],
        number      => ['' => ''],
        separator   => ['' => ''],
        sigil       => ['' => ''],
        tag         => ['' => ''],
        value       => ['' => ''],
    )

There are several pre-defined schemes at L<HTML::Linear::Path::Colors>.

=cut

our (%xpath_wrap) = (%{$HTML::Linear::Path::Colors::scheme{default}});

=method as_string

Build a quick & dirty string representation of a path the L<HTML::TreeBuilder> structure.

=cut

sub as_string {
    my ($self) = @_;
    return $self->key if $self->key;

    my $ref = {
        _tag    => $self->tag,
        addr    => $self->address,
    };
    $ref->{attr} = $self->attributes if keys %{$self->attributes};

    return $self->key($self->json->encode($ref));
}

=method as_xpath

Build a nice XPath representation of a path inside the L<HTML::TreeBuilder> structure.

=cut

sub as_xpath {
    my ($self, $strict) = @_;

    my $xpath = _wrap(separator => '/') . _wrap(tag => $self->tag);

    my $expr = '';
    for my $attr (keys %groupby) {
        if (_isgroup($self->tag, $attr) and $self->attributes->{$attr}) {
            $expr .= _wrap(array        => '[');
            $expr .= _wrap(sigil        => '@');
            $expr .= _wrap(attribute    => $attr);
            $expr .= _wrap(equal        => '=');
            $expr .= _wrap(value        => _quote($self->attributes->{$attr}));
            $expr .= _wrap(array        => ']');

            $self->is_groupable(1);

            last;
        }
    }

    return $xpath . (
        (not $self->strict and not $strict)
            ? $expr
            : ''
    );
}

=method weight

Return tag weight.

=cut

sub weight {
    my ($self) = @_;
    return $tag_weight{$self->tag} // 0;
}

=func _quote

Quote attribute values for XPath representation.

=cut

sub _quote {
    local ($_) = @_;

    s/\\/\\\\/gsx;
    s/'/\\'/gsx;
    s/\s+/ /gsx;
    s/^\s//sx;
    s/\s$//sx;

    return "'$_'";
}

=func _wrap

Help to make a fancy XPath.

=cut

sub _wrap {
    my ($p, $q) = @_;
    return
        $xpath_wrap{$p}->[0]
        . $q
        . $xpath_wrap{$p}->[1];
}

=func _isgroup($tag, $attribute)

Checks if C<$tag>/C<$attribute> tuple matches L</%HTML::Linear::Path::groupby>.

=cut

sub _isgroup {
    my ($tag, $attr) = @_;
    return 1 and grep {
        $_ eq '*'
            or
        $_ eq $tag
    } @{$groupby{$attr} // []};
}

1;
