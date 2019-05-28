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
}

new Amazon_S3_and_CloudFront_Tweaks();