package Linux::Iwd::KnownNetwork;

##! This class provides known network information and implements role
##! [Linux::Iwd::Base](Base.html).
##!
##!     use Linux::Iwd::KnownNetwork;
##!     use Linux::Iwd::DBus;
##!
##!     my $dbus = Linux::Iwd::DBus->new();
##!     my $known_network =
##!       Linux::Iwd::KnownNetwork->new('DBus' => $dbus, '/0/2/6d657368696f_psk');
##!
##! The Data attribute contains following items.
##!
##!   * Hidden
##!   * LastConnectedTime
##!   * Type

use strict;
use warnings;

use Modern::Perl '2018';

use Moose;
with 'Linux::Iwd::Base';

sub _build_Service {
    my $self = shift;

    return 'net.connman.iwd.KnownNetwork';
}

__PACKAGE__->meta->make_immutable;

1;
