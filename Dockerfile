FROM ubuntu:18.04

LABEL name="wordpress docker container" \
     version="latest"

ARG DEBIAN_FRONTEND=noninteractive

ARG DUMB_INIT_VERSION=1.2.2
ARG WP_CLI_VERSION=2.2.0
ARG WP_CORE_VERSION=5.1.1
ARG WP_PLUGIN_OFFLOAD_VERSION=2.1.1
ARG WP_PLUGIN_AMAZON_VERSION=1.0.5

ENV MYSQL_DATABASE=wordpress \
    MYSQL_HOST=localhost \
    MYSQL_PORT=3306 \
    MYSQL_USER=root \
    MYSQL_PASSWORD=secert \
    REDIS_HOST=localhost \
    REDIS_PORT=6379

RUN apt-get update && apt-get install -y \
    php-xml \
    php-xmlrpc \
    php-curl \
    php-intl \
    php-mbstring \
    php-gd \
    php-zip \
    php-mysql \
    php-redis \
    php-fpm \
    nginx \
    wget \
    unzip \
    sudo \
    curl \
    mysql-client \
    && apt-get upgrade -y \
    && apt-get clean

# init
RUN wget -q https://github.com/Yelp/dumb-init/releases/download/v${DUMB_INIT_VERSION}/dumb-init_${DUMB_INIT_VERSION}_amd64.deb && \
  dpkg -i dumb-init_*.deb && rm dumb-init_*.deb

RUN wget -q https://github.com/wp-cli/wp-cli/releases/download/v${WP_CLI_VERSION}/wp-cli-${WP_CLI_VERSION}.phar && \
  chmod 755 wp-cli-${WP_CLI_VERSION}.phar && mv wp-cli-${WP_CLI_VERSION}.phar /usr/local/bin/wp

RUN mkdir /app && \
  cd /app && \
  /usr/local/bin/wp core download --allow-root --version=${WP_CORE_VERSION}

ADD src/wp-config.php /app/wp-config.php

RUN wget -q https://downloads.wordpress.org/plugin/amazon-web-services.${WP_PLUGIN_AMAZON_VERSION}.zip && \
  unzip amazon-web-services.${WP_PLUGIN_AMAZON_VERSION}.zip && \
  mv amazon-web-services /app/wp-content/plugins && \
  rm amazon-web-services.${WP_PLUGIN_AMAZON_VERSION}.zip

RUN wget -q https://downloads.wordpress.org/plugin/amazon-s3-and-cloudfront.${WP_PLUGIN_OFFLOAD_VERSION}.zip && \
  unzip amazon-s3-and-cloudfront.${WP_PLUGIN_OFFLOAD_VERSION}.zip && \
  mv amazon-s3-and-cloudfront /app/wp-content/plugins && \
  rm amazon-s3-and-cloudfront.${WP_PLUGIN_OFFLOAD_VERSION}.zip

WORKDIR /app

RUN chown -R www-data /var/lib/nginx
RUN mkdir -p /app/wp-content/uploads && chown -R www-data /app/wp-content/uploads

ADD install-core.sh /install-core.sh
ADD activate-plugins.sh /activate-plugins.sh
ADD run-nginx.sh /run-nginx.sh
ADD run-php.sh /run-php.sh
ADD run-cron.sh /run-cron.sh
ADD nginx.conf /etc/nginx/nginx.conf
ADD fpm.conf /etc/php/7.2/fpm/php-fpm.conf
ADD fpm-pool.conf /etc/php/7.2/fpm/pool.d/www.conf

RUN chmod 755 /*.sh

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

USER www-data

#EXPOSE 8080/tcp