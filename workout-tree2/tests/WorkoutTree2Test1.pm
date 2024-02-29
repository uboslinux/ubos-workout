#!/usr/bin/perl
#
# Runs workout-tree2
#
# Copyright (C) 2014 and later, Indie Computing Corp. All rights reserved. License: see package.
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

    packageDbsToAdd => {
        'toyapps' => 'https://depot.ubosfiles.net/$channel/$arch/toyapps'
    },

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
