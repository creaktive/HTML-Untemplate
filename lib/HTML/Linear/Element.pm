package HTML::Linear::Element;
# ABSTRACT: represent elements to populate HTML::Linear
use strict;
use common::sense;

use Digest::SHA;
use Any::Moose;

use HTML::Linear::Path;

# VERSION

=attr attributes

Element attributes.

=attr content

Element content.

=attr depth

Depth level of an element inside a L<HTML::TreeBuilder> structure.

=attr index

Index to preserve elements order.

=attr index_map

Used for internal collision detection.

=attr key

Stringified element representation.

=attr path

Store representations of paths inside C<HTML::TreeBuilder> structure (L<HTML::Linear::Path>).

=attr sha

Lazy L<Digest::SHA> (256-bit) representation.

=cut

has attributes  => (is => 'rw', isa => 'HashRef[Str]', default => sub { {} }, auto_deref => 1);
has content     => (is => 'rw', isa => 'Str', default => '');
has depth       => (is => 'ro', isa => 'Int', required => 1);
has index       => (is => 'rw', isa => 'Int', default => 0);
has index_map   => (is => 'rw', isa => 'HashRef[Str]', default => sub { {} }, auto_deref => 1);
has key         => (is => 'rw', isa => 'Str', default => '');
has path        => (is => 'ro', isa => 'ArrayRef[HTML::Linear::Path]', required => 1, auto_deref => 1);
has sha         => (is => 'ro', isa => 'Digest::SHA', default => sub { new Digest::SHA(256) }, lazy => 1 );

use overload '""' => \&as_string, fallback => 1;

=for Pod::Coverage
BUILD
=cut

sub BUILD {
    my ($self) = @_;
    $self->attributes({%{$self->path->[-1]->attributes}});
}

=method as_string

Stringified signature of an element.

=cut

sub as_string {
    my ($self) = @_;
    return $self->key if $self->key;

    $self->sha->add($self->content);
    $self->sha->add($self->index);
    $self->sha->add(join ',', $self->path);

    return $self->key($self->sha->b64digest);
}

=method as_xpath

Build a nice XPath representation of a path inside the L<HTML::TreeBuilder> structure.

=cut

sub as_xpath {
    my ($self) = @_;
    return
        join '',
            map {
                $_->as_xpath . ($self->index_map->{$_->address} // '')
            } $self->path;
}

=method as_hash

Linearize element as an associative array (Perl hash).

=cut

sub as_hash {
    my ($self) = @_;
    my $hash = {};
    my $xpath = $self->as_xpath . HTML::Linear::Path::_wrap(separator => '/');

    for my $key (sort keys %{$self->attributes}) {
        $hash->{
            $xpath
            . HTML::Linear::Path::_wrap(sigil       => '@')
            . HTML::Linear::Path::_wrap(attribute   => $key)
        } = $self->attributes->{$key}
            unless $self->attributes->{$key} =~ m{^\s*$}s;
    }

    $hash->{
        $xpath
        . HTML::Linear::Path::_wrap(attribute => 'text()')
    } = $self->content
        unless $self->content =~ m{^\s*$}s;

    return $hash;
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
