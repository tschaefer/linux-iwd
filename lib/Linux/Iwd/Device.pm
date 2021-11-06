package Linux::Iwd::Device;

##! This class provides device information and implements role
##! [Linux::Iwd::Base](Base.html).
##!
##!     use Linux::Iwd::Device;
##!     use Linux::Iwd::DBus;
##!
##!     my $dbus   = Linux::Iwd::DBus->new();
##!     my $device = Linux::Iwd::Adapter->new('DBus' => $dbus, '/0/2');
##!
##! The Data attribute contains following items.
##!
##!   * Adapter
##!   * Address
##!   * Mode
##!   * Name
##!   * Powered
##!   * WDS

use strict;
use warnings;

use Moose;
with 'Linux::Iwd::Base';

use Linux::Iwd::Network;
use Linux::Iwd::AccessPoint;
use Linux::Iwd::AdHoc;
use Linux::Iwd::Station;

### List of discovered networks [Linux::Iwd::Network](Network.html).
### The list is accessable via native Moose array traits with lower case
### attribute suffix (e.g. `all_known_attributes`).
has 'Networks' => (
    is       => 'ro',
    isa      => 'ArrayRef[Linux::Iwd::Network]',
    lazy     => 1,
    builder  => '_build_Networks',
    init_arg => undef,
    traits   => ['Array'],
    handles  => {
        count_networks  => 'count',
        has_no_networks => 'is_empty',
        all_networks    => 'elements',
        get_network     => 'get',
        find_network    => 'first',
        map_networks    => 'map',
        sort_networks   => 'sort',
    },
);

### Current device mode, one of [Linux::Iwd::Station](Station.html),
### [Linux::Iwd::AdHoc](AdHoc.html) or [Linux::Iwd::AccessPoint](AccessPoint).
has 'Mode' => (
    is       => 'ro',
    isa      => 'Linux::Iwd::Station|Linux::Iwd::AdHoc|Linux::Iwd::AccessPoint',
    lazy     => 1,
    builder  => '_build_Mode',
    init_arg => undef,
);

sub _build_Service {
    my $self = shift;

    return 'net.connman.iwd.Device';
}

sub _build_Networks {
    my $self = shift;

    my $objects = $self->DBus->objects;
    my $root    = $self->Path;

    my @networks = ();
    foreach my $path ( keys %{$objects} ) {
        next if ( $path !~ m{^$root\/\w+_(?:open|psk|8021x)$}x );

        push @networks,
          Linux::Iwd::Network->new( DBus => $self->DBus, Path => $path );
    }

    return \@networks;
}

sub _build_Mode {
    my $self = shift;

    my %mode_class = (
        'station' => 'Linux::Iwd::Station',
        'ap'      => 'Linux::Iwd::AccessPoint',
        'ad-hoc'  => 'Linux::Iwd::AdHoc',
    );

    my $class = $mode_class{$self->Data->{'Mode'}};

    return $class->new( DBus => $self->DBus, Path => $self->Path );
}

__PACKAGE__->meta->make_immutable;

1;
