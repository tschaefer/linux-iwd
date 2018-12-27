package Linux::Iwd::Device;

use strict;
use warnings;

use Modern::Perl '2018';

use Moose;
with 'Linux::Iwd::Base';

use Linux::Iwd::Network;
use Linux::Iwd::AccessPoint;
use Linux::Iwd::AdHoc;
use Linux::Iwd::Station;

has '+Service' => ( default => sub { return 'net.connman.iwd.Device' }, );

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

has 'Mode' => (
    is       => 'ro',
    isa      => 'Linux::Iwd::Station|Linux::Iwd::AdHoc|Linux::Iwd::AccessPoint',
    lazy     => 1,
    builder  => '_build_Mode',
    init_arg => undef,
);

sub _build_Networks {
    my $self = shift;

    my $objects = $self->DBus->objects;
    my $root    = $self->Path;

    my @networks = ();
    foreach my $path ( keys %{$objects} ) {
        next if ( $path !~ /^$root\/\w+_(?:open|psk|8021x)$/x );

        push @networks,
          Linux::Iwd::Network->new( DBus => $self->DBus, Path => $path );
    }

    return \@networks;
}

sub _build_Mode {
    my $self = shift;

    my $mode;
    if ( $self->Data->{'Mode'} eq 'station' ) {
        $mode =
          Linux::Iwd::Station->new( DBus => $self->DBus, Path => $self->Path );
    }
    elsif ( $self->Data->{'Mode'} eq 'ap' ) {
        $mode = Linux::Iwd::AccessPoint->new(
            DBus => $self->DBus,
            Path => $self->Path
        );
    }
    elsif ( $self->Data->{'Mode'} eq 'ad-hoc' ) {
        $mode =
          Linux::Iwd::AdHoc->new( DBus => $self->DBus, Path => $self->Path );
    }

    return $mode;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=encoding utf8

=head1 NAME

Linux::Iwd::Device - Device information.

=head1 SYNOPSIS

    use Linux::Iwd::Device;
    use Linux::Iwd::DBus;

    my $dbus   = Linux::Iwd::DBus->new();
    my $device =
      Linux::Iwd::Device->new('DBus' => $dbus, '/0/2');

=head1 DESCRIPTION

This module provides device information.

=head1 ATTRIBUTES

=head2 Networks

List of discovered networks (L<Linux::Iwd::Network>).

=head2 Data

Device status information.

=over 2

=item *

Adapter

=item *

Address

=item *

Mode

=item *

Name

=item *

Powered

=item *

WDS

=back

=head2 Mode

Current device mode, one of L<Linux::Iwd::Station>, L<Linux::Iwd::AdHoc>,
L<Linux::Iwd::AccessPoint>.

=head1 METHODS

=head2 Data

Data handles Moose native hash traits, see L<Linux::Iwd::Base>.

=head1 AUTHORS

Tobias Schäfer L<github@blackox.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2018 by Tobias Schäfer.

This is free software; you can redistribute it and/or modify it under the same
terms as the Perl 5 programming language system itself.

=cut
