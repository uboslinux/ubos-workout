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

package WorkoutMysql1Test1;

use UBOS::Logging;
use UBOS::Utils;
use UBOS::WebAppTest;
# The states and transitions for this test


my $TEST = new UBOS::WebAppTest(
    appToTest   => 'workout-mysql1',
    description => 'Tests MySQL database initialization and upgrade.',
    testContext => '/workout-mysql1',
    hostname    => 'test',
    checks      => [
            new UBOS::WebAppTest::StateCheck(
                    name  => 'virgin',
                    check => sub {
                        my $c = shift;
                        my $dbFile        = $c->getTest()->apache2ContextDir() .  '/db';
                        my $dbFileContent = UBOS::Utils::slurpFile( $dbFile );
                        
                        my( $dbHost, $dbPort, $dbName, $dbUserLid, $dbUserLidCredential );
                        eval $dbFileContent || $c->error( 'Eval failed', $! );

                        unless( $dbHost ) {
                            $c->error( 'dbHost not set' );
                        }
                        unless( $dbPort ) {
                            $c->error( 'dbPort not set' );
                        }
                        unless( $dbName ) {
                            $c->error( 'dbName not set' );
                        }
                        unless( $dbUserLid ) {
                            $c->error( 'dbUserLid not set' );
                        }
                        unless( $dbUserLidCredential ) {
                            $c->error( 'dbUserLidCredential not set' );
                        }
                        
                        my $dbh = UBOS::Databases::MySqlDriver::dbConnect( $dbName, $dbUserLid, $dbUserLidCredential, $dbHost, $dbPort );
                        my $sth = UBOS::Databases::MySqlDriver::sqlPrepareExecute( $dbh, <<SQL );
SELECT * FROM `happenings` ORDER BY `ts`;
SQL
                        my @events = ();
                        while( my $ref = $sth->fetchrow_hashref() ) {
                            push @events, $ref->{event};
                        }
                        print "Events:\n" . join( "\n", @events ) . "\n";
                        return 1;
                    }
            )
    ]
);

$TEST;
