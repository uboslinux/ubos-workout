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
    testContext => '/workout-mysql2',
    hostname    => 'test',
    checks      => [
            new UBOS::WebAppTest::StateCheck(
                    name  => 'virgin',
                    check => sub {
                        my $c = shift;

                        my $siteId        = $c->getTest()->siteId();
                        my $dbFile        = $c->getTest()->apache2ContextDir() .  '/db';
                        my $dbFileContent = UBOS::Utils::slurpFile( $dbFile );
                        
                        my( $dbHost, $dbPort, $dbName, $dbUserLid, $dbUserLidCredential );
                        eval $dbFileContent || $c->error( 'Eval failed', $! );

                        my $dbh = UBOS::Databases::MySqlDriver::dbConnect( $dbName, $dbUserLid, $dbUserLidCredential, $dbHost, $dbPort );

                        my $sth = UBOS::Databases::MySqlDriver::sqlPrepareExecute( $dbh, <<SQL );
SELECT * FROM `happenings` ORDER BY `ts`;
SQL
                        my %events = ();
                        while( my $ref = $sth->fetchrow_hashref() ) {
                            my $event = $ref->{event};
                            if( exists( $events{$event} )) {
                                ++$events{$event};
                            } else {
                                $events{$event} = 1;
                            }
                            unless( $ref->{argument} =~ m!$siteId! ) {
                                $c->error( 'No siteid in argument column' );
                            }
                            unless( $ref->{argument} =~ m!$dbUserLid! ) {
                                $c->error( 'No dbUserLid in argument column' );
                            }
                        }

                        # There can be two events (create and install) or three events (plus: upgrade)
                        if( exists( $events{'create.tmpl'} )) {
                            unless( $events{'create.tmpl'} == 1 ) {
                                $c->error( 'Too many create events', $events{'create.tmpl'} );
                            }
                        } else {
                            $c->error( 'No create event' );
                        }
                        if( exists( $events{'install.tmpl'} )) {
                            unless( $events{'install.tmpl'} == 1 ) {
                                $c->error( 'Too many install events', $events{'install.tmpl'} );
                            }
                        } else {
                            $c->error( 'No install event' );
                        }
                        if( exists( $events{'upgrade.tmpl'} )) {
                            unless( $events{'upgrade.tmpl'} == 1 ) {
                                $c->error( 'Too many upgrade events', $events{'upgrade.tmpl'} );
                            }
                        } # There may not be an upgrade event
                        return 1;
                    }
            )
    ]
);

$TEST;
