package Linux::Iwd::Station;

use strict;
use warnings;

use Modern::Perl '2018';

use Moose;
with 'Linux::Iwd::Base';

has '+Service' => ( default => sub { return 'net.connman.iwd.Station' }, );

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=encoding utf8

=head1 NAME

Linux::Iwd::Station - Station information.

=head1 SYNOPSIS

    use Linux::Iwd::Device;
    use Linux::Iwd::DBus;

    my $dbus   = Linux::Iwd::DBus->new();
    my $device =
      Linux::Iwd::Device->new('DBus' => $dbus, '/0/2');
    my $station = $device->Mode;
    printf "State is %s\n", $ap->get('State');

=head1 DESCRIPTION

This module provides station information.

=head1 ATTRIBUTES

=head2 Data

Station status information.

=over 2

=item *

State

=item *

ConnectedNetwork

=item *

Scanning

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
