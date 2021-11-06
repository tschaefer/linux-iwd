use Test::More tests => 36;
use Test::Moose::More;

use Net::DBus;

my $class = 'Linux::Iwd';

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
    if ( $_ =~ m{/net/connman/iwd/[0-9]+$}x ) {
        $path = $_;
        last;
    }
}

SKIP: {
    skip( "no net.connman.iwd.Network found.", 18 ) if ( !$path );

    my $obj = $class->new();

    validate_attribute(
        $class => 'DBus' => (
            is       => 'ro',
            lazy     => 1,
            builder  => '_build_DBus',
            init_arg => undef,
        )
    );

    ok( ref $obj->DBus eq 'Linux::Iwd::DBus',
        sprintf "%s's attribute DBus is a Linux::Iwd::DBus", $class );

    validate_attribute(
        $class => 'Adapters' => (
            is       => 'ro',
            lazy     => 1,
            builder  => '_build_Adapters',
            init_arg => undef,
        )
    );

    ok( ref $obj->Adapters eq 'ARRAY',
        sprintf "%s's attribute Adapters is a Array", $class );

    validate_attribute(
        $class => 'KnownNetworks' => (
            is       => 'ro',
            lazy     => 1,
            builder  => '_build_KnownNetworks',
            init_arg => undef,
        )
    );

    ok( ref $obj->KnownNetworks eq 'ARRAY',
        sprintf "%s's attribute KnownNetworks is a Array", $class );

}
