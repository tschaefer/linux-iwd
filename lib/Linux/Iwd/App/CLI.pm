package Linux::Iwd::App::CLI;

##! [Linux::Iwd](../../Iwd.html) command line application. Parse, validate
##! command line options and execute action.
##!
##!     use Linux::Iwd::App::CLI;
##!
##!     exit Linux::Iwd::App::CLI->run();
##!
##! ### Inheritance
##!     Linux::Iwd::App::CLI
##!       isa Linux::Iwd:App

use strict;
use warnings;

use Moose;
extends 'Linux::Iwd::App';

use File::Which;
use Getopt::Long;
use IPC::Run;
use List::Util qw(any);
use Path::Tiny;
use Scalar::Util;
use Text::Table;
use Term::ReadKey;
use Throw qw(throw);
use Try::Tiny;

no warnings 'uninitialized';

### #[ignore(item)]
### Action to execute.
has 'action' => (
    is       => 'ro',
    isa      => 'Maybe[Str]',
    lazy     => 1,
    builder  => '_build_action',
    init_arg => undef,
);

### #[ignore(item)]
### Command line options.
has 'options' => (
    is       => 'ro',
    isa      => 'HashRef',
    lazy     => 1,
    builder  => '_build_options',
    init_arg => undef,
);

### #[ignore(item)]
### Action arguments.
has '+arguments' => (
    default  => sub { return \@ARGV || []; },
    init_arg => undef,
);

### Parse and validate command line action.
### Croak if action is unknown.
sub _build_action {
    my $self = shift;

    my $action = shift @ARGV;
    return if ( !$action );

    $action =~ s/-/_/g;

    throw( ( sprintf "No such action: '%s'", $action ), { trace => 3 } )
      if ( !any { $_ eq $action } @Linux::Iwd::App::ACTIONS );

    return $action;
}

### Parse and validate command line options.
### Croak on option error.
sub _build_options {
    my $self = shift;

    local $SIG{__WARN__} = \&Throw::throw;

    my %options;
    my $parser = Getopt::Long::Parser->new( config => ['require_order'] );
    $parser->getoptions(
        "help|h"    => \$options{'help'},
        "man|m"     => \$options{'man'},
        "version|v" => \$options{'version'},
        "no-legend" => \$options{'no_legend'},
        "no-pager"  => \$options{'no_pager'},
    );

    foreach my $key ( keys %options ) {
        delete $options{$key} if ( !$options{$key} );
    }

    my $count = keys %options;

    throw( 'Too many options.', { trace => 3 } )
      if ( ( $options{'help'} || $options{'man'} || $options{'version'} )
        && $count > 1 );

    return \%options;
}

### Stringify action `Text::Table` output.
sub _prepare_output {
    my ( $self, $table, $num_entries ) = @_;

    my $length = length $table->title;

    my $output;
    $output .= $table->title . '—' x $length . "\n"
      if ( !$self->options->{'no_legend'} );

    $output .= $table->body;

    $output .= "\n" . $num_entries . " entries listed.\n"
      if ( !$self->options->{'no_legend'} );

    return $output;
}

### Print action output. Use pager if terminal size too small.
sub _print_output {
    my ( $self, $output ) = @_;

    my ( $width, $height ) = GetTerminalSize();
    my $num = scalar split "\n", $output;

    my $pager = $ENV{'PAGER'};
    if ( !$pager || !File::Which::which($pager) ) {
        for (qw(less more)) {
            $pager = File::Which::which($_);
            last if ($pager);
        }
    }

    if (   $self->options->{'no_pager'}
        || !$pager
        || ( $height > $num ) )
    {
        print $output;
    }
    else {
        my $tmpfile = Path::Tiny::tempfile();
        $tmpfile->spew($output);
        IPC::Run::run( [ 'sh', '-c', $pager . ' < ' . $tmpfile->stringify ] );
    }

    return;
}

### Parse command line arguments, print to stderr on failure.
sub _parse {
    my $self = shift;

    my $rc = try {
        $self->options;
        $self->action;
        $self->arguments;

        return 1;
    }
    catch {
        my $exception = shift;

        $exception->{error} =~ s/[\n\r]//g;

        printf {*STDERR} "%s\n\n", $exception->{error};

        $self->usage();

        return 0;
    };
    return $rc if ( !$rc );

    if ( !scalar keys %{ $self->options } && !$self->action ) {
        print {*STDERR} "Missing action\n\n";

        $self->usage();

        $rc = 0;
    }

    return $rc;
}

### Execute action and output results.
around ['_adapters', '_devices', '_networks', '_known_networks'] => sub {
    my ( $orig, $self, @args ) = @_;

    my $data = $self->$orig(@args);

    my @headers = @{ $data->{'header'} };
    @headers = map {
            $_ =~ s{[A-Z][a-z]*+(?!\W)\K}{ }gx;
            uc $_;
    } @headers;
    my $table = Text::Table->new(@headers);

    foreach my $entries ( @{ $data->{'entries'} } ) {
        my @body;

        foreach my $key ( @{ $data->{'header'} } ) {
            push @body, $entries->{$key};
        }

        $table->load( \@body );
    }

    my $num = scalar @{ $data->{'entries'} };

    my $output = $self->_prepare_output( $table, $num );
    $self->_print_output($output);

    return 1;
};

around '_diagnostics' => sub {
    my ( $orig, $self, @args ) = @_;

    $self->options->{'no_legend'} = 1;

    my $data = $self->$orig(@args);

    my $table = Text::Table->new;
    foreach my $entries ( @{ $data->{'entries'} } ) {
        $table->add( sprintf "%+12s: %s", $entries->{'Property'}, $entries->{'Value'} );
    }

    my $output = $self->_prepare_output( $table, 0 );
    $self->_print_output($output);

    return 1;
};

### #[ignore(item)]
### Print help.
around 'help' => sub {
    my ( $orig, $self ) = @_;

    my $tempfile = $self->$orig();
    print <$tempfile>;

    return 1;
};

### #[ignore(item)]
### Open manpage in pager.
around 'man' => sub {
    my ( $orig, $self ) = @_;

    my $tempfile = $self->$orig();

    my $pager = $ENV{'PAGER'};
    if ( !$pager || !File::Which::which($pager) ) {
        for (qw(less more)) {
            $pager = File::Which::which($_);
            last if ($pager);
        }
    }

    IPC::Run::run( [ $pager, $tempfile->filename ] );

    return 1;
};

### #[ignore(item)]
### Print usage to stderr.
around 'usage' => sub {
    my ( $orig, $self ) = @_;

    my $tempfile = $self->$orig();
    print {*STDERR} <$tempfile>;

    return 1;
};

### #[ignore(item)]
### Print `Linux::Iwd` version.
around 'version' => sub {
    my ( $orig, $self ) = @_;

    printf "%s\n", $self->$orig();

    return 1;
};

### Run `Linux::Iwd` command line application. Options and action  arguments
### are used from command line.
around 'run' => sub {
    my ( $orig, $self ) = @_;

    $self = Linux::Iwd::App::CLI->new()
      if ( !Scalar::Util::blessed($self) );

    return 1 if ( !$self->_parse() );

    $self->help()    && return 0 if ( $self->options->{'help'} );
    $self->man()     && return 0 if ( $self->options->{'man'} );
    $self->version() && return 0 if ( $self->options->{'version'} );

    my $action = '_' . $self->action;

    my $rc = try {
        $self->$action( @{ $self->arguments } );
    }
    catch {
        my $exception = shift;

        printf {*STDERR} "%s\n", $exception->{error};

        $self->usage();

        return 0;
    };

    return $rc;
};

__PACKAGE__->meta->make_immutable;

1;
