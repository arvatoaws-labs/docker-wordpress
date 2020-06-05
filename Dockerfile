FROM ubuntu:18.04

LABEL name="wordpress docker container" \
     version="5.3"

ARG DEBIAN_FRONTEND=noninteractive

ARG DUMB_INIT_VERSION=1.2.2
ARG WP_CLI_VERSION=2.4.0
ARG WP_CORE_VERSION=5.3.2
ARG WP_PLUGIN_OFFLOAD_S3_VERSION=2.3.2
ARG WP_PLUGIN_OFFLOAD_SES_VERSION=1.2.2
ARG WP_SCRIPTS_VERSION=0.9

ENV MYSQL_DATABASE=wordpress \
    MYSQL_HOST=localhost \
    MYSQL_PORT=3306 \
    MYSQL_USER=root \
    MYSQL_PASSWORD=secret \
    REDIS_HOST=localhost \
    REDIS_PORT=6379 \
    WP_CLI_PACKAGES_DIR=/opt/wp-cli-packages

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
    php-opcache \
    php-fpm \
    php-soap \
    php-imagick \
    nginx \
    wget \
    unzip \
    sudo \
    curl \
    bats \
    less \
    mysql-client && \
    apt-get upgrade -y && \
    apt-get clean && \
    wget -q https://github.com/Yelp/dumb-init/releases/download/v${DUMB_INIT_VERSION}/dumb-init_${DUMB_INIT_VERSION}_amd64.deb && \
    dpkg -i dumb-init_*.deb && rm dumb-init_*.deb

RUN wget -q https://github.com/wp-cli/wp-cli/releases/download/v${WP_CLI_VERSION}/wp-cli-${WP_CLI_VERSION}.phar && \
  chmod 755 wp-cli-${WP_CLI_VERSION}.phar && mv wp-cli-${WP_CLI_VERSION}.phar /usr/local/bin/wp && \
  mkdir /app && \
  cd /app && \
  /usr/local/bin/wp core download --allow-root --version=${WP_CORE_VERSION} && \
  wget -q https://downloads.wordpress.org/plugin/amazon-s3-and-cloudfront.${WP_PLUGIN_OFFLOAD_S3_VERSION}.zip && \
  unzip amazon-s3-and-cloudfront.${WP_PLUGIN_OFFLOAD_S3_VERSION}.zip && \
  mv amazon-s3-and-cloudfront /app/wp-content/plugins && \
  rm amazon-s3-and-cloudfront.${WP_PLUGIN_OFFLOAD_S3_VERSION}.zip && \
  wget -q https://downloads.wordpress.org/plugin/wp-ses.${WP_PLUGIN_OFFLOAD_SES_VERSION}.zip && \
  unzip wp-ses.${WP_PLUGIN_OFFLOAD_SES_VERSION}.zip && \
  mv wp-ses /app/wp-content/plugins && \
  rm wp-ses.${WP_PLUGIN_OFFLOAD_SES_VERSION}.zip && \
  mkdir -p /app/wp-content/languages && \
  cd /app/wp-content/languages && \
  wget -q https://downloads.wordpress.org/translation/core/${WP_CORE_VERSION}/de_DE.zip && \
  unzip de_DE.zip && \
  rm de_DE.zip && \
  chown -R www-data /var/lib/nginx && \
  mkdir -p /app/wp-content/uploads && \
  chown -R www-data /app/wp-content/uploads

RUN wget -q https://github.com/arvatoaws-labs/wp-scripts/archive/${WP_SCRIPTS_VERSION}.zip && \
  unzip ${WP_SCRIPTS_VERSION}.zip && \
  mv wp-scripts* /scripts && \
  rm ${WP_SCRIPTS_VERSION}.zip && \
  mkdir -p WP_CLI_PACKAGES_DIR && \
  wp package install git@github.com:arvatoaws-labs/wp-arvato-aws-s3-migrator.git --allow-root

WORKDIR /app

COPY src/wp-config.php /app/wp-config.php
COPY src/amazon-s3-and-cloudfront-tweaks.php /app/wp-content/plugins/amazon-s3-and-cloudfront-tweaks.php
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/fpm.conf /etc/php/7.2/fpm/php-fpm.conf
COPY conf/fpm-pool.conf /etc/php/7.2/fpm/pool.d/www.conf

RUN chmod 755 /scripts/*.sh

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

USER www-data

#EXPOSE 8080/tcp
