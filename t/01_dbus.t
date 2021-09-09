use Test::More tests => 38;
use Test::Moose::More;

my $class = 'Linux::Iwd::DBus';

use_ok($class);
is_class_ok($class);
is_immutable_ok($class);
check_sugar_ok($class);

my $obj = $class->new();

my %attrs = (
    'bus'     => 'Net::DBus',
    'service' => 'Net::DBus::RemoteService',
    'objects' => 'HASH',
);

while ( my ( $attr, $type ) = each %attrs ) {
    validate_attribute(
        $class => $attr => (
            is       => 'ro',
            lazy     => 1,
            builder  => '_build_' . $attr,
            init_arg => undef,
        )
    );

    ok(
        ref $obj->$attr eq $type,
        sprintf "Linux::Iwd::DBus's attribute %s is a %s",
        $attr, $type
    );
}

is( $obj->service->get_service_name,
    'net.connman.iwd',
    sprintf "%s attribute service is DBus Service 'net.connman.iwd", $class );

ok(
    exists $obj->objects->{'/net/connman/iwd'}
      ->{'net.connman.iwd.AgentManager'},
    sprintf "%s attribute objects has interface 'net.connman.iwd.AgentManager",
    $class
);
