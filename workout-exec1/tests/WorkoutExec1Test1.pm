#!/usr/bin/perl
#
# Runs workout-exec1
#
# Copyright (C) 2014 and later, Indie Computing Corp. All rights reserved. License: see package.
#

use strict;
use warnings;

package WorkoutExec1Test1;

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
        'apache2' => {
            'appconfigfragmentdir'            => '/etc/httpd/appconfigs',
            'gname'                           => 'http',
            'sitefragmentdir'                 => '/etc/httpd/sites',
            'sitesdir'                        => '/ubos/http/sites',
            'ssldir'                          => '/etc/httpd/ssl',
            'uname'                           => 'http'
        },
        'appconfig' => {
            'apache2' => {
                'appconfigfragmentfile' => '/etc/httpd/appconfigs/s[\da-f]{40}/a[\da-f]{40}.conf',
                'dir'                   => '/ubos/http/sites/s[\da-f]{40}' . quotemeta( $context )
            },
            'appconfigid'                   => 'a[\da-f]{40}',
            'context'                       => quotemeta( $context ),
            'contextnoslashorroot'          => quotemeta( $noSlashOrRootContext ),
            'contextorslash'                => quotemeta( $contextOrSlash ),
            'cronjobfile'                   => '/etc/cron.d/50-a[\da-f]{40}',
            'datadir'                       => '/ubos/lib/workout-perlscript1/a[\da-f]{40}'
        },
        'host' => {
            'tmpdir'                             => '/tmp'
        },
        'hostname'                                => '\S+',
        'now' => {
            'tstamp'                              => '\d{8}-\d{6}',
            'unixtime'                            => '\d+'
        },
        'package' => {
            'codedir'                         => '/ubos/share/workout-perlscript1',
            'datadir'                         => '/ubos/lib/workout-perlscript1',
            'manifestdir'                     => '/ubos/lib/ubos/manifests',
            'name'                            => 'workout-perlscript1'
        },
        'site' => {
            'admin' => {
                'credential'                   => 's3cr3t',
                'email'                        => 'testing@ignore.ubos.net',
                'userid'                       => 'testuser',
                'username'                     => 'Test User'
            },
            'apache2' => {
                'authgroupfile'              => '/etc/httpd/sites/s[\da-f]{40}\.groups',
                'htdigestauthuserfile'       => '/etc/httpd/sites/s[\da-f]{40}\.htdigest',
                'sitedocumentdir'            => '/ubos/http/sites/s[\da-f]{40}',
                'sitefragmentfile'           => '/etc/httpd/sites/s[\da-z]{40}\.conf'
            },
            'hostname'                           => quotemeta( $hostname ),
            'protocol'                           => 'http',
            'siteid'                             => 's[\da-f]{40}'
        }
    );
}

# 
# Helper methods

sub checkTemplateContent {
    my $c        = shift;
    my $fileName = shift;

    my $json  = UBOS::Utils::readJsonFromFile( $fileName );

    my $ret = _check( $c, $json, \%vars );
    return $ret;
}

sub _check {
    my $c    = shift;
    my $json = shift;
    my $vars = shift;
    my $path = shift || [];

    my $ret = 1;
    if( ref( $json )) {
        if( ref( $vars )) {
            foreach my $key ( sort keys %$json ) {
                if( exists( $vars->{$key} )) {
                    $ret &= _check( $c, $json->{$key}, $vars->{$key}, [ @$path, $key ] );
                } else {
                    $c->myerror( 'Key Not found in vars:', @$path );
                    $ret = 0;
                }
            }
            foreach my $key ( sort keys %vars ) {
                unless( exists( $json->{$key} )) {
                    $c->myerror( 'Key not found in JSON:', @$path );
                    $ret = 0;
                }
            }
        } else {
            $c->myerror( 'Ref in JSON is not in vars:', @$path );
            $ret = 0;
        }
    } else {
        if( ref( $vars )) {
            $c->myerror( 'Ref in vars is not in JSON:', @$path );
            $ret = 0;
        } else {
            if( $json ne $vars ) {
                $c->myerror( 'Different values:', $json, $vars, '(', @$path . ')' );
                $ret = 0;
            }
        }
    }
    return $ret;
}

# The states and transitions for this test

my $TEST = new UBOS::WebAppTest(
    appToTest   => 'workout-exec1',
    description => 'Tests installation of exec AppConfigItems.',

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

                        $c->checkFile( "$dir/file", undef, undef, undef, \&checkContent );

                        return 1;
                    }
            )
    ]
);

$TEST;
