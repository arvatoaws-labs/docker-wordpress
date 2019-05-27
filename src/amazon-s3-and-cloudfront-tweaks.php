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
     * This filter allows you to alter the local domains that can be filtered to S3 URLs.
     *
     * If you're dynamically altering the site's URL with something like the following...
     *
     * define( 'WP_SITEURL', 'http://' . $_SERVER['HTTP_HOST'] );
     * define( 'WP_HOME', 'http://' . $_SERVER['HTTP_HOST'] );
     *
     * ... then you'll need to append all known domains with this filter so that
     * any URLs inserted into content with an alternate domain are matched as local.
     *
     * @param array $domains
     *
     * @return array
     */
    function local_domains( $domains ) {
        $mydomains = array();
        
        if (getenv('WP_OFFLOAD_LOCAL_DOMAINS')) {
          $mydomains = explode(' ', getenv('WP_OFFLOAD_LOCAL_DOMAINS'));
        }
        
        if ($_SERVER['HTTP_HOST']) {
          $mydomains[] = $_SERVER['HTTP_HOST'];
        }
        
        return array_unique(array_merge($domains, $mydomains));
    }
}

new Amazon_S3_and_CloudFront_Tweaks();