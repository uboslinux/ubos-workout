#!/usr/bin/perl
#
# Runs workout-perlscript1
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

package WorkoutPerlscript1Test1;

use UBOS::Logging;
use UBOS::Utils;
use UBOS::WebAppTest;
use UBOS::Logging;
use UBOS::Utils;
use UBOS::WebAppTest;

my %vars = (
    'apache2.appconfigfragmentdir'            => '/etc/httpd/ubos/appconfigs',
    'apache2.gname'                           => 'http',
    'apache2.sitefragmentdir'                 => '/etc/httpd/ubos/sites',
    'apache2.sitesdir'                        => '/srv/http/sites',
    'apache2.ssldir'                          => '/etc/httpd/ubos/ssl',
    'apache2.uname'                           => 'http',
    'appconfig.apache2.appconfigfragmentfile' => '/etc/httpd/ubos/appconfigs/s[\da-f]{40}/a[\da-f]{40}.conf',
    'appconfig.apache2.dir'                   => '/srv/http/sites/s[\da-f]{40}/workout-perlscript1',
    'appconfig.appconfigid'                   => 'a[\da-f]{40}',
    'appconfig.context'                       => '/workout-perlscript1',
    'appconfig.contextnoslashorroot'          => 'workout-perlscript1',
    'appconfig.contextorslash'                => '/workout-perlscript1',
    'appconfig.cronjobfile'                   => '/etc/cron.d/50-a[\da-f]{40}',
    'appconfig.datadir'                       => '/var/lib/workout-perlscript1/a[\da-f]{40}',
    'host.tmpdir'                             => '/tmp',
    'hostname'                                => '\S+',
    'now.tstamp'                              => '\d{8}-\d{6}',
    'now.unixtime'                            => '\d+',
    'package.codedir'                         => '/usr/share/workout-perlscript1',
    'package.datadir'                         => '/var/lib/workout-perlscript1',
    'package.manifestdir'                     => '/var/lib/ubos/manifests',
    'package.name'                            => 'workout-perlscript1',
    'site.admin.credential'                   => 's3cr3t',
    'site.admin.email'                        => 'testing@ignore.ubos.net',
    'site.admin.userid'                       => 'testuser',
    'site.admin.username'                     => 'Test User',
    'site.apache2.authgroupfile'              => '/etc/httpd/ubos/sites/s[\da-f]{40}\.groups',
    'site.apache2.htdigestauthuserfile'       => '/etc/httpd/ubos/sites/s[\da-f]{40}\.htdigest',
    'site.apache2.sitedocumentdir'            => '/srv/http/sites/s[\da-f]{40}',
    'site.apache2.sitefragmentfile'           => '/etc/httpd/ubos/sites/s[\da-z]{40}\.conf',
    'site.hostname'                           => 'test',
    'site.protocol'                           => 'http',
    'site.siteid'                             => 's[\da-f]{40}'
);

# 
# Helper methods

sub checkTemplateContent {
    my $c        = shift;
    my $fileName = shift;

    my $content = UBOS::Utils::slurpFile( $fileName );

    my $ret = 1;
    foreach my $var ( sort keys %vars ) {
        my $regex   = $vars{$var};
        my $toMatch = quotemeta( $var ) . "\\s+$regex\\s*" . quotemeta( "\\\${$var}" ) . "\\s*";

        unless( $content =~ m!^$toMatch$!m ) {
            $c->error( 'Incorrect variable substitution in file', $fileName, 'for var', $var );
            $ret = 0;
        }
    }
    return $ret;
}

# The states and transitions for this test

my $TEST = new UBOS::WebAppTest(
    appToTest   => 'workout-perlscript1',
    description => 'Tests installation of perlscript AppConfigItems.',
    checks      => [
            new UBOS::WebAppTest::StateCheck(
                    name  => 'virgin',
                    check => sub {
                        my $c = shift;

                        my $dir = $c->getTestPlan()->apache2ContextDir();

                        $c->checkFile( "$dir/file", undef, undef, undef, \&checkTemplateContent );

                        return 1;
                    }
            )
    ]
);

$TEST;