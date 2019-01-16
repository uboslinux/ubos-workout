#!/usr/bin/perl
#
# Runs workout-perlscript1
#
# Copyright (C) 2014 and later, Indie Computing Corp. All rights reserved. License: see package.
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

my %vars = ();

# Initialize the vars hash
# $hostname: the host at which the site runs
# $context: the context at which the site runs
sub initVars {
    my $hostname = shift;
    my $context  = shift;

    my $noSlashOrRootContext = $context;
    $noSlashOrRootContext =~ s!^/!!;
    unless( $noSlashOrRootContext ) {
        $noSlashOrRootContext = 'ROOT';
    }

    my $contextOrSlash = $context ? $context : '/';

    %vars = (
        'apache2.appconfigfragmentdir'            => '/etc/httpd/appconfigs',
        'apache2.gname'                           => 'http',
        'apache2.sitefragmentdir'                 => '/etc/httpd/sites',
        'apache2.sitesdir'                        => '/ubos/http/sites',
        'apache2.ssldir'                          => '/etc/httpd/ssl',
        'apache2.uname'                           => 'http',
        'appconfig.apache2.appconfigfragmentfile' => '/etc/httpd/appconfigs/s[\da-f]{40}/a[\da-f]{40}.conf',
        'appconfig.apache2.dir'                   => '/ubos/http/sites/s[\da-f]{40}' . quotemeta( $context ),
        'appconfig.appconfigid'                   => 'a[\da-f]{40}',
        'appconfig.context'                       => quotemeta( $context ),
        'appconfig.contextnoslashorroot'          => quotemeta( $noSlashOrRootContext ),
        'appconfig.contextorslash'                => quotemeta( $contextOrSlash ),
        'appconfig.cronjobfile'                   => '/etc/cron.d/50-a[\da-f]{40}',
        'appconfig.datadir'                       => '/ubos/lib/workout-perlscript1/a[\da-f]{40}',
        'host.tmpdir'                             => '/ubos/tmp',
        'hostname'                                => '\S+',
        'now.tstamp'                              => '\d{8}-\d{6}',
        'now.unixtime'                            => '\d+',
        'package.codedir'                         => '/ubos/share/workout-perlscript1',
        'package.datadir'                         => '/ubos/lib/workout-perlscript1',
        'package.manifestdir'                     => '/ubos/lib/ubos/manifests',
        'package.name'                            => 'workout-perlscript1',
        'site.admin.credential'                   => 's3cr3t',
        'site.admin.email'                        => 'testing@ignore.ubos.net',
        'site.admin.userid'                       => 'testuser',
        'site.admin.username'                     => 'Test User',
        'site.apache2.authgroupfile'              => '/etc/httpd/sites/s[\da-f]{40}\.groups',
        'site.apache2.htdigestauthuserfile'       => '/etc/httpd/sites/s[\da-f]{40}\.htdigest',
        'site.apache2.sitedocumentdir'            => '/ubos/http/sites/s[\da-f]{40}',
        'site.apache2.sitefragmentfile'           => '/etc/httpd/sites/s[\da-z]{40}\.conf',
        'site.hostname'                           => quotemeta( $hostname ),
        'site.protocol'                           => 'http',
        'site.siteid'                             => 's[\da-f]{40}'
    );
}

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

    packageDbsToAdd => {
        'toyapps' => 'http://depot.ubos.net/$channel/$arch/toyapps'
    },

    checks      => [
            new UBOS::WebAppTest::StateCheck(
                    name  => 'virgin',
                    check => sub {
                        my $c = shift;

                        my $dir = $c->apache2ContextDir();

                        initVars( $c->hostname(), $c->context() );

                        $c->checkFile( "$dir/file", undef, undef, undef, \&checkTemplateContent );

                        return 1;
                    }
            )
    ]
);

$TEST;
