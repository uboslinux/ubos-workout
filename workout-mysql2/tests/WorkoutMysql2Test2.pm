#!/usr/bin/perl
#
# Runs workout-mysql1
#
# This file is part of UBOS.
# (C) 2012-2014 Indie Computing Corp.
#
# UBOS is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# UBOS is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with gladiwashere.  If not, see <http://www.gnu.org/licenses/>.
#

use strict;
use warnings;

package WorkoutMysql2Test1;

use UBOS::Logging;
use UBOS::Utils;
use UBOS::WebAppTest;

# The states and transitions for this test

my $TEST = new UBOS::WebAppTest(
    appToTest   => 'workout-mysql2',
    description => 'Tests MySQL database initialization and upgrade based on templates.',
    checks      => [
            new UBOS::WebAppTest::StateCheck(
                    name  => 'virgin',
                    check => sub {
                        my $c      = shift;
                        my $siteId = $c->getTestPlan()->siteId();
                        my $dbFile = $c->getTestPlan()->apache2ContextDir() .  '/db';

                        my $scaffold = $c->getScaffold();

                        my $out;
                        my $err;
                        my $cmd = <<CMD;
use strict;
use warnings;
use UBOS::Utils;
use UBOS::Databases::MySqlDriver;

my \$dbFileContent = UBOS::Utils::slurpFile( '$dbFile' );
my \$siteId        = '$siteId';
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
my $dbh = UBOS::Databases::MySqlDriver::dbConnect( $dbName, $dbUserLid, $dbUserLidCredential, $dbHost, $dbPort );

my $sth = UBOS::Databases::MySqlDriver::sqlPrepareExecute( $dbh, <<SQL );
SELECT * FROM `happenings` ORDER BY `ts`;
SQL
my %events = ();
my $exit   = 0;
while( my $ref = $sth->fetchrow_hashref() ) {
    my $event = $ref->{event};
    if( exists( $events{$event} )) {
        ++$events{$event};
    } else {
        $events{$event} = 1;
    }
    unless( $ref->{argument} =~ m!$siteId! ) {
        print STDERR "No siteid in argument column\n";
        $exit = 1;
    }
    unless( $ref->{argument} =~ m!$dbUserLid! ) {
        print STDERR "No dbUserLid in argument column\n";
        $exit = 1;
    }
}

# There can be two events (create and install) or three events (plus: upgrade)
if( exists( $events{'create.tmpl'} )) {
    unless( $events{'create.tmpl'} == 1 ) {
        print STDERR "Too many create events: " . $events{'create.sql'} . "\n";
        $exit = 1;
    }
} else {
    print STDERR "No create event\n";
    $exit = 1;
}
if( exists( $events{'install.tmpl'} )) {
    unless( $events{'install.tmpl'} == 1 ) {
        print STDERR "Too many install events: " . $events{'install.sql'} . "\n";
        $exit = 1;
    }
} else {
    print STDERR "No install event\n";
    $exit = 1;
}
if( exists( $events{'upgrade.tmpl'} )) {
    unless( $events{'upgrade.tmpl'} == 1 ) {
        print STDERR "Too many upgrade events: " . $events{'upgrade.sql'} . "\n";
        $exit = 1;
    }
} # There may not be an upgrade event

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
