use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
    'ABSTRACT'   => "Poor man's iwd Perl API.",
    'AUTHOR'     => 'Tobias Schaefer <github@blackox.org>',
    'DISTNAME'   => 'Linux-Iwd',
    'EXE_FILES'  => ['bin/iwstatus'],
    'META_MERGE' => {
        resources => {
            'license'    => 'http://dev.perl.org/licenses',
            'homepage'   => 'https://github.com/tschaefer/linux-iwd',
            'repository' => 'https://github.com/tschaefer/linux-iwd.git',
        }
    },
    'NAME'      => 'Linux::Iwd',
    'PREREQ_PM' => {
        'Moose'           => '2.2010',
        'Net::DBus'       => '1.1.0',
        'Term::ANSIColor' => '4.06',
        'Throw'           => '0.13',
        'File::Which'     => '1.27',
        'IPC::Run'        => '20200505.0',
        'Path::Tiny'      => '0.120',
        'Readonly'        => '2.05',
        'Term::ReadKey'   => '2.38',
        'Text::Table'     => '1.134',
        'Try::Tiny'       => '0.30',
    },
    'VERSION_FROM' => 'lib/Linux/Iwd.pm',
    'clean'        => { FILES    => 'Linux-Iwd-*' },
    'dist'         => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    ( $ExtUtils::MakeMaker::VERSION >= 6.3002 ? ( 'LICENSE' => 'perl', ) : () ),
);

