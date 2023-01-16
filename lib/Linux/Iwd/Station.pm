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
##!   * ConnectedNetwork
##!   * Scanning
##!   * State

use strict;
use warnings;

use Moose;
with 'Linux::Iwd::Base';

use Linux::Iwd::Station::Diagnostic;
use Linux::Iwd::Network;

##! Current diagnostic information of the station [Linux::Iwd::Station::Diagnostic](Station/Diagnostic.html).
has 'Diagnostic' => (
    is       => 'ro',
    isa      => 'Linux::Iwd::Station::Diagnostic',
    lazy     => 1,
    builder  => '_build_Diagnostic',
    init_arg => undef,
);

##! Current connected network [Linux::Iwd::Network](Network.html).
has 'ConnectedNetwork' => (
    is       => 'ro',
    isa      => 'Linux::Iwd::Network',
    lazy     => 1,
    builder  => '_build_ConnectedNetwork',
    init_arg => undef,
);


sub _build_Service {
    my $self = shift;

    return 'net.connman.iwd.Station';
}

sub _build_Diagnostic {
    my $self = shift;

    return Linux::Iwd::Station::Diagnostic->new( DBus => $self->DBus, Path => $self->Path );
}

sub _build_ConnectedNetwork {
    my $self = shift;

    return Linux::Iwd::Network->new( DBus => $self->DBus, Path => $self->get('ConnectedNetwork') );
}

__PACKAGE__->meta->make_immutable;

1;
