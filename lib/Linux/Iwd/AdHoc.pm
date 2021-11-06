package Linux::Iwd::AdHoc;

##! This class provides ad-hoc mode information and implements role
##! [Linux::Iwd::Base](Base.html).
##!
##!     use Linux::Iwd::Device;
##!     use Linux::Iwd::DBus;
##!
##!     my $dbus   = Linux::Iwd::DBus->new();
##!     my $device =
##!       Linux::Iwd::Device->new('DBus' => $dbus, '/0/2');
##!     my $adhoc = $device->Mode;
##!     printf "Ad-hoc network is %s\n",
##!       $ap->get('Started') ? 'started' : 'not started';
##!
##! The Data attribute contains following items.
##!
##!   * ConnectedPeers
##!   * Started

use strict;
use warnings;

use Moose;
with 'Linux::Iwd::Base';

sub _build_Service {
    my $self = shift;

    return 'net.connman.iwd.AdHoc';
}


__PACKAGE__->meta->make_immutable;

1;
