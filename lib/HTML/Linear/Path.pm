package HTML::Linear::Path;
# ABSTRACT: represent paths inside HTML::Tree
use strict;
use common::sense;

use JSON::XS;
use Any::Moose;

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
    isa         => 'JSON::XS',
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

Strict mode disables grouping by C<id>, C<class> or C<name> attributes.

=attr tag

Tag name.

=cut

has address     => (is => 'rw', isa => 'Str', required => 1);
has attributes  => (is => 'ro', isa => 'HashRef[Str]', required => 1, auto_deref => 1);
has key         => (is => 'rw', isa => 'Str', default => '');
has strict      => (is => 'ro', isa => 'Bool', default => 0);
has tag         => (is => 'ro', isa => 'Str', required => 1);

use overload '""' => \&as_string, fallback => 1;

our %xpath_wrap = (
    array       => ['' => ''],
    attribute   => ['' => ''],
    equal       => ['' => ''],
    number      => ['' => ''],
    separator   => ['' => ''],
    sigil       => ['' => ''],
    tag         => ['' => ''],
    value       => ['' => ''],
);

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
    my ($self) = @_;

    my $xpath = _wrap(separator => '/') . _wrap(tag => $self->tag);

    unless ($self->strict) {
        for (qw(id class name)) {
            if ($self->attributes->{$_}) {
                $xpath .= _wrap(array       => '[');
                $xpath .= _wrap(sigil       => '@');
                $xpath .= _wrap(attribute   => $_);
                $xpath .= _wrap(equal       => '=');
                $xpath .= _wrap(value       => _quote($self->attributes->{$_}));
                $xpath .= _wrap(array       => ']');

                last;
            }
        }
    }

    return $xpath;
}

=func _quote

Quote attribute values for XPath representation.

=cut

sub _quote {
    local $_ = $_[0];

    s/\\/\\\\/gs;
    s/'/\\'/gs;
    s/\s+/ /gs;
    s/^\s//s;
    s/\s$//s;

    return "'$_'";
}

=func _wrap

Help to make a fancy XPath.

=cut

sub _wrap {
    return
        $xpath_wrap{$_[0]}->[0]
        . $_[1]
        . $xpath_wrap{$_[0]}->[1];
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
