<?php
/*
Plugin Name: WP Offload S3 Tweaks
Plugin URI: http://github.com/deliciousbrains/wp-amazon-s3-and-cloudfront-tweaks
Description: WP Offload S3's filters to support ArvatoAWS wordpress architecture
Author: ArvatoAWS
Version: 1.0.0
Author URI: https://github.com/arvatoaws
*/
// Copyright (c) 2015 Delicious Brains. All rights reserved.
// Copyright (c) 2018 arvato Systems GmbH. All rights reserved.
//
// Released under the GPL license
// http://www.opensource.org/licenses/gpl-license.php
//
// **********************************************************************
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// **********************************************************************

class Amazon_S3_and_CloudFront_Tweaks {
    
    function __construct() {
        add_filter( 'as3cf_local_domains', array( $this, 'local_domains' ), 10, 1 );
        
        /*
		 * Custom S3 API Example: MinIO
		 * @see https://min.io/
		 */
        if(getenv('USE_MINIO')) {
		    add_filter( 'as3cf_aws_s3_client_args', array( $this, 'minio_s3_client_args' ) );
		    add_filter( 'as3cf_aws_get_regions', array( $this, 'minio_get_regions' ) );
		    add_filter( 'as3cf_aws_s3_url_domain', array( $this, 'minio_s3_url_domain' ), 10, 6 );
		    add_filter( 'as3cf_upload_acl', array( $this, 'minio_upload_acl' ), 10, 1 );
		    add_filter( 'as3cf_upload_acl_sizes', array( $this, 'minio_upload_acl' ), 10, 1 );
		    add_filter( 'as3cf_aws_s3_console_url', array( $this, 'minio_s3_console_url' ) );
		    add_filter( 'as3cf_aws_s3_console_url_prefix_param', array( $this, 'minio_s3_console_url_prefix_param' ) );
        }
    }

  /**
   * This filter allows you to alter the local domains that can be filtered to bucket URLs.
   *
   * If you're dynamically altering the site's URL with something like the following...
   *
   * define( 'WP_SITEURL', 'http://' . $_SERVER['HTTP_HOST'] );
   * define( 'WP_HOME', 'http://' . $_SERVER['HTTP_HOST'] );
   *
   * ... then you'll need to append all known domains with this filter so that
   * any URLs inserted into content with an alternate domain are matched as local.
   *
   * @handles `as3cf_local_domains`
   *
   * @param array $domains
   *
   * @return array
   *
   * Note: First entry in `$domains` *should* be akin to `siteurl`, but as returned by `wp_upload_dir()`.
   * This however can be altered by domain mapping plugins or custom code as shown above.
   * Therefore it's a good idea to "double down" and include configured domain as well as alternates here.
   */
    function local_domains( $domains ) {
        if (isset($_SERVER['HTTP_HOST'])) {
          $domains[] = $_SERVER['HTTP_HOST'];
        }

        // Example makes sure that the current multisite's canonical domain is included
        // in match check even if domain mapping etc. has changed the URL of site.
        if ( is_multisite() ) {
          $blog_details = get_blog_details();
          if ( false !== $blog_details && ! in_array( $blog_details->domain, $domains ) ) {
            $domains[] = $blog_details->domain;
          }
        }

        if (getenv('WP_OFFLOAD_LOCAL_DOMAINS')) {
          $domains = array_merge($domains, explode(' ', getenv('WP_OFFLOAD_LOCAL_DOMAINS')));
        }
        
        return $domains;
    }
    
	/*
	 * >>> MinIO Examples Start
	 */
	/**
	 * This filter allows you to adjust the arguments passed to the provider's service specific SDK client.
	 *
	 * The service specific SDK client is created from the initial provider SDK client, and inherits most of its config.
	 * The service specific SDK client is re-created more often than the provider SDK client for specific scenarios, so if possible
	 * set overrides in the provider client rather than service client for a slight improvement in performance.
	 *
	 * @see     https://docs.aws.amazon.com/aws-sdk-php/v3/api/class-Aws.S3.S3Client.html#___construct
	 * @see     https://docs.min.io/docs/how-to-use-aws-sdk-for-php-with-minio-server.html
	 *
	 * @handles `as3cf_aws_s3_client_args`
	 *
	 * @param array $args
	 *
	 * @return array
	 *
	 * Note: A good place for changing 'signature_version', 'use_path_style_endpoint' etc. for specific bucket/object actions.
	 */
	function minio_s3_client_args( $args ) {
		// Example changes endpoint to connect to a local MinIO server configured to use port 54321 (the default MinIO port is 9000).
		$args['endpoint'] = 'http://127.0.0.1:54321';
		// Example forces SDK to use endpoint URLs with bucket name in path rather than domain name as required by MinIO.
		$args['use_path_style_endpoint'] = true;
		return $args;
	}
	/**
	 * This filter allows you to add or remove regions for the provider.
	 *
	 * @handles `as3cf_aws_get_regions`
	 *
	 * @param array $regions
	 *
	 * @return array
	 *
	 * MinIO regions, like Immortals in Highlander, there can be only one.
	 */
	function minio_get_regions( $regions ) {
		$regions = array(
			'us-east-1' => 'Default',
		);
		return $regions;
	}
	/**
	 * This filter allows you to change the URL used for serving the files.
	 *
	 * @handles `as3cf_aws_s3_url_domain`
	 *
	 * @param string $domain
	 * @param string $bucket
	 * @param string $region
	 * @param int    $expires
	 * @param array  $args    Allows you to specify custom URL settings
	 * @param bool   $preview When generating the URL preview sanitize certain output
	 *
	 * @return string
	 */
	function minio_s3_url_domain( $domain, $bucket, $region, $expires, $args, $preview ) {
		// MinIO doesn't need a region prefix, and always puts the bucket in the path.
		return '127.0.0.1:54321/' . $bucket;
	}
	/**
	 * Normally these filters allow you to change the default Access Control List (ACL)
	 * permission for an original file and its thumbnails when offloaded to bucket.
	 * However, MinIO doesn't do ACLs and defaults to private. So while this filter handler
	 * doesn't change anything in the bucket, it does tell WP Offload Media it needs sign URLs.
	 * In this handler we're just accepting the ACL and not bothering with any other params
	 * from the two filters.
	 *
	 * @handles `as3cf_upload_acl`
	 * @handles `as3cf_upload_acl_sizes`
	 *
	 * @param string $acl defaults to 'public-read'
	 *
	 * @return string
	 *
	 * Note: Only enable this if you are happy with signed URLs and haven't changed the bucket's policy to "Read Only" or similar.
	 */
	function minio_upload_acl( $acl ) {
		return 'private';
	}
	/**
	 * This filter allows you to change the base URL used to take you to the provider's console from WP Offload Media's settings.
	 *
	 * @handles `as3cf_aws_s3_console_url`
	 *
	 * @param string $url
	 *
	 * @return string
	 */
	function minio_s3_console_url( $url ) {
		return 'http://127.0.0.1:54321/minio/';
	}
	/**
	 * The "prefix param" denotes what should be in the console URL before the path prefix value.
	 *
	 * For example, the default for AWS/S3 is "?prefix=".
	 *
	 * The prefix is usually added to the console URL just after the bucket name.
	 *
	 * @handles `as3cf_aws_s3_console_url_prefix_param`
	 *
	 * @param $param
	 *
	 * @return string
	 *
	 * MinIO just appends the path prefix directly after the bucket name.
	 */
	function minio_s3_console_url_prefix_param( $param ) {
		return '/';
	}
	/*
	 * <<< MinIO Examples End
	 */    
}

new Amazon_S3_and_CloudFront_Tweaks();
