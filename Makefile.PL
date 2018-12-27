use ExtUtils::MakeMaker;

WriteMakefile(
    'ABSTRACT'   => "Poor man's iwd Perl API.",
    'AUTHOR'     => 'Tobias Schaefer <github@blackox.org>',
    'DISTNAME'   => 'Linux-Iwd',
    'META_MERGE' => {
        resources => {
            'license'    => 'http://dev.perl.org/licenses',
            'homepage'   => 'https://github.com/tschaefer/linux-iwd',
            'repository' => 'https://github.com/tschaefer/linux-iwd',
        }
    },
    'NAME'      => 'Linux::Iwd',
    'PREREQ_PM' => {
        'Date::Parse'      => '2.30',
        'Modern::Perl'     => '1.20181021',
        'Moose'            => '2.2010',
        'Net::DBus'        => '1.1.0',
        'Term::ANSIColor'  => '4.06',
        'Throw'            => '0.13',
    },
    'VERSION_FROM' => 'lib/Linux/Iwd.pm',
    'clean'        => { FILES => 'Linux-Iwd-*' },
    'dist'         => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    ( $ExtUtils::MakeMaker::VERSION >= 6.3002 ? ( 'LICENSE' => 'perl', ) : () ),
);
