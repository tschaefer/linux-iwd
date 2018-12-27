package Linux::Iwd::DBus;

use strict;
use warnings;

use Modern::Perl '2018';

use Moose;

use Net::DBus;

has 'bus' => (
    is       => 'ro',
    isa      => 'Net::DBus',
    lazy     => 1,
    builder  => '_build_bus',
    init_arg => undef,
);

has 'service' => (
    is       => 'ro',
    isa      => 'Net::DBus::RemoteService',
    lazy     => 1,
    builder  => '_build_service',
    init_arg => undef,
);

has 'objects' => (
    is       => 'ro',
    isa      => 'HashRef',
    lazy     => 1,
    builder  => '_build_objects',
    init_arg => undef,
);

sub _build_bus {
    my $self = shift;

    return Net::DBus->system();
}

sub _build_service {
    my $self = shift;

    return $self->bus->get_service('net.connman.iwd');
}

sub _build_objects {
    my $self = shift;

    my $manager =
      $self->service->get_object( '/', 'org.freedesktop.DBus.ObjectManager' );
    return \%{ $manager->GetManagedObjects };
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=encoding utf8

=head1 NAME

Linux::Iwd::DBus - Provides Iwd DBus accesses.

=head1 DESCRIPTION

This module provides common methods and attributes to communicate with the Iwd
DBus Interface.

=head1 ATTRIBUTES

=head2 bus

DBus connection.

=head2 service

DBus Iwd Service connection I<net.connman.iwd>.

=head2 objects

All DBus Iwd objects gathered from DBus interface
I<org.freedesktop.DBus.ObjectManager>.

=head1 METHODS

None.

=head1 AUTHORS

Tobias Schäfer L<github@blackox.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2018 by Tobias Schäfer.

This is free software; you can redistribute it and/or modify it under the same
terms as the Perl 5 programming language system itself.

=cut
