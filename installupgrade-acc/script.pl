#!/usr/bin/perl
#
# Echo to stdout how the script was invoked
#
# Copyright (C) 2016 and later, Indie Computing Corp. All rights reserved. License: see package.
#

use strict;

use UBOS::Logging;
use UBOS::Utils;

my $siteId      = $config->getResolve( 'site.siteid' );
my $appConfigId = $config->getResolve( 'appconfig.appconfigid' );

print( "XXX installupgrade-acc script.pl $operation (site=$siteId, appConfig=$appConfigId)\n" );

1;
