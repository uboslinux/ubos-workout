#!/usr/bin/perl
#
# Runs workout-symlink1
#
# Copyright (C) 2014 and later, Indie Computing Corp. All rights reserved. License: see package.
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

    packageDbsToAdd => {
        'toyapps' => 'http://depot.ubos.net/$channel/$arch/toyapps'
    },

    checks      => [
            new UBOS::WebAppTest::StateCheck(
                    name  => 'virgin',
                    check => sub {
                        my $c = shift;

                        my $dir = $c->apache2ContextDir();

                        $c->checkSymlink( '/tmp',                                 "$dir/symlink-1" );
                        $c->checkSymlink( '/usr/share/workout-symlink1/somefile', "$dir/symlink-2" );

                        return 1;
                    }
            )
    ]
);

$TEST;
