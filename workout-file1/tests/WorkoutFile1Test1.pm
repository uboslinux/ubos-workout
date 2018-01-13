#!/usr/bin/perl
#
# Runs workout-file1
#
# Copyright (C) 2014 and later, Indie Computing Corp. All rights reserved. License: see package.
#

use strict;
use warnings;

package WorkoutFile1Test1;

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
        'apache2.appconfigfragmentdir'            => '/etc/httpd/ubos/appconfigs',
        'apache2.gname'                           => 'http',
        'apache2.sitefragmentdir'                 => '/etc/httpd/ubos/sites',
        'apache2.sitesdir'                        => '/srv/http/sites',
        'apache2.ssldir'                          => '/etc/httpd/ubos/ssl',
        'apache2.uname'                           => 'http',
        'appconfig.apache2.appconfigfragmentfile' => '/etc/httpd/ubos/appconfigs/s[\da-f]{40}/a[\da-f]{40}.conf',
        'appconfig.apache2.dir'                   => '/srv/http/sites/s[\da-f]{40}' . quotemeta( $context ),
        'appconfig.appconfigid'                   => 'a[\da-f]{40}',
        'appconfig.context'                       => quotemeta( $context ),
        'appconfig.contextnoslashorroot'          => quotemeta( $noSlashOrRootContext ),
        'appconfig.contextorslash'                => quotemeta( $contextOrSlash ),
        'appconfig.cronjobfile'                   => '/etc/cron.d/50-a[\da-f]{40}',
        'appconfig.datadir'                       => '/var/lib/workout-file1/a[\da-f]{40}',
        'host.tmpdir'                             => '/tmp',
        'hostname'                                => '\S+',
        'now.tstamp'                              => '\d{8}-\d{6}',
        'now.unixtime'                            => '\d+',
        'package.codedir'                         => '/usr/share/workout-file1',
        'package.datadir'                         => '/var/lib/workout-file1',
        'package.manifestdir'                     => '/var/lib/ubos/manifests',
        'package.name'                            => 'workout-file1',
        'site.admin.credential'                   => 's3cr3t',
        'site.admin.email'                        => 'testing@ignore.ubos.net',
        'site.admin.userid'                       => 'testuser',
        'site.admin.username'                     => 'Test User',
        'site.apache2.authgroupfile'              => '/etc/httpd/ubos/sites/s[\da-f]{40}\.groups',
        'site.apache2.htdigestauthuserfile'       => '/etc/httpd/ubos/sites/s[\da-f]{40}\.htdigest',
        'site.apache2.sitedocumentdir'            => '/srv/http/sites/s[\da-f]{40}',
        'site.apache2.sitefragmentfile'           => '/etc/httpd/ubos/sites/s[\da-z]{40}\.conf',
        'site.hostname'                           => quotemeta( $hostname ),
        'site.protocol'                           => 'http',
        'site.siteid'                             => 's[\da-f]{40}'
    );
}

#
# Helper methods

sub checkStaticContent {
    my $c        = shift;
    my $fileName = shift;

    my $content = UBOS::Utils::slurpFile( $fileName );

    my $ret = 1;
    unless( $content =~ m!Great content.*For a test file!s ) {
        $c->error( 'Not copied correctly:', $fileName );
        $ret = 0;
    }
    return $ret;
}

sub checkTemplateContent {
    my $c        = shift;
    my $fileName = shift;

    my $content = UBOS::Utils::slurpFile( $fileName );

    my $ret = 1;
    foreach my $var ( sort keys %vars ) {
        my $regex   = $vars{$var};
        my $toMatch = quotemeta( $var ) . "\\s+$regex\\s*" . quotemeta( "\\\${$var}" ) . "\\s*";

        unless( $content =~ m!^$toMatch$!m ) {
            $c->error( 'Incorrect variable substitution in file', $fileName, 'for var', $var, ': was expecting', $toMatch );
            $ret = 0;
        }
    }
    return $ret;
}

# The states and transitions for this test

my $TEST = new UBOS::WebAppTest(
    appToTest   => 'workout-file1',
    description => 'Tests installation of file AppConfigItems.',

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

                        trace( 'Checking copied files' );
                        $c->checkFile( "$dir/file-copy-1.TXT", 'root', 'root',   0644, \&checkStaticContent );
                        $c->checkFile( "$dir/file-copy-2.txt", 'http', 'games', 01234, \&checkStaticContent );

                        trace( 'Checking varsubst files' );
                        $c->checkFile( "$dir/file-template-varsubst-1.txt", 'root', 'root',   0644, \&checkTemplateContent );
                        $c->checkFile( "$dir/file-template-varsubst-2.txt", 'http', 'games', 01234, \&checkTemplateContent );

                        trace( 'Checking perlscript files' );
                        $c->checkFile( "$dir/file-template-perlscript-1.txt", 'root', 'root',   0644, \&checkTemplateContent );
                        $c->checkFile( "$dir/file-template-perlscript-2.txt", 'http', 'games', 01234, \&checkTemplateContent );

                        trace( 'Checking multi-name files' );
                        $c->checkFile( "$dir/file-1-copy-a.txt", 'http', 'games', 01234, \&checkStaticContent );
                        $c->checkFile( "$dir/file-2-copy-a.txt", 'root', 'root',   0644, \&checkStaticContent );
                        $c->checkFile( "$dir/multi/file-1-copy-c.txt", 'http', 'games', 01234, \&checkStaticContent );
                        $c->checkFile( "$dir/multi/file-2-copy-c.txt", 'root', 'root',   0644, \&checkStaticContent );
                        $c->checkFile( "$dir/multi/multi/file-1-copy-b.txt", 'http', 'games', 01234, \&checkStaticContent );
                        $c->checkFile( "$dir/multi/multi/file-2-copy-b.txt", 'root', 'root',   0644, \&checkStaticContent );

                        return 1;
                    }
            )
    ]
);

$TEST;
