package Linux::Iwd::Station::Diagnostic;

##! This class provides station mode diagnostic information.
##!
##!     use Linux::Iwd::Device;
##!     use Linux::Iwd::DBus;
##!
##!     my $dbus       = Linux::Iwd::DBus->new();
##!     my $diagnostic =
##!       Linux::Iwd::Station::Diagnostic->new('DBus' => $dbus, '/0/2');
##!     printf "Security is %s\n", $diagnostic->get('Security');
##!
##! The Data attribute contains following items.
##!
##!   * AverageRSSI
##!   * ConnectedBss
##!   * Frequency
##!   * RSSI
##!   * RxBitrate
##!   * RxMCS
##!   * RxMode
##!   * Security
##!   * TxBitrate
##!   * TxMCS
##!   * TxMode

use strict;
use warnings;

use Moose;
with 'Linux::Iwd::Base';

sub _build_Service {
    my $self = shift;

    return 'net.connman.iwd.StationDiagnostic';
}

sub _build_Data {
    my $self = shift;

    my $object = $self->DBus->service->get_object($self->Path, $self->Service);

    return $object->GetDiagnostics();
}

__PACKAGE__->meta->make_immutable;

1;
