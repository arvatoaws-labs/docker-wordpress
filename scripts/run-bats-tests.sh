#!/usr/bin/env bats

@test "Check that we have a /tmp directory" {
    run stat /tmp
    [ $status = 0 ]
}

# @test "Check that we get redirected from http to https" {
#     run curl -A bats-test -I http://$WP_DEFAULT_HOST/
# 	[ $status = 0 ]
# 	[[ $output =~ "301" ]]
# }

@test "Check that we can fetch the startpage" {
    run curl -A bats-test -I https://$WP_DEFAULT_HOST/
    [ $status = 0 ]
    [[ $output =~ "200" ]]
}

@test "Check that we get the correct content of the startpage" {
    run curl -A bats-test https://$WP_DEFAULT_HOST/
    [ $status = 0 ]
    [[ $output =~ "WordPress" ]]
}

@test "Check that we can fetch the loginpage" {
    run curl -A bats-test -I https://$WP_DEFAULT_HOST/wp-login.php
    [ $status = 0 ]
    [[ $output =~ "200" ]]
}

@test "Check that we cannot fetch the wp-config.conf" {
    run curl -A bats-test -I https://$WP_DEFAULT_HOST/wp-config.php
    [ $status = 0 ]
    [[ $output =~ "403" ]]
}

@test "Check that we cannot fetch the wp-settings.conf" {
    run curl -A bats-test -I https://$WP_DEFAULT_HOST/wp-settings.php
    [ $status = 0 ]
    [[ $output =~ "403" ]]
}

@test "Check that we cannot fetch the readme.html" {
    run curl -A bats-test -I https://$WP_DEFAULT_HOST/readme.html
    [ $status = 0 ]
    [[ $output =~ "403" ]]
}

@test "Check that we cannot fetch the license.html" {
    run curl -A bats-test -I https://$WP_DEFAULT_HOST/license.html
    [ $status = 0 ]
    [[ $output =~ "403" ]]
}
