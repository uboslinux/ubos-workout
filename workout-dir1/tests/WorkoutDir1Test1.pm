#!/usr/bin/perl
#
# Runs workout-dir1
#
# Copyright (C) 2014 and later, Indie Computing Corp. All rights reserved. License: see package.
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

    packageDbsToAdd => {
        'toyapps' => 'https://depot.ubosfiles.net/$channel/$arch/toyapps'
    },

    checks      => [
            new UBOS::WebAppTest::StateCheck(
                    name  => 'virgin',
                    check => sub {
                        my $c = shift;

                        my $dir = $c->apache2ContextDir();

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
