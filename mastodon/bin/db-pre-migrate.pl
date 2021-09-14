#!/usr/bin/perl
#
# For upgrading to 3.4.0 we need to run this pre-migrate
# Only invoke from ubos-manifest.json.
#

use strict;

use UBOS::Databases::PostgreSqlDriver;
use UBOS::Logging;
use UBOS::Utils;

my $appConfigId  = $config->getResolveOrNull( 'appconfig.appconfigid' );
my $dataDir      = $config->getResolveOrNull( 'appconfig.datadir' );

my $dbUser       = $config->getResolveOrNull( 'appconfig.postgresql.dbuser.maindb' );
my $dbName       = $config->getResolveOrNull( 'appconfig.postgresql.dbname.maindb' );

if( 'upgrade' eq $operation ) {
    unless( UBOS::Databases::PostgreSqlDriver::changeSchemaOwnership( $dbName, $dbUser )) {
        error( 'Changing postgres schema ownership failed' );
    }
}

if( 'install' eq $operation || 'upgrade' eq $operation ) {
    my $cmd = 'cd ' . $dataDir . '/mastodon'
            . ' &&'
            . ' SAFETY_ASSURED=1'
            . ' SKIP_POST_DEPLOYMENT_MIGRATIONS=true'
            . ' RAILS_ENV=production'
            . ' APPCONFIGID=' . $appConfigId
            . ' bundle exec rails db:migrate';

    my $out;
    if( UBOS::Utils::myexec( $cmd, undef, \$out, \$out )) {
        error( "Rails db:migrate failed: cmd: $cmd, out: $out" );
    }
}

1;

