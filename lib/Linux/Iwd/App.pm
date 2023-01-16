package Linux::Iwd::App;

##! [Linux::Iwd](../Iwd.html) application.
##!
##!     use Linux::Iwd::App;
##!
##!     my $app = Linux::Iwd::App->new();
##!     $app->run('adapters');

use strict;
use warnings;

use Moose;

use Moose::Util::TypeConstraints;

use File::Temp qw( :seekable );
use Pod::Usage;
use Readonly;
use Throw qw(throw);

Readonly::Array our @ACTIONS => qw(adapters devices networks known_networks diagnostics);

use Linux::Iwd;

no warnings 'uninitialized';

### Action to execute [required].
has 'action' => (
    is  => 'ro',
    isa => enum( \@ACTIONS ),
);

### Action arguments [optional].
has 'arguments' => (
    is      => 'ro',
    isa     => 'Maybe[ArrayRef]',
    lazy    => 1,
    default => sub { return []; },
);

### #[ignore(item)]
### Linux::Iwd object.
has 'controller' => (
    is       => 'ro',
    isa      => 'Linux::Iwd',
    lazy     => 1,
    builder  => '_build_controller',
    init_arg => undef,
);

### Create Linux::Iwd object.
sub _build_controller {
    my $self = shift;

    return Linux::Iwd->new();
}

### Return list of existing adapters.
sub _adapters {
    my $self = shift;

    my @adapters;
    foreach ( $self->controller->all_adapters ) {
        my ( $name, $powered, $vendor ) =
          $_->get( 'Name', 'Powered', 'Vendor' );

        push @adapters,
          {
            Name    => $name,
            Powered => $powered ? 'yes' : 'no',
            Vendor  => $vendor
          };
    }

    return { header => [qw(Name Powered Vendor)], entries => \@adapters };
}

### Return list of existing devices.
sub _devices {
    my $self = shift;

    my @devices;
    foreach ( $self->controller->all_adapters ) {
        my ( $name, $powered, $address, $mode ) =
          $_->Device->get( 'Name', 'Powered', 'Address', 'Mode' );

        my $state = $_->Device->Mode->Data->{'State'};

        push @devices,
          {
            Name    => $name,
            Powered => $powered ? 'yes' : 'no',
            Address => $address,
            Mode    => ucfirst $mode,
            State   => $state,
          };
    }

    return {
        header  => [qw(Name Powered Vendor Address Mode State)],
        entries => \@devices
    };
}

### Return list of available networks by device.
sub _networks {
    my ( $self, $device ) = @_;

    throw( 'Missing device name', { trace => 3 } ) if ( !$device );

    my $data = { header => [qw(Name Connected Type KnownNetwork)], };

    my $adapter = $self->controller->find_adapter(
        sub {
            $device eq ( $_->Device->get('Name') );
        }
    );
    return $data if ( !$adapter );

    my @networks;
    foreach ( $adapter->Device->all_networks ) {
        my ( $nname, $connected, $type, $known ) =
          $_->get( 'Name', 'Connected', 'Type', 'KnownNetwork' );

        push @networks,
          {
            Name         => $nname,
            Connected    => $connected ? 'yes' : 'no',
            Type         => $type,
            KnownNetwork => $known ? 'yes' : 'no'
          };
    }

    $data->{entries} = \@networks;

    return $data;
}

### Return list of known networks.
sub _known_networks {
    my $self = shift;

    my @known_networks;
    foreach ( $self->controller->all_known_networks ) {
        my ( $name, $type, $last_connected ) =
          $_->get( 'Name', 'Type', 'LastConnectedTime' );

        push @known_networks,
            {
              Name              => $name,
              Type              => $type,
              LastConnectedTime => $last_connected,
            };
    }

    return {
        header  => [qw(Name Type LastConnectedTime)],
        entries => \@known_networks,
    };

}

### Return diagnostic info by device.
sub _diagnostics {
    my ( $self, $device ) = @_;

    throw( 'Missing device name', { trace => 3 } ) if ( !$device );

    my $adapter = $self->controller->find_adapter(
        sub {
            $device eq ( $_->Device->get('Name') );
        }
    );
    return {} if ( !$adapter );
    return {} if ( $adapter->Device->Mode eq 'ad-hoc' );

    my @diag;
    while ( my ( $key, $value ) = each %{ $adapter->Device->Mode->Diagnostic->Data } ) {
        push @diag, { Property => $key, Value => $value };
    }

    return { header  => ['Property', 'Value'], entries => \@diag };
}


### Return help message as temporary filehandle.
sub help {
    my $self = shift;

    my $tempfile = File::Temp->new();

    pod2usage(
        -exitval  => 'NOEXIT',
        -verbose  => 99,
        -input    => __FILE__,
        -sections => 'SYNOPSIS|OPTIONS|PARAMETERS',
        -output   => $tempfile,
    );

    $tempfile->seek( 0, SEEK_SET );

    return $tempfile;
}

### Return manpage as temporary filehandle.
sub man {
    my $self = shift;

    my $tempfile = File::Temp->new();

    pod2usage(
        -exitval => 'NOEXIT',
        -verbose => 2,
        -input   => __FILE__,
        -output  => $tempfile,
    );

    $tempfile->seek( 0, SEEK_SET );

    return $tempfile;
}

### Return usage message as temporary filehandle.
sub usage {
    my $self = shift;

    my $tempfile = File::Temp->new();

    pod2usage(
        -exitval => 'NOEXIT',
        -verbose => 0,
        -input   => __FILE__,
        -output  => $tempfile,
    );

    $tempfile->seek( 0, SEEK_SET );

    return $tempfile;
}

### Return Linux::Iwd version string.
sub version {
    my $self = shift;

    return sprintf "iwstatus %s", $Linux::Iwd::VERSION;
}

### Run `Linux::Iwd` application.
sub run {
    my ( $self, $action, @args ) = @_;

    $action //= $self->action;
    my $arguments = @args ? \@args : $self->arguments;

    $action = sprintf "_%s", $action;
    return $self->$action( @{$arguments} );
}

__PACKAGE__->meta->make_immutable;

1;

## no critic (Documentation)

__END__

=encoding utf8

=head1 NAME

iwstatus - Poor man's iwd status tool.

=head1 SYNOPSIS

iwstatus --help|-h --man|-m --version|-v

iwstatus [--no-legend] [--no-pager] adapters | devices | known-networks

iwstatus [--no-legend] [--no-pager] networks DEVICE

iwstatus [--no-pager] diagnostics DEVICE

=head1 OPTIONS

=head2 base

=over 8

=item --help|-h

Print short usage help.

=item --man|-m

Print extended usage help.

=item --version|-v

Print version string.

=back

=head2 action

=over 8

=item --no-legend

Do not print a legend (column headers and hints).

=item --no-pager

Do not pipe output into a pager.

=back

=head1 PARAMETERS

=over 8

=item devices

Show available devices.

=item adapters

Show available adapters.

=item networks DEVICE

Show available networks by device.

=item known-networks

Show all known networks.

=item diagnostics DEVICE

Show diagnostics by device.

=back

=head1 DESCRIPTION

iwstatus is a tool to gather status information of the iNet wireless daemon
(iwd).

For further information see L<https://iwd.wiki.kernel.org/>.

=head1 AUTHORS

Tobias Schäfer github@blackox.org

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2021 by Tobias Schäfer.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
