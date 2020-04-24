<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the
 * installation. You don't have to use the web site, you can
 * copy this file to "wp-config.php" and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * MySQL settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://codex.wordpress.org/Editing_wp-config.php
 *
 * @package WordPress
 */

// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */

define('DB_NAME', getenv('MYSQL_DATABASE'));

/** MySQL database username */
define('DB_USER', getenv('MYSQL_USER'));

/** MySQL database password */
define('DB_PASSWORD', getenv('MYSQL_PASSWORD'));

/** MySQL hostname */
define('DB_HOST', getenv('MYSQL_HOST'));

/** Database Charset to use in creating database tables. */
define('DB_CHARSET', 'utf8');

/** The Database Collate type. Don't change this if in doubt. */
define('DB_COLLATE', '');

/*
 * Use iam profiles
 */
if(getenv('AWS_ACCESS_KEY') && getenv('AWS_SECRET_KEY')) {
    $s3_settings = array(
        'provider' => 'aws',
        'access-key-id' => getenv('AWS_ACCESS_KEY'),
        'secret-access-key' => getenv('AWS_SECRET_KEY'),
        'use-server-roles' => false
    );
} else {
    define('AWS_USE_EC2_IAM_ROLE', true);
    $s3_settings = array(
        'provider' => 'aws',
        'use-server-roles' => true
    );
}

/*
 * S3 HTTPS handling
 */
$s3_force_https = true;
if(getenv('USE_MINIO')) {
    $s3_force_https = false;
}

/*
 * Only run cronjobs as real cronjobs in the backend
 */
define('DISABLE_WP_CRON', 'true');

/*
 * Force HTTP Host
 */
if(getenv('WP_FORCE_HOST')) {
    $_SERVER['HTTP_HOST'] = getenv('WP_FORCE_HOST');
    $_SERVER['SERVER_NAME']  = getenv('WP_FORCE_HOST');
}

/*
 * Support for wp cli and others
 */
if(!isset($_SERVER['HTTP_HOST'])) {
    if(getenv('WP_DEFAULT_HOST')) {
        $_SERVER['HTTP_HOST'] = getenv('WP_DEFAULT_HOST');
        $_SERVER['SERVER_NAME']  = getenv('WP_DEFAULT_HOST');
    } elseif (defined( 'WP_CLI' )  && WP_CLI) {
        $_SERVER['HTTP_HOST'] = 'wp-cli.org';
        $_SERVER['SERVER_NAME'] = 'wp-cli.org';
    }
}

/*
 * Handle multi domain into single instance of wordpress installation
 */
$proto = 'http';
if ((isset($_SERVER['HTTPS']) && (($_SERVER['HTTPS'] == 'on') || ($_SERVER['HTTPS'] == '1'))) || (isset($_SERVER['HTTPS']) && $_SERVER['SERVER_PORT'] == 443)) {
    $proto = 'https';
    $_SERVER['HTTPS'] = true;
} elseif (!empty($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https' || !empty($_SERVER['HTTP_X_FORWARDED_SSL']) && $_SERVER['HTTP_X_FORWARDED_SSL'] == 'on') {
    $proto = 'https';
    $_SERVER['HTTPS'] = true;
} else {
    $_SERVER['HTTPS'] = false;
}

define('WP_SITEURL', $proto . '://' . $_SERVER['HTTP_HOST']);
define('WP_HOME', $proto . '://' . $_SERVER['HTTP_HOST']);

/*
 * WP Super Cache setting
 */
#define('WPCACHEHOME', dirname(__FILE__) . '/wp-content/plugins/wp-super-cache/');
#define('WP_CACHE', true);

/*
 * WP Offload setting
 */
define( 'AS3CF_SETTINGS', serialize( array_merge($s3_settings, array(
    // S3 bucket to upload files
    'bucket' => getenv('WP_OFFLOAD_BUCKET'),
    // S3 bucket region (e.g. 'us-west-1' - leave blank for default region)
    'region' => getenv('WP_OFFLOAD_REGION'),
    // Automatically copy files to S3 on upload
    'copy-to-s3' => true,
    // Rewrite file URLs to S3
    'serve-from-s3' => true,
    // S3 URL format to use ('path', 'cloudfront')
    'domain' => getenv('WP_OFFLOAD_DOMAIN'),
    // Custom domain if 'domain' set to 'cloudfront'
    'cloudfront' => getenv('WP_OFFLOAD_CLOUDFRONT'),
    // Enable object prefix, useful if you use your bucket for other files
    'enable-object-prefix' => true,
    // Object prefix to use if 'enable-object-prefix' is 'true'
    'object-prefix' => 'wp-content/uploads/',
    // Organize S3 files into YYYY/MM directories
    'use-yearmonth-folders' => true,
    // Serve files over HTTPS
    'force-https' => $s3_force_https,
    // Remove the local file version once offloaded to S3
    'remove-local-file' => true,
    // Append a timestamped folder to path of files offloaded to S3
    'object-versioning' => true,
) ) ) );

/**#@+
 * Authentication Unique Keys and Salts.
 *
 * Change these to different unique phrases!
 * You can generate these using the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}
 * You can change these at any point in time to invalidate all existing cookies. This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define('AUTH_KEY',         '2c]o5=o@|9>;##[]pI^:.-`_aM_x/ O2[&>47B.raECxz4{9V-r=|gx7i#j-!{/t');
define('SECURE_AUTH_KEY',  '-{!^|9EluQdYL~~|i>rRe |MQ+m:qp?w#h]#G=B]DcJ/0F&QY6tR+yB{7NZIy?|l');
define('LOGGED_IN_KEY',    '-/ZhtSWq~.;Zm+#D+PN,c<lI:b]X4+#ui1so|<3c#B@li;-?|R`}/e)F/dE+op5!');
define('NONCE_KEY',        'hB2#Kq8DdkFFU8(!DEY:Y/P9k+dGsd*:H]Mn,iLi_i+H-V$*PMh65j3=g28*JuAq');
define('AUTH_SALT',        'dXbM(B)~gHH/wr~fS`1=f~vi =r%-eBNxo|%+a8QUN~6t+>~g+1/>v+<|t}&D&JX');
define('SECURE_AUTH_SALT', 'W|2E~+2<t{G-sPIL:CCOe-u4}F]/xzf4+,^~B-5/)/:%E4_fKXi/63fUk`Z*H(bV');
define('LOGGED_IN_SALT',   'Z-BH-MS-jl+kY!uyZ.k[DLdRY&hdp<jd*pJAbvv:Y<^JusUgIZ}Nt~5IyGPt_YWt');
define('NONCE_SALT',       'FgMc6|.Z$.Wu7G=uQ-#,+jsPz3vg{4A=ynoV14qDGmx?KQNo P->{I?eJYHgj`(2');

/**#@-*/

/**
 * WordPress Database Table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix  = 'wp_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the Codex.
 *
 * @link https://codex.wordpress.org/Debugging_in_WordPress
 */
define('WP_DEBUG', getenv('WP_DEBUG') ? true : false);
define('WP_DEBUG_LOG', getenv('WP_DEBUG_LOG') ? true : false);
define('WP_DEBUG_DISPLAY', getenv('WP_DEBUG_LOG') ? true : false);

/* That's all, stop editing! Happy blogging. */

/** Absolute path to the WordPress directory. */
if ( !defined('ABSPATH') )
	define('ABSPATH', dirname(__FILE__) . '/');

/** Sets up WordPress vars and included files. */
require_once(ABSPATH . 'wp-settings.php');
