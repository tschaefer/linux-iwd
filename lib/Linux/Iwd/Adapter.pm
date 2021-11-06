package Linux::Iwd::Adapter;

##! This class provides adapter information and implements role
##! [Linux::Iwd::Base](Base.html).
##!
##!     use Linux::Iwd::Adapter;
##!     use Linux::Iwd::DBus;
##!
##!     my $dbus    = Linux::Iwd::DBus->new();
##!     my $adapter = Linux::Iwd::Adapter->new('DBus' => $dbus, '/0');
##!
##! The Data attribute contains following items.
##!
##!   * Model
##!   * Name
##!   * Powered
##!   * SupportedModes
##!   * Vendor

use strict;
use warnings;

use Moose;
with 'Linux::Iwd::Base';

use Linux::Iwd::Device;

### Device object [Linux::Iwd::Device](Device.html). WLAN device used by the
### adapter.
has 'Device' => (
    is       => 'ro',
    isa      => 'Linux::Iwd::Device',
    lazy     => 1,
    builder  => '_build_Device',
    init_arg => undef,
);

sub _build_Service {
    my $self = shift;

    return 'net.connman.iwd.Adapter';
}

sub _build_Device {
    my $self = shift;

    my $objects = $self->DBus->objects;
    my $root    = $self->Path;

    my $device;
    foreach my $path ( keys %{$objects} ) {
        next if ( $path !~ m{^$root\/\d+$}x );

        $device = Linux::Iwd::Device->new( DBus => $self->DBus, Path => $path );
        last;
    }

    return $device;
}

__PACKAGE__->meta->make_immutable;

1;
