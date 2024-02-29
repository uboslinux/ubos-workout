#!/usr/bin/perl
#
# Runs workout-mysql1
#
# Copyright (C) 2014 and later, Indie Computing Corp. All rights reserved. License: see package.
#

use strict;
use warnings;

package WorkoutMysql1Test1;

use UBOS::Logging;
use UBOS::Utils;
use UBOS::WebAppTest;
# The states and transitions for this test


my $TEST = new UBOS::WebAppTest(
    appToTest   => 'workout-mysql1',
    description => 'Tests MySQL database initialization and upgrade.',

    packageDbsToAdd => {
        'toyapps' => 'https://depot.ubosfiles.net/$channel/$arch/toyapps'
    },

    checks      => [
            new UBOS::WebAppTest::StateCheck(
                    name  => 'virgin',
                    check => sub {
                        my $c      = shift;
                        my $dbFile = $c->apache2ContextDir() .  '/db';

                        my $scaffold = $c->getScaffold();

                        my $out;
                        my $err;
                        my $cmd = <<CMD;
use strict;
use warnings;
use UBOS::Utils;
use UBOS::Databases::MySqlDriver;

my \$dbFileContent = UBOS::Utils::slurpFile( '$dbFile' );
CMD
                        $cmd .= <<'CMD';
unless( $dbFileContent ) {
    print STDERR "Cannot continue, dbFile not here\n";
    exit 1;
}
my( $dbHost, $dbPort, $dbName, $dbUserLid, $dbUserLidCredential );
unless( eval $dbFileContent ) {
    print STDERR "Eval failed: $!\n";
    exit 1;
}

my $dbh = UBOS::Databases::MySqlDriver::dbConnect( $dbName, $dbUserLid, $dbUserLidCredential, 'test connect', $dbHost, $dbPort );
my $sth = UBOS::Databases::MySqlDriver::sqlPrepareExecute( $dbh, <<SQL );
SELECT * FROM `happenings` ORDER BY `ts`;
SQL

my %events = ();
my $exit = 0;
while( my $ref = $sth->fetchrow_hashref() ) {
    my $event = $ref->{event};
    if( exists( $events{$event} )) {
        ++$events{$event};
    } else {
        $events{$event} = 1;
    }
}

# There can be two events (create and install) plus any number of upgrade events
if( exists( $events{'create.sql'} )) {
    unless( $events{'create.sql'} == 1 ) {
        print STDERR "Too many create events: " . $events{'create.sql'} . "\n";
        $exit = 1;
    }
} else {
    print STDERR "No create event\n";
    $exit = 1;
}
if( exists( $events{'install.sql'} )) {
    unless( $events{'install.sql'} == 1 ) {
        print STDERR "Too many install events: " . $events{'install.sql'} . "\n";
        $exit = 1;
    }
} else {
    print STDERR "No install event\n";
    $exit = 1;
}
# FIXME: check for upgrade events. Problem: there may be zero or any number, depending
# on the test plan

exit $exit;
CMD

                        my $ret = $scaffold->invokeOnTarget( 'perl', $cmd, \$out, \$err );
                        if( $ret != 0 ) {
                            $c->error( $err );
                            return 0;
                        }

                        return 1;
                    }
            )
    ]
);

$TEST;
