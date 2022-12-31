#!/usr/bin/perl
#
# Generate the production .env file.
# Only invoke from ubos-manifest.json.
#

use strict;

use UBOS::Logging;
use UBOS::Utils;

my $dataDir = $config->getResolveOrNull( 'appconfig.datadir' );
my $name    = "$dataDir/mastodon/.env.production";

if( 'deploy' eq $operation ) {
    my $appConfigId = $config->getResolveOrNull( 'appconfig.appconfigid' );

    my $redisPort   = $config->getResolveOrNull( 'appconfig.tcpport.redis' );

    my $dbHost      = $config->getResolveOrNull( 'appconfig.postgresql.dbhost.maindb' );
    my $dbUser      = $config->getResolveOrNull( 'appconfig.postgresql.dbuser.maindb' );
    my $dbName      = $config->getResolveOrNull( 'appconfig.postgresql.dbname.maindb' );
    my $dbPass      = $config->getResolveOrNull( 'appconfig.postgresql.dbusercredential.maindb' );
    my $dbPort      = $config->getResolveOrNull( 'appconfig.postgresql.dbport.maindb' );

    my $hostname    = $config->getResolveOrNull( 'site.hostname' );

    my $paperclipSecret = $config->getResolveOrNull( 'installable.customizationpoints.paperclip_secret.value' );
    my $secretKeyBase   = $config->getResolveOrNull( 'installable.customizationpoints.secret_key_base.value' );
    my $otpSecret       = $config->getResolveOrNull( 'installable.customizationpoints.otp_secret.value' );

    my $singleUserMode  = $config->getResolve( 'installable.customizationpoints.singleusermode.value', 1 );
    $singleUserMode     = $singleUserMode ? 'true' : 'false';

    my $defaultLocale   = $config->getResolveOrNull( 'installable.customizationpoints.defaultlocale.value' );

    my $emailDomainBlacklist = $config->getResolveOrNull( 'installable.customizationpoints.email_domain_blacklist.value' );
    my $emailDomainWhitelist = $config->getResolveOrNull( 'installable.customizationpoints.email_domain_whitelist.value' );

    my $ruby = <<RUBY;
require 'webpush'

vapid_key = Webpush.generate_key

puts 'public:' + vapid_key.public_key
puts 'private:' + vapid_key.private_key
RUBY

    my $out;
    my $err;
    if( UBOS::Utils::myexec( "cd $dataDir/mastodon; bundle exec ruby", $ruby, \$out, \$err )) {
        error( 'Ruby key generation failed:', $out, $err );
    }

    my $vapidPrivate;
    my $vapidPublic;
    if( $out =~ m!^public:(.+)$!m ) {
        $vapidPublic = $1;
    }
    if( $out =~ m!^private:(.+)$!m ) {
        $vapidPrivate = $1;
    }

    my $content = <<CONTENT;
REDIS_HOST=127.0.0.1
REDIS_PORT=$redisPort
REDIS_PASSWORD=

DB_HOST=$dbHost
DB_USER=$dbUser
DB_NAME=$dbName
DB_PASS=$dbPass
DB_PORT=$dbPort

LOCAL_DOMAIN=$hostname

SECRET_KEY_BASE=$secretKeyBase
OTP_SECRET=$otpSecret

VAPID_PRIVATE_KEY=$vapidPrivate
VAPID_PUBLIC_KEY=$vapidPublic

SINGLE_USER_MODE=$singleUserMode

DEFAULT_LOCALE=$defaultLocale

SMTP_SERVER=localhost
SMTP_PORT=25
SMTP_FROM_ADDRESS=notifications\@$hostname
SMTP_AUTH_METHOD=none
SMTP_OPENSSL_VERIFY_MODE=none
SMTP_ENABLE_STARTTLS=auto

STREAMING_CLUSTER_NUM=1
CONTENT

    if( $emailDomainBlacklist ) {
        $content .= <<CONTENT;
EMAIL_DOMAIN_BLACKLIST=$emailDomainBlacklist
CONTENT
    }
    if( $emailDomainWhitelist ) {
        $content .= <<CONTENT;
EMAIL_DOMAIN_WHITELIST=$emailDomainWhitelist
CONTENT
    }
# Only allow registrations with the following e-mail domains
# EMAIL_DOMAIN_WHITELIST=example1.com|example2.de|etc

    UBOS::Utils::saveFile( $name, $content, 0400, 'mastodon', 'mastodon' );
}
if( 'undeploy' eq $operation ) {
    UBOS::Utils::deleteFile( $name );
}

1;
