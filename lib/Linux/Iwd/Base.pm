package Linux::Iwd::Base;

use strict;
use warnings;

use Modern::Perl '2018';

use Moose::Role;

use Throw qw(throw);

has 'DBus' => (
    is       => 'ro',
    isa      => 'Linux::Iwd::DBus',
    required => 1,
);

has 'Service' => (
    is       => 'ro',
    isa      => 'Str',
    init_arg => undef,
);

has 'Data' => (
    is       => 'ro',
    isa      => 'HashRef',
    lazy     => 1,
    builder  => '_build_Data',
    init_arg => undef,
    traits   => ['Hash'],
    handles  => {
        defined => 'defined',
        exists  => 'exists',
        get     => 'get',
        keys    => 'keys',
        kv      => 'kv',
        values  => 'values',
    },
);

has 'Path' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

sub BUILD {
    my $self = shift;

    my $objects = $self->DBus->objects;
    my $path    = $self->Path;

    throw( ( sprintf "Object not found: '%s'", $path ), { trace => 3 } )
      if ( !$objects->{$path} );
    throw( ( sprintf "Object %s is not type: '%s'", $path, $self->Service ),
        { trace => 3 } )
      if ( !$objects->{$path}->{ $self->Service } );

    return;
}

sub _build_Data {
    my $self = shift;

    return $self->DBus->objects->{ $self->Path }->{ $self->Service };
}

1;

__END__

=pod

=encoding utf8

=head1 NAME

Linux::Iwd::Base - Provides a basic interface for Iwd classes.

=head1 DESCRIPTION

This module provides common methods and attributes for mostly all Iwd classes.

=head1 ATTRIBUTES

=head2 DBus

An object of class Linux::Lwd::DBus to communicate [required].

=head2 Service

Appropriate DBus Interface name.

=head2 Path

Path to the relevant DBus object [required].

=head2 Data

Object information.

=head1 METHODS

=head2 Hash trait handles

The Data attribute is accessable via native Moose hash traits.

    defined => 'defined',
    exists  => 'exists',
    get     => 'get',
    keys    => 'keys',
    kv      => 'kv',
    values  => 'values',

=head1 AUTHORS

Tobias Schäfer L<github@blackox.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2018 by Tobias Schäfer.

This is free software; you can redistribute it and/or modify it under the same
terms as the Perl 5 programming language system itself.

=cut
