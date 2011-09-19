package HTML::Linear::Element;
use common::sense;

use Digest::SHA;
use Moose;

has [qw(left right)] => (is => 'rw', isa => 'Int', default => -1);
has content     => (is => 'rw', isa => 'Str', default => '');
has depth       => (is => 'ro', isa => 'Int', required => 1);
has index       => (is => 'rw', isa => 'Int', default => 0);
has key         => (is => 'rw', isa => 'Str', default => '');
has path        => (is => 'ro', isa => 'ArrayRef[HTML::Linear::Path]', required => 1, auto_deref => 1);
has sha         => (is => 'ro', isa => 'Digest::SHA', default => sub { new Digest::SHA(256) }, lazy => 1 );

use overload '""' => \&as_string, fallback => 1;

sub as_string {
    my ($self) = @_;
    return $self->key if $self->key;

    $self->sha->add($self->content);
    $self->sha->add($self->index);
    $self->sha->add(join ',', $self->path);

    return $self->key($self->sha->b64digest);
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
