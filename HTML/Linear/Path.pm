package HTML::Linear::Path;
use common::sense;

use JSON::XS;
use Moose;

has json        => (
    is          => 'ro',
    isa         => 'JSON::XS',
    default     => sub { JSON::XS->new->ascii->canonical },
    lazy        => 1,
);

has address     => (is => 'rw', isa => 'Str', required => 1);
has attributes  => (is => 'ro', isa => 'HashRef[Str]', required => 1, auto_deref => 1);
has key         => (is => 'rw', isa => 'Str', default => '');
has tag         => (is => 'ro', isa => 'Str', required => 1);

use overload '""' => \&as_string, fallback => 1;

sub as_string {
    my ($self) = @_;
    return $self->key if $self->key;

    my $ref = {
        _tag    => $self->tag,
        addr    => $self->address,
    };
    $ref->{attr} = $self->attributes if keys $self->attributes;

    return $self->key($self->json->encode($ref));
}

sub as_xpath {
    my ($self) = @_;

    my $xpath = $self->tag;

    if (keys $self->attributes) {
        $xpath .= '[';
        $xpath .=
            join ' and ',
            map { "\@${_}=" . _quote($self->attributes->{$_}) }
            sort keys $self->attributes;
        $xpath .= ']';
    }

    return $xpath;
}

sub _quote {
    local $_ = $_[0];
    s/\\/\\\\/g;
    s/'/\\'/g;
    "'$_'";
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
