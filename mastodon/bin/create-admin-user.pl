#!/usr/bin/perl
#
# Provision a user and make it admin. Only invoke from ubos-manifest.json.
#

use strict;

use UBOS::Logging;
use UBOS::Utils;

if( 'install' eq $operation ) {
    my $appConfigId = $config->getResolveOrNull( 'appconfig.appconfigid' );
    my $dataDir     = $config->getResolveOrNull( 'appconfig.datadir' );
    my $adminEmail  = $config->getResolveOrNull( 'site.admin.email' );
    my $adminPass   = $config->getResolveOrNull( 'site.admin.credential' );
    my $adminUserId = $config->getResolveOrNull( 'site.admin.userid' );

    # from config/settings.yml
    my $reservedUserIds = {
        'admin',
        'support',
        'help',
        'root',
        'webmaster',
        'administrator'
    };

    if( exists( $reservedUserIds->{$adminUserId} )) {
        my $replacement = 'mastodon' . $reservedUserIds->{$adminUserId};
        warning( 'mastodon does not allow a user named', $reservedUserIds->{$adminUserId},
                 '. Provisioning a user named', $replacement, 'instead.' );

        $adminUserId = $replacement;
    }
    my $cmdPrefix = "cd $dataDir/mastodon; APPCONFIGID=$appConfigId RAILS_ENV=production";
    my $out;
    my $err;

    # Add admin user
    my $input = <<INPUT;
$adminEmail
$adminUserId
$adminPass
INPUT

    if( UBOS::Utils::myexec( "$cmdPrefix bundle exec rails ubos:provision_admin", $input, \$out, \$err )) {
        error( 'Rake task ubos:provision_admin:', $out, $err );
    }
}

1;
