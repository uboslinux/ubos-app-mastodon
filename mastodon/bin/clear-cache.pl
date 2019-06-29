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
    my $appConfigDir = $config->getResolveOrNull( 'appconfig.apache2.dir' );

    my $cmd = "cd '$appConfigDir';";
    $cmd .= " RAILS_ENV=production bin/tootctl cache clear";

    if( UBOS::Utils::myexec( $cmd, undef, \$out, \$out ) != 0 ) {
        error( "Cleaning mastodon cache failed: $out" );
        $ret = 0;
    }
}

$ret;




