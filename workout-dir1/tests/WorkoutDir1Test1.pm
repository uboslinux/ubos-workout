#!/usr/bin/perl
#
# Runs workout-dir1
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

package WorkoutDir1Test1;

use UBOS::Logging;
use UBOS::Utils;
use UBOS::WebAppTest;
# The states and transitions for this test

my $TEST = new UBOS::WebAppTest(
    appToTest   => 'workout-dir1',
    description => 'Tests installation of directory AppConfigItems.',
    checks      => [
            new UBOS::WebAppTest::StateCheck(
                    name  => 'virgin',
                    check => sub {
                        my $c = shift;

                        my $dir = $c->getTest()->apache2ContextDir();

                        $c->checkDir( "$dir/dir1", 'root', 'root',   0755 );
                        $c->checkDir( "$dir/dir2", 'http', 'games',  0555 );

                        $c->checkDir( "/var/tmp/workout-dir1-dir1", 'root', 'root',   0755 );
                        $c->checkDir( "/var/tmp/workout-dir1-dir2", 'http', 'games',  0777 );

                        $c->checkDir( "$dir/multi",       'http', 'games', 0101 );
                        $c->checkDir( "$dir/multi/multi", 'http', 'games', 0101 );
                        
                        return 1;
                    }
            )
    ]
);

$TEST;
