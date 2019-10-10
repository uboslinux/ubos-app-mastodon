#!/usr/bin/perl
#
# Clear cache
#
# Copyright (C) 2019 and later, Indie Computing Corp. All rights reserved. License: see package.
#

use strict;

use UBOS::Logging;
use UBOS::Utils;

my $ret = 1;

if( 'upgrade' eq $operation ) {
    my $appConfigDataDir = $config->getResolveOrNull( 'appconfig.datadir' );
    my $appConfigId      = $config->getResolveOrNull( 'appconfig.appconfigid' );

    my $cmd = "cd '$appConfigDataDir/mastodon';";
    $cmd .= " APPCONFIGID=$appConfigId";
    $cmd .= " RAILS_ENV=production";
    $cmd .= " bin/tootctl cache clear";

    my $out;
    if( UBOS::Utils::myexec( $cmd, undef, \$out, \$out ) != 0 ) {
        error( "Cleaning mastodon cache failed: $out" );
        $ret = 0;
    }
}

$ret;




