package HTML::Linear;
use common::sense;

use Data::NestedSet;
use Moose;
use MooseX::NonMoose;
extends 'HTML::TreeBuilder';

use HTML::Linear::Element;
use HTML::Linear::Path;

has _list       => (
    traits      => ['Array'],
    is          => 'ro',
    isa         => 'ArrayRef[Any]',
    default     => sub { [] },
    handles     => {qw{
        add_element     push
        count_elements  count
    }},
    auto_deref  => 1,
);

after eof => sub {
    my ($self) = @_;

    $self->deparse($self, []);

    my $i = 0;
    my (@list, %uniq);
    push @list, [ $i++, $_->depth ] for $self->_list;

    my $nodes = Data::NestedSet->new(\@list, 1)->create_nodes;
    for (@{$nodes}) {
        my ($i, $depth, $left, $right) = @{$_};
        my $elem = $self->_list->[$i];

        $elem->index($uniq{join ',', $elem->path}++);

        $elem->left($left);
        $elem->right($right);
    }
};

sub deparse {
    my ($self, $node, $path) = @_;

    my $level = HTML::Linear::Path->new({
        address     => $node->address,
        attributes  => {
            map     { lc $_ => $node->attr($_) }
            grep    { not m{^_} }
            $node->all_attr_names
        },
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

    for my $child ($node->content_list) {
        if (ref $child) {
            $self->deparse($child, [ @{$path}, $level ]);
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
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
