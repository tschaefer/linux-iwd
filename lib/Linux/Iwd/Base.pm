package Linux::Iwd::Base;

##! Provides a basic interface for common methods and attributes for all
##! [Linux::Iwd](../Iwd.html) subclasses.

use strict;
use warnings;

use Moose::Role;

requires '_build_Service';

use Throw qw(throw);

### An object of class [Linux::Lwd::DBus](DBus.html) to communicate [required].
has 'DBus' => (
    is       => 'ro',
    isa      => 'Linux::Iwd::DBus',
    required => 1,
);

### Appropriate DBus Interface name.
has 'Service' => (
    is       => 'ro',
    isa      => 'Str',
    lazy     => 1,
    builder  => '_build_Service',
    init_arg => undef,
);

### Specified DBus object information.
### The attribute is accessible via native Moose hash traits.
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

### Path to the relevant DBus object [required].
has 'Path' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

### #[ignore(item)]
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
