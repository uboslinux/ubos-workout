#!/usr/bin/perl
#
# Runs workout-tree2
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

package WorkoutTree2Test1;

use UBOS::Logging;
use UBOS::Utils;
use UBOS::WebAppTest;

# The states and transitions for this test

my $TEST = new UBOS::WebAppTest(
    appToTest   => 'workout-tree2',
    description => 'Tests installation of directory tree AppConfigItems.',
    checks      => [
            new UBOS::WebAppTest::StateCheck(
                    name  => 'virgin',
                    check => sub {
                        my $c = shift;

                        my $dir = $c->apache2ContextDir();

                        $c->checkDir(  "$dir/dir" );
                        $c->checkDir(  "$dir/dir/tree-dollar1-1" );
                        $c->checkFile( "$dir/dir/tree-dollar1-1/tree-dollar1-1-a" );

                        $c->checkDir(  "$dir/dir/tree-dollar1-2" );
                        $c->checkDir(  "$dir/dir/tree-dollar1-2/tree-dollar1-2-1" );
                        $c->checkFile( "$dir/dir/tree-dollar1-2/tree-dollar1-2-1/tree-dollar1-2-1-a" );

                        $c->checkDir(  "$dir/dir/tree-dollar2-1" );
                        $c->checkFile( "$dir/dir/tree-dollar2-1/tree-dollar2-1-a" );

                        $c->checkDir(  "$dir/dir/tree-dollar2-2" );
                        $c->checkFile( "$dir/dir/tree-dollar2-2/tree-dollar2-2-a" );
                        
                        return 1;
                    }
            )
    ]
);

$TEST;
