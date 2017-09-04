#!/usr/bin/perl
#
# Runs workout-file2
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

package WorkoutFile1Test1;

use Sys::Hostname;
use UBOS::Logging;
use UBOS::Utils;
use UBOS::WebAppTest;

# The states and transitions for this test

my $TEST = new UBOS::WebAppTest(
    appToTest   => 'workout-file2',
    description => 'Tests installation of file AppConfigItems with variables in filenames.',
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
                        $c->checkFile( "/etc/httpd/ubos/appconfigs/file.txt",                  'root', 'root', 0644 );
                        $c->checkFile( "/srv/http/sites/file.txt",                             'root', 'root', 0644 );
                        $c->checkFile( "/etc/httpd/ubos/ssl/file.txt",                         'root', 'root', 0644 );
                        $c->checkFile( "/etc/httpd/ubos/appconfigs/$siteId/$appConfigId.conf", 'root', 'root', 0644 );
                        $c->checkFile( "$dir/file.txt",                                        'root', 'root', 0644 );
                        $c->checkFile( "/etc/httpd/ubos/sites/$siteId.groups",                 'root', 'root', 0644 );
                        $c->checkFile( "/etc/httpd/ubos/sites/$siteId.htdigest",               'root', 'root', 0644 );

                        trace( 'Checking section 3' );
                        trace( 'Checking section 4' );

                        $c->checkFile( "$dir/$appConfigId",                                    'http', 'http', 0644 );
                        # Cannot test: "/var/lib/workout-file2/$appConfigId/$hostname": must be remote hostname
                        $c->checkFile( "$dir/$siteId",                                         'http', 'http', 0644 );
                        $c->checkFile( "$dir/$vhostname-http",                                 'http', 'http', 0644 );
                        $c->checkFile( "/tmp$context",                                         'http', 'http', 0644 );
                        $c->checkFile( "$dir$context",                                         'http', 'http', 0644 );
                        $c->checkFile( "$dir/testing\@ignore.ubos.net-testuser",               'http', 'http', 0644 );

                        return 1;
                    }
            )
    ]
);

$TEST;
