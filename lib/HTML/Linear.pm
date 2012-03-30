package HTML::Linear;
# ABSTRACT: ...
use common::sense;

use Moose;
use MooseX::NonMoose;
extends 'HTML::TreeBuilder';

use HTML::Linear::Element;
use HTML::Linear::Path;

# VERSION

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

has _uniq       => (is => 'ro', isa => 'HashRef[Str]', default => sub { {} });

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

...

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

=head1 SEE ALSO

=for :list
* L<HTML::Similarity>
* L<XML::DifferenceMarkup>

=cut
no Moose;
__PACKAGE__->meta->make_immutable;

1;