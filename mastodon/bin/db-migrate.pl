#!/usr/bin/perl
#
# Initialize freshly installed Mastodon. Only invoke from ubos-manifest.json.
#

use strict;

use UBOS::Logging;
use UBOS::Utils;

if( 'install' eq $operation ) {
    my $appConfigId  = $config->getResolveOrNull( 'appconfig.appconfigid' );
    my $dataDir      = $config->getResolveOrNull( 'appconfig.datadir' );

    my $cmd = 'cd ' . $dataDir . '/mastodon'
            . ' &&'
            . ' SAFETY_ASSURED=1'
            . ' RAILS_ENV=production'
            . ' APPCONFIGID=' . $appConfigId
            . ' bundle exec rails db:migrate';

    my $out;
    if( UBOS::Utils::myexec( $cmd, undef, \$out, \$out )) {
        error( "Rails db:migrate failed: cmd: $cmd, out: $out" );
    }
}

1;

