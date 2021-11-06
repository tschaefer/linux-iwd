package Linux::Iwd::Network;

##! This class provides network information.
##!
##!     use Linux::Iwd::Network;
##!     use Linux::Iwd::DBus;
##!
##!     my $dbus    = Linux::Iwd::DBus->new();
##!     my $network =
##!       Linux::Iwd::Network->new('DBus' => $dbus, '/0/2/6d657368696f_psk');
##!
##! The Data attribute contains following items.
##!
##!   * Connected
##!   * Device
##!   * KnownNetwork

use strict;
use warnings;

use Moose;
with 'Linux::Iwd::Base';

sub _build_Service {
    my $self = shift;

    return 'net.connman.iwd.Network';
}

__PACKAGE__->meta->make_immutable;

1;
