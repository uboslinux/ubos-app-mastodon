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
        'admin'         => 1,
        'support'       => 1,
        'help'          => 1,
        'root'          => 1,
        'webmaster'     => 1,
        'administrator' => 1
    };

    if( exists( $reservedUserIds->{$adminUserId} )) {
        my $replacement = "mastodon$adminUserId";
        warning( "mastodon does not allow a user named $adminUserId. Provisioning a user named $replacement instead." );

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
        error( 'Rake task ubos:provision_admin: cmdPrefix:', $cmdPrefix, 'input: ', $input, 'output:'. $out, 'error:', $err );
    }
}

1;
