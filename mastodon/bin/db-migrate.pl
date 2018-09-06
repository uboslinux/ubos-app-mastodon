#!/usr/bin/perl
#
# Initialize freshly installed Mastodon, or upgrade an existing one.
# Only invoke from ubos-manifest.json.
#

use strict;

use UBOS::Databases::PostgreSqlDriver;
use UBOS::Logging;
use UBOS::Utils;

if( 'install' eq $operation || 'upgrade' eq $operation ) {
    my $appConfigId  = $config->getResolveOrNull( 'appconfig.appconfigid' );
    my $dataDir      = $config->getResolveOrNull( 'appconfig.datadir' );

    my $dbUser       = $config->getResolveOrNull( 'appconfig.postgresql.dbuser.maindb' );
    my $dbName       = $config->getResolveOrNull( 'appconfig.postgresql.dbname.maindb' );

    # This seems to be a hack, but after restore from backup, our
    # postgres user does not have any privileges any more to access
    # this database, see https://github.com/uboslinux/ubos-mastodon/issues/7

    unless( UBOS::Databases::PostgreSqlDriver::executeCmdAsAdmin(
            'psql -v HISTFILE=/dev/null ' . $dbName,
            <<SQL )) {
GRANT ALL ON ALL TABLES IN SCHEMA public TO "$dbUser";
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO "$dbUser";
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO "$dbUser";
SQL
        error( 'Updating postgres user permissions failed' );
    }

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

