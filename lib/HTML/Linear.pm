package HTML::Linear;
# ABSTRACT: represent HTML::Tree as a flat list
use strict;
use common::sense;

use Any::Moose;
use Any::Moose qw(X::NonMoose);
extends 'HTML::TreeBuilder';

use HTML::Linear::Element;
use HTML::Linear::Path;

# VERSION

=attr _list

Internal list representation.

=method add_element

Add an element to the list.

=method as_list

Access list as array.

=method count_elements

Number of elements in list.

=method get_element

Element accessor.

=cut

has _list       => (
    traits      => ['Array'],
    is          => 'ro',
    isa         => 'ArrayRef[Any]',
    default     => sub { [] },
    handles     => {
        add_element     => 'push',
        as_list         => 'elements',
        count_elements  => 'count',
        get_element     => 'accessor',
    },
);

=attr _strict

Internal strict mode flag.

=method set_strict

Do not group by C<id>, C<class> or C<name> attributes.

=method unset_strict

Group by C<id>, C<class> or C<name> attributes.

=cut

has _strict => (
    traits      => ['Bool'],
    is          => 'ro',
    isa         => 'Bool',
    default     => 0,
    handles     => {
        set_strict      => 'set',
        unset_strict    => 'unset',
    },
);

=attr _uniq

Used for internal collision detection.

=cut

has _uniq       => (is => 'ro', isa => 'HashRef[Str]', default => sub { {} });

=method eof

Overrides L<HTML::TreeBuilder> C<eof>.

=cut

after eof => sub {
    my ($self) = @_;

    $self->deparse($self, []);

    my $i = 0;
    my %uniq;
    for my $elem ($self->as_list) {
        $elem->index($uniq{join ',', $elem->path}++);
        $elem->index_map($self->_uniq);
    }
};

=method deparse($node, $path)

Recursively scan underlying L<HTML::TreeBuilder> structure.

=cut

sub deparse {
    my ($self, $node, $path) = @_;

    my $level = HTML::Linear::Path->new({
        address     => $node->address,
        attributes  => {
            map     { lc $_ => $node->attr($_) }
            grep    { not m{^[_/]} }
            $node->all_attr_names
        },
        strict      => $self->_strict,
        tag         => $node->tag,
    });

    if (
        not $node->content_list
        or (ref(($node->content_list)[0]) ne '')
    ) {
        $self->add_element(
            HTML::Linear::Element->new({
                depth   => $node->depth,
                path    => [ @{$path}, $level ],
            })
        );
    }

    my %uniq;
    for my $child ($node->content_list) {
        if (ref $child) {
            my $l = $self->deparse($child, [ @{$path}, $level ]);
            push @{$uniq{$l->as_xpath}}, $l->address;
        } else {
            $self->add_element(
                HTML::Linear::Element->new({
                    content => $child,
                    depth   => $node->depth,
                    path    => [ @{$path}, $level ],
                })
            );
        }
    }

    while (my ($xpath, $address) = each %uniq) {
        next if 2 > scalar @{$address};

        my $i = 0;
        $self->_uniq->{$_} =
            HTML::Linear::Path::_wrap(array     => '[')
            . HTML::Linear::Path::_wrap(number  => ++$i)
            . HTML::Linear::Path::_wrap(array   => ']')
                for @{$address};
    }

    return $level;
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
