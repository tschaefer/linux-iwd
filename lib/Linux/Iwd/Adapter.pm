package Linux::Iwd::Adapter;

use strict;
use warnings;

use Modern::Perl '2018';

use Moose;
with 'Linux::Iwd::Base';

use Linux::Iwd::Device;

has '+Service' => ( default => sub { return 'net.connman.iwd.Adapter' }, );

has 'Device' => (
    is         => 'ro',
    isa        => 'Maybe[Linux::Iwd::Device]',
    lazy_build => 1,
    init_arg   => undef,
);

sub _build_Device {
    my $self = shift;

    my $objects = $self->DBus->objects;
    my $root    = $self->Path;

    my $device;
    foreach my $path ( keys %{$objects} ) {
        next if ( $path !~ /^$root\/\d+$/x );

        $device = Linux::Iwd::Device->new( DBus => $self->DBus, Path => $path );
        last;
    }

    return $device;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=encoding utf8

=head1 NAME

Linux::Iwd::Adapter - Adapter information.

=head1 SYNOPSIS

    use Linux::Iwd::Adapter;
    use Linux::Iwd::DBus;

    my $dbus    = Linux::Iwd::DBus->new();
    my $adapter =
      Linux::Iwd::Adapter->new('DBus' => $dbus, '/0');

=head1 DESCRIPTION

This module provides adapter information.

=head1 ATTRIBUTES

=head2 Device

Device object (L<Linux::Iwd::Device>).

=head2 Data

Adapter status information.

=over 2

=item *

Model

=item *

Name

=item *

Powered

=item *

SupportedModes

=item *

Vendor

=back

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
