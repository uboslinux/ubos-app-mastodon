#!/usr/bin/perl
#
# Create a log directory. Only invoke from ubos-manifest.json.
#

use strict;

use UBOS::Logging;
use UBOS::Utils;

if( 'deploy' eq $operation ) {
    my $appConfigId = $config->getResolveOrNull( 'appconfig.appconfigid' );
    my $logDir      = "/var/log/mastodon-$appConfigId";

    unless( -d $logDir ) {
        UBOS::Utils::mkdir( $logDir, 0755, 'mastodon', 'mastodon' );
    }
}

1;

