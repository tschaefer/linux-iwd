# linux-iwd

Poor man's iwd Perl API.

## Introduction

__linux-iwd__ gathers status information  of the iNet wireless daemon (iwd)
via DBus.

* Adapters
* Devices
* Known networks
* Available networks

## Installation

Best way is to use the cpanm tool.

    $ perl Makefile.pl
    $ make dist
    $ VERSION=$(perl -le 'use lib "./lib"; require "./lib/Linux/Installer.pm"; print $Linux::Installer::VERSION')
    $ cpanm Linux-Iwd-$VERSION.tar.gz

### License

http://dev.perl.org/licenses/

