use Test::More tests => 31;
use Test::Moose::More;

use Data::Printer;

use Net::DBus;

my $class = 'Linux::Iwd::Station::Diagnostic';

use_ok($class);
is_class_ok($class);
is_immutable_ok($class);
check_sugar_ok($class);

my $dbus    = Net::DBus->system();
my $service = $dbus->get_service('net.connman.iwd');
my $manager = $service->get_object( '/', 'org.freedesktop.DBus.ObjectManager' );
my %objects = %{ $manager->GetManagedObjects };

my $path;
foreach $_ ( keys %objects ) {
    if ( $_ =~ m{/net/connman/iwd/[0-9]+/[0-9]+$}x ) {
        next if ( $objects{$_}{'net.connman.iwd.Device'}{Mode} ne 'station' );
        $path = $_;
        last;
    }
}

SKIP: {
    skip( "no net.connman.iwd.Station found.", 34 ) if ( !$path );

    use Linux::Iwd::DBus;
    my $obj = $class->new( DBus => Linux::Iwd::DBus->new(), Path => $path );

    validate_attribute(
        $class => 'DBus' => (
            is       => 'ro',
            required => 1,
        )
    );

    ok( ref $obj->DBus eq 'Linux::Iwd::DBus',
        sprintf "%s's attribute DBus is a Linux::Iwd::DBus", $class );

    validate_attribute(
        $class => 'Service' => (
            is       => 'ro',
            init_arg => undef,
        )
    );

    ok( ref $obj->Service eq undef,
        sprintf "%s's attribute Service is a scalar", $class );

    validate_attribute(
        $class => 'Data' => (
            is       => 'ro',
            lazy     => 1,
            builder  => '_build_Data',
            init_arg => undef,
        )
    );

    ok( ref $obj->Data eq 'HASH',
        sprintf "%s's attribute Data is a HASH", $class );

    is_deeply(
        [
            sort qw(
              AverageRSSI
              ConnectedBss
              Frequency
              RSSI
              RxBitrate
              RxMCS
              RxMode
              Security
              TxBitrate
              TxMCS
              TxMode
            )
        ],
        [ sort keys %{ $obj->Data } ],
        sprintf "%s's attribute Data got all keys",
        $class
    );
}
