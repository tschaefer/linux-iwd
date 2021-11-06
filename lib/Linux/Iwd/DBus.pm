package Linux::Iwd::DBus;

##! This role provides common methods and attributes to communicate with the
##! Iwd DBus Interface.

use strict;
use warnings;

use Moose;

use Net::DBus;

### DBus connection.
has 'bus' => (
    is       => 'ro',
    isa      => 'Net::DBus',
    lazy     => 1,
    builder  => '_build_bus',
    init_arg => undef,
);

### DBus service `net.connman.iwd`.
has 'service' => (
    is       => 'ro',
    isa      => 'Net::DBus::RemoteService',
    lazy     => 1,
    builder  => '_build_service',
    init_arg => undef,
);

### DBus service managed objects.
has 'objects' => (
    is       => 'ro',
    isa      => 'HashRef',
    lazy     => 1,
    builder  => '_build_objects',
    init_arg => undef,
);

sub _build_bus {
    my $self = shift;

    return Net::DBus->system();
}

sub _build_service {
    my $self = shift;

    return $self->bus->get_service('net.connman.iwd');
}

sub _build_objects {
    my $self = shift;

    my $manager =
      $self->service->get_object( '/', 'org.freedesktop.DBus.ObjectManager' );
    return \%{ $manager->GetManagedObjects };
}

__PACKAGE__->meta->make_immutable;

1;
