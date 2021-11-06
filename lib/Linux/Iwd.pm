package Linux::Iwd;

##! This class provides known networks and adapters information.
##!
##!     use Linux::Iwd;
##!
##!     my $iwd = Linux::Iwd->new();

use strict;
use warnings;

use Moose;

use Linux::Iwd::DBus;
use Linux::Iwd::KnownNetwork;
use Linux::Iwd::Adapter;

our $VERSION = '0.02';

### #[ignore(item)]
### `Linux::Iwd::DBus` object for quering the systemd DBus.
has 'DBus' => (
    is       => 'ro',
    isa      => 'Linux::Iwd::DBus',
    lazy     => 1,
    builder  => '_build_DBus',
    init_arg => undef,
);

### List of (available, active) adapters
### [Linux::Iwd::Adapter](Iwd/Adapter.html).
### The list is accessible via native Moose array traits with lower case
### attribute suffix (e.g. `all_adapters`).
has 'Adapters' => (
    is       => 'ro',
    isa      => 'ArrayRef[Linux::Iwd::Adapter]',
    lazy     => 1,
    builder  => '_build_Adapters',
    init_arg => undef,
    traits   => ['Array'],
    handles  => {
        count_adapters  => 'count',
        has_no_adapters => 'is_empty',
        all_adapters    => 'elements',
        get_adapter     => 'get',
        find_adapter    => 'first',
        map_adapters    => 'map',
        sort_adapters   => 'sort',
    },
);

### List of known (configured) networks
### [Linux::Iwd::KnownNetwork](Iwd/KnownNetwork.html)
### The list is accessible via native Moose array traits with lower case
### attribute suffix (e.g. `all_known_attributes`).
has 'KnownNetworks' => (
    is       => 'ro',
    isa      => 'ArrayRef[Linux::Iwd::KnownNetwork]',
    lazy     => 1,
    builder  => '_build_KnownNetworks',
    init_arg => undef,
    traits   => ['Array'],
    handles  => {
        count_known_networks  => 'count',
        has_no_known_networks => 'is_empty',
        all_known_networks    => 'elements',
        get_known_network     => 'get',
        find_known_network    => 'first',
        map_known_networks    => 'map',
        sort_known_networks   => 'sort',
    },
);

sub _build_DBus {
    my $self = shift;

    return Linux::Iwd::DBus->new();
}

sub _build_Adapters {
    my $self = shift;

    my $objects = $self->DBus->objects;

    my @adapters = ();
    foreach my $path ( keys %{$objects} ) {
        next if ( $path !~ m{/net/connman/iwd/\d+$}x );

        push @adapters,
          Linux::Iwd::Adapter->new( DBus => $self->DBus, Path => $path );
    }

    return \@adapters;
}

sub _build_KnownNetworks {
    my $self = shift;

    my $objects = $self->DBus->objects;

    my @known_networks = ();
    foreach my $path ( keys %{$objects} ) {
        next if ( $path !~ m{/net/connman/iwd/\w+_(?:open|psk|8021x)$}x );

         push @known_networks,
          Linux::Iwd::KnownNetwork->new( DBus => $self->DBus, Path => $path );
    }

    return \@known_networks;
}

__PACKAGE__->meta->make_immutable;

1;
