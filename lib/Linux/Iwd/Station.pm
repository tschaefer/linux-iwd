package Linux::Iwd::Station;

##! This class provides station mode information.
##!
##!     use Linux::Iwd::Device;
##!     use Linux::Iwd::DBus;
##!
##!     my $dbus   = Linux::Iwd::DBus->new();
##!     my $device =
##!       Linux::Iwd::Device->new('DBus' => $dbus, '/0/2');
##!     my $station = $device->Mode;
##!     printf "State is %s\n", $ap->get('State');
##!
##! The Data attribute contains following items.
##!
##!   * State
##!   * Scanning

use strict;
use warnings;

use Moose;
with 'Linux::Iwd::Base';

sub _build_Service {
    my $self = shift;

    return 'net.connman.iwd.Station';
}

__PACKAGE__->meta->make_immutable;

1;
