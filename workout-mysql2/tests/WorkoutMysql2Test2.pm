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
print "In StateCheck virgin\n";
                        my $c = shift;
                        my $dbFile        = $c->getTest()->apache2ContextDir() .  '/db';
                        my $dbFileContent = UBOS::Utils::slurpFile( $dbFile );
                        
                        my( $dbHost, $dbPort, $dbName, $dbUserLid, $dbUserLidCredential );
                        eval $dbFileContent || $c->error( 'Eval failed', $! );

                        my $dbh = UBOS::Databases::MySqlDriver::dbConnect( $dbName, $dbUserLid, $dbUserLidCredential, $dbHost, $dbPort );
print "dbh: $dbh\n";

                        return 1;
                    }
            )
    ]
);

$TEST;
