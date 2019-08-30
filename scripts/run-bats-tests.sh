#!/usr/bin/env bats

@test "Check that we have a /tmp directory" {
	run stat /tmp
	[ $status = 0 ]
}

@test "Check that we get redirected from http to https" {
        run curl -I http://$WP_DEFAULT_HOST/
	[ $status = 0 ]
	[[ $output =~ "301" ]]
}

@test "Check that we can fetch the startpage of wordpress" {
        run curl -I https://$WP_DEFAULT_HOST/
	[ $status = 0 ]
	[[ $output =~ "200" ]]
}

@test "Check that we get the correct content of the startpage" {
        run curl https://$WP_DEFAULT_HOST/
         [[ $output =~ "doctype html" ]]
         [[ $output =~ "WordPress" ]]
}

@test "Check that we can fetch the loginpage of wordpress" {
        run curl -I https://$WP_DEFAULT_HOST/wp-login.php
	[ $status = 0 ]
	[[ $output =~ "200" ]]
}

@test "Check that we cannot fetch the wp-settings.conf of wordpress" {
        run curl -I https://$WP_DEFAULT_HOST/wp-settings.php
	[ $status = 0 ]
	[[ $output =~ "403" ]]
}

