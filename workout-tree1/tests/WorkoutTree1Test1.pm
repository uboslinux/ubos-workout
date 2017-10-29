#!/usr/bin/perl
#
# Runs workout-tree1
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

package WorkoutTree1Test1;

use UBOS::Logging;
use UBOS::Utils;
use UBOS::WebAppTest;

##
# Helper method
sub checkDir {
    my $c       = shift;
    my $root    = shift;
    my $uname   = shift;
    my $gname   = shift;
    my $dirMod  = shift;
    my $fileMod = shift;

    $c->checkDir( "$root",                             $uname, $gname, $dirMod );
    $c->checkDir( "$root/in-tree-dir",                 $uname, $gname, $dirMod );
    $c->checkDir( "$root/in-tree-dir/in-tree-dir-dir", $uname, $gname, $dirMod );

    $c->checkFile( "$root/in-tree-a",                                     $uname, $gname, $fileMod );
    $c->checkFile( "$root/in-tree-dir/in-tree-dir-a",                     $uname, $gname, $fileMod );
    $c->checkFile( "$root/in-tree-dir/in-tree-dir-dir/in-tree-dir-dir-b", $uname, $gname, $fileMod );
    $c->checkFile( "$root/in-tree-z",                                     $uname, $gname, $fileMod );
}

# The states and transitions for this test

my $TEST = new UBOS::WebAppTest(
    appToTest   => 'workout-tree1',
    description => 'Tests installation of directory tree AppConfigItems.',

    packageDbsToAdd => {
        'toyapps' => 'http://depot.ubos.net/$channel/$arch/toyapps'
    },

    checks      => [
            new UBOS::WebAppTest::StateCheck(
                    name  => 'virgin',
                    check => sub {
                        my $c = shift;

                        my $dir = $c->apache2ContextDir();

                        checkDir( $c, "$dir/tree-1-asis",     'root', 'root',  0755, 0644 );
                        checkDir( $c, "$dir/tree-1-chmod",    'root', 'root',  0753, 0432 );
                        checkDir( $c, "$dir/tree-1-preserve", 'http', 'games', 0755, 0644 );
                        
                        return 1;
                    }
            )
    ]
);

$TEST;
