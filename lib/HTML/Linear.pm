package HTML::Linear;
# ABSTRACT: represent HTML::Tree as a flat list
use strict;
use utf8;
use warnings qw(all);

use Digest::SHA qw(sha256);

use Moo;
use MooX::Types::MooseLike::Base qw(:all);
extends 'HTML::TreeBuilder';

use HTML::Linear::Element;
use HTML::Linear::Path;

## no critic (ProtectPrivateSubs, RequireFinalReturn)

# VERSION

=head1 SYNOPSIS

    use Data::Printer;
    use HTML::Linear;

    my $hl = HTML::Linear->new;
    $hl->parse_file(q(index.html));

    for my $el ($hl->as_list) {
        my $hash = $el->as_hash;
        p $hash;
    }

=attr _list

Internal list representation.

=method as_list

Access list as array.

=method count_elements

Number of elements in list.

=method get_element

Element accessor.

=cut

has _list       => (
    is          => 'ro',
    isa         => ArrayRef[InstanceOf('HTML::Linear::Element')],
    default     => sub { [] },
);

sub _add_element { push @{shift->_list}, shift }
sub as_list { @{shift->_list} }
sub count_elements { 0 + @{shift->_list} }
sub get_element { shift->_list->[shift] }

=attr _shrink

Internal shrink mode flag.

=method set_shrink

Enable XPath shrinking.

=method unset_shrink

Disable XPath shrinking.

=cut

has _shrink => (
    is          => 'rwp',
    isa         => Bool,
    default     => sub { 0 },
);

sub set_shrink { shift->_set__shrink(1) }
sub unset_shrink { shift->_set__shrink(0) }

=attr _strict

Internal strict mode flag.

=method set_strict

Do not group by C<id>, C<class> or C<name> attributes.

=method unset_strict

Group by C<id>, C<class> or C<name> attributes.

=cut

has _strict => (
    is          => 'rwp',
    isa         => Bool,
    default     => sub { 0 },
);

sub set_strict { shift->_set__strict(1) }
sub unset_strict { shift->_set__strict(0) }

=attr _uniq

Used for internal collision detection.

=cut

has _uniq       => (is => 'ro', isa => HashRef[Str], default => sub { {} });

=attr _path_count

Used internally for computing numeric tag indexes (like in C</p[3]>).

=cut

has _path_count => (is => 'ro', isa => HashRef[Str], default => sub { {} });

=method eof

Overrides L<HTML::TreeBuilder> C<eof>.

=cut

after eof => sub {
    my ($self) = @_;

    $self->deparse($self, []);

    if ($self->_shrink) {
        my %short;
        for my $elem ($self->as_list) {
            my @rpath = reverse $elem->as_xpath;
            my $i = 0;
            unless ($self->_strict) {
                for (; $i <= $#rpath; $i++) {
                    last if $elem->path->[-1 - $i]->is_groupable;
                }
            }
            for my $j ($i .. $#rpath) {
                my $key = sha256(join '' => @rpath[0 .. $j]);
                $short{$key}{offset} = $#rpath - $j;
                push @{$short{$key}{elem}}, $elem;
                ++$short{$key}{accumulator}{$elem->as_xpath};
            }
        }

        for my $key (sort { $short{$b}{offset} <=> $short{$a}{offset} } keys %short) {
            next if 1 < keys %{$short{$key}{accumulator}};
            for my $elem (@{$short{$key}{elem}}) {
                next if $elem->trim_at;
                $elem->trim_at($short{$key}{offset});
            }
        }
    }
};

=method add_element

Add an element to the list.

=cut

sub add_element {
    my ($self, $elem) = @_;

    $elem->index($self->_path_count->{join ',', $elem->path}++);
    $elem->index_map($self->_uniq);

    $self->_add_element($elem);
}

=method deparse($node, $path)

Recursively scan underlying L<HTML::TreeBuilder> structure.

=cut

sub deparse {
    my ($self, $node, $path) = @_;

    my $level = HTML::Linear::Path->new({
        address     => $node->address,
        attributes  => {
            map {
                m{^[_/]}x
                    ? ()
                    : (lc, $node->attr($_))
            } $node->all_attr_names
        },
        strict      => $self->_strict,
        tag         => $node->tag,
    });

    my $flag = 0;
    $flag = 1 if not $node->content_list;
    $flag = 1 if $node->content_list and (ref(($node->content_list)[0]) ne '');
    $self->add_element(
        HTML::Linear::Element->new({
            depth   => $node->depth,
            path    => [ @{$path}, $level ],
            strict  => $self->_strict,
        })
    ) if $flag;

    my (%uniq, %uniq_strict, %is_groupable);
    for my $child ($node->content_list) {
        if (ref $child) {
            my $l = $self->deparse($child, [ @{$path}, $level ]);
            push @{$uniq{$l->as_xpath}}, $l->address;
            push @{$uniq_strict{$l->as_xpath(1)}}, $l->address;
            $is_groupable{$l->address} = $l->is_groupable;
        } else {
            $self->add_element(
                HTML::Linear::Element->new({
                    content => $child,
                    depth   => $node->depth,
                    path    => [ @{$path}, $level ],
                    strict  => $self->_strict,
                })
            );
        }
    }

    my %count;
    while (my ($xpath, $address) = each %uniq_strict) {
        my $i = 1;
        for my $addr (@{$address}) {
            $count{$addr} = $i;
        } continue {
            ++$i;
        }
    }

    while (my ($xpath, $address) = each %uniq) {
        if (
            grep { $count{$_} > 1 } @{$address}
            #or ($self->_strict and $self->_shrink)  # less verbose; unstable
            or $self->_shrink                       # verbose; stable
        ) {
            my $i = 1;
            for my $addr (@{$address}) {
                $self->_uniq->{$addr} =
                    HTML::Linear::Path::_wrap(array     => '[')
                    . HTML::Linear::Path::_wrap(number  => $is_groupable{$addr} ? $i : $count{$addr})
                    . HTML::Linear::Path::_wrap(array   => ']');
            } continue {
                ++$i;
            }
        }
    }

    return $level;
}

1;
