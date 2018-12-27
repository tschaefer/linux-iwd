package Linux::Iwd::Test;

use strict;
use warnings;

use Moose;
with 'Linux::Iwd::Base';

has '+Service' => ( default => sub { return 'net.connman.iwd.Test' }, );

__PACKAGE__->meta->make_immutable;

1;

package main;

use Test::More tests => 2;
use Test::Exception;

use Net::DBus;

use Linux::Iwd::DBus;

my $dbus    = Net::DBus->system();
my $service = $dbus->get_service('net.connman.iwd');
my $manager = $service->get_object( '/', 'org.freedesktop.DBus.ObjectManager' );
my %objects = %{ $manager->GetManagedObjects };

my $path;
foreach $_ ( keys %objects ) {
    if ( $_ =~ /^\/[0-9]+$/x ) {
        $path = $_;
        last;
    }
}

throws_ok {
    Linux::Iwd::Test->new( DBus => Linux::Iwd::DBus->new(), Path => '/9999' )
}
qr/Object not found: '\/9999'/;

SKIP: {
    skip( "no net.connman.iwd found.", 1 ) if ( !$path );

    throws_ok {
        Linux::Iwd::Test->new( DBus => Linux::Iwd::DBus->new(), Path => $path )
    }
    qr/Object \/0 is not type: 'net\.connman\.iwd\.Test'/;
}
