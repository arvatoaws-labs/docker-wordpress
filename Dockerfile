FROM ubuntu:18.04

LABEL name="wordpress docker container" \
     version="latest"

ARG DEBIAN_FRONTEND=noninteractive

ARG DUMB_INIT_VERSION=1.2.2
ARG WP_CLI_VERSION=2.2.0
ARG WP_CORE_VERSION=5.1.1
ARG WP_PLUGIN_OFFLOAD_VERSION=2.1.1
ARG WP_PLUGIN_AMAZON_VERSION=1.0.5

ENV APACHE_MIN_CHILDS=1 \
    APACHE_MAX_CHILDS=50 \
    APACHE_MIN_CHILDS_SPARE=1 \
    APACHE_MAX_CHILDS_SPARE=5 \
    APACHE_SERVER_NAME=wordpress.loc \
    APACHE_SERVER_ADMIN=webmaster@wordpress.loc \
    PHP_MAX_POST_SIZE=60M \
    PHP_MAX_UPLOAD_SIZE=50M \
    PHP_MAX_UPLOADS=10 \
    PHP_MAX_EXECUTION_ZIME=30 \
    MYSQL_DATABASE=wordpress \
    MYSQL_HOST=localhost \
    MYSQL_PORT=3306 \
    MYSQL_USER=root \
    MYSQL_PASSWORD=secert \
    REDIS_HOST=localhost \
    REDIS_PORT=6379 \
    DATA_RESET=false \
    DATA_MIGRATE=false

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

# ADD run.sh /run.sh
# ADD reset.sh /reset.sh
# ADD migrate.sh /migrate.sh
# RUN chmod 700 /*.sh

# CMD ["dumb-init", "/run.sh"]

# EXPOSE 80/tcp
# EXPOSE 443/tcp

# HEALTHCHECK CMD curl -I 0.0.0.0:80