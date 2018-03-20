#!/usr/bin/perl
#
# Runs workout-file2
#
# Copyright (C) 2014 and later, Indie Computing Corp. All rights reserved. License: see package.
#

use strict;
use warnings;

package WorkoutFile1Test1;

use Sys::Hostname;
use UBOS::Logging;
use UBOS::Utils;
use UBOS::WebAppTest;

# The states and transitions for this test

my $TEST = new UBOS::WebAppTest(
    appToTest   => 'workout-file2',
    description => 'Tests installation of file AppConfigItems with variables in filenames.',

    packageDbsToAdd => {
        'toyapps' => 'http://depot.ubos.net/$channel/$arch/toyapps'
    },

    checks      => [
            new UBOS::WebAppTest::StateCheck(
                    name  => 'virgin',
                    check => sub {
                        my $c = shift;

                        my $appConfigId = $c->getTestPlan()->appConfigId();
                        my $dir         = $c->apache2ContextDir();
                        my $hostname    = hostname();
                        my $context     = $c->context();
                        my $siteId      = $c->getTestPlan()->siteId();
                        my $vhostname   = $c->getTestPlan()->hostname();

                        trace( 'Checking section 1' );
                        $c->checkFile( "/etc/cron.d/50-$appConfigId", 'root', 'root',  '0644' );

                        trace( 'Checking section 2' );
                        $c->checkFile( "/etc/httpd/appconfigs/file.txt",                  'root', 'root', 0644 );
                        $c->checkFile( "/ubos/http/sites/file.txt",                       'root', 'root', 0644 );
                        $c->checkFile( "/etc/httpd/ssl/file.txt",                         'root', 'root', 0644 );
                        $c->checkFile( "/etc/httpd/appconfigs/$siteId/$appConfigId.conf", 'root', 'root', 0644 );
                        $c->checkFile( "$dir/file.txt",                                   'root', 'root', 0644 );
                        $c->checkFile( "/etc/httpd/sites/$siteId.groups",                 'root', 'root', 0644 );
                        $c->checkFile( "/etc/httpd/sites/$siteId.htdigest",               'root', 'root', 0644 );

                        trace( 'Checking section 3' );
                        trace( 'Checking section 4' );

                        $c->checkFile( "$dir/$appConfigId",                               'http', 'http', 0644 );
                        # Cannot test: "/ubos/lib/workout-file2/$appConfigId/$hostname": must be remote hostname
                        $c->checkFile( "$dir/$siteId",                                    'http', 'http', 0644 );
                        $c->checkFile( "$dir/$vhostname-http",                            'http', 'http', 0644 );
                        $c->checkFile( "/tmp$context",                                    'http', 'http', 0644 );
                        $c->checkFile( "$dir$context",                                    'http', 'http', 0644 );
                        $c->checkFile( "$dir/testing\@ignore.ubos.net-testuser",          'http', 'http', 0644 );

                        return 1;
                    }
            )
    ]
);

$TEST;
