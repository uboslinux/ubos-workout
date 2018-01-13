#!/usr/bin/perl
#
# Copyright (C) 2014 and later, Indie Computing Corp. All rights reserved. License: see package.
#

use strict;

use UBOS::Utils;

my @vars = qw(
    apache2.appconfigfragmentdir
    apache2.gname
    apache2.sitefragmentdir
    apache2.sitesdir
    apache2.ssldir
    apache2.uname
    appconfig.apache2.appconfigfragmentfile
    appconfig.apache2.dir
    appconfig.appconfigid
    appconfig.context
    appconfig.contextnoslashorroot
    appconfig.contextorslash
    appconfig.cronjobfile
    appconfig.datadir
    host.tmpdir
    hostname
    now.tstamp
    now.unixtime
    package.codedir
    package.datadir
    package.manifestdir
    package.name
    site.admin.credential
    site.admin.email
    site.admin.userid
    site.admin.username
    site.apache2.authgroupfile
    site.apache2.htdigestauthuserfile
    site.apache2.sitedocumentdir
    site.apache2.sitefragmentfile
    site.hostname
    site.protocol
    site.siteid
);
my $ret;
foreach my $var ( @vars ) {
    $ret .= sprintf( '%-40s%-42s\${%s}', $var, $config->getResolve( $var ), $var ) . "\n";
}
$ret;
