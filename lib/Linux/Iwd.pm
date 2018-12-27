package Linux::Iwd;

use strict;
use warnings;

use Modern::Perl '2018';

use Moose;

use Linux::Iwd::DBus;
use Linux::Iwd::KnownNetwork;
use Linux::Iwd::Adapter;

our $VERSION = '0.01';

has 'DBus' => (
    is       => 'ro',
    isa      => 'Linux::Iwd::DBus',
    lazy     => 1,
    builder  => '_build_DBus',
    init_arg => undef,
);

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

sub _build_KnownNetworks {
    my $self = shift;

    my $objects = $self->DBus->objects;

    my @known_networks = ();
    foreach my $path ( keys %{$objects} ) {
        next if ( $path !~ /^\/\w+_(?:open|psk|8021x)$/x );

        push @known_networks,
          Linux::Iwd::KnownNetwork->new( DBus => $self->DBus, Path => $path );
    }

    return \@known_networks;
}

sub _build_Adapters {
    my $self = shift;

    my $objects = $self->DBus->objects;

    my @adapters = ();
    foreach my $path ( keys %{$objects} ) {
        next if ( $path !~ /^\/\d+$/x );

        push @adapters,
          Linux::Iwd::Adapter->new( DBus => $self->DBus, Path => $path );
    }

    return \@adapters;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=encoding utf8

=head1 NAME

Linux::Iwd - Known networks and adapters information.

=head1 SYNOPSIS

    use Linux::Iwd;

    my $iwd = Linux::Iwd->new();

=head1 DESCRIPTION

This module provides a list of known - configured, already connected - networks
and available, active adapters.

=head1 ATTRIBUTES

=head2 KnownNetworks

List of Known (configured) networks (L<Linux::Iwd::KnownNetwork>).

=head2 Adapters

List of (avilable, active) adapters (L<Linux::Iwd::Adapter>).

=head1 METHODS

=head2 Array trait handles

Both lists handle Moose native array traits.

    Adapters
        count_adapters  => 'count',
        has_no_adapters => 'is_empty',
        all_adapters    => 'elements',
        get_adapter     => 'get',
        find_adapter    => 'first',
        map_adapters    => 'map',
        sort_adapters   => 'sort',

    KnownNetworks
        count_known_networks  => 'count',
        has_no_known_networks => 'is_empty',
        all_known_networks    => 'elements',
        get_known_network     => 'get',
        find_known_network    => 'first',
        map_known_networks    => 'map',
        sort_known_networks   => 'sort',

=head1 AUTHORS

Tobias Schäfer L<github@blackox.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2018 by Tobias Schäfer.

This is free software; you can redistribute it and/or modify it under the same
terms as the Perl 5 programming language system itself.

=cut
