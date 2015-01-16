#!/usr/bin/perl
#
# Runs workout-symlink1
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

package WorkoutSymlink1Test1;

use UBOS::Logging;
use UBOS::Utils;
use UBOS::WebAppTest;

# The states and transitions for this test

my $TEST = new UBOS::WebAppTest(
    appToTest   => 'workout-symlink1',
    description => 'Tests installation of symlink AppConfigItems.',
    checks      => [
            new UBOS::WebAppTest::StateCheck(
                    name  => 'virgin',
                    check => sub {
                        my $c = shift;

                        my $dir = $c->getTestPlan()->apache2ContextDir();

                        $c->checkSymlink( '/tmp',                                 "$dir/symlink-1" );
                        $c->checkSymlink( '/usr/share/workout-symlink1/somefile', "$dir/symlink-2" );

                        return 1;
                    }
            )
    ]
);

$TEST;
