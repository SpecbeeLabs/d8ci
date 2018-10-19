FROM php:7.1-apache-stretch

# Common
RUN apt-get update \
  && apt-get install -y \
  openssh-client \
  git \
  wget \
  gnupg \
  libjpeg-dev \
  libpng-dev \
  && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
  && docker-php-ext-install \
    gd \
    mbstring \
    opcache \
    zip

# Remove the memory limit for the CLI only.
RUN echo 'memory_limit = -1' > /usr/local/etc/php/php-cli.ini

# Change directory to /tmp
RUN chmod -R 777 /tmp
WORKDIR /tmp

# Install composer and put binary into $PATH
RUN curl -sS https://getcomposer.org/installer | php \
  && mv composer.phar /usr/local/bin/ \
  && ln -s /usr/local/bin/composer.phar /usr/local/bin/composer

# Put a turbo on composer.
RUN composer global require hirak/prestissimo

# Install PHPCS.
RUN composer global require drupal/coder --update-no-dev --no-suggest --prefer-dist ^8.2
RUN composer global require dealerdirect/phpcodesniffer-composer-installer
RUN ln -s /root/.composer/vendor/bin/phpcs /usr/bin/phpcs
# Set Drupal as default CodeSniffer Standard
RUN phpcs --config-set installed_paths /root/.composer/vendor/drupal/coder/coder_sniffer/ \
  && phpcs --config-set default_standard Drupal


# Change working directory to webroot
WORKDIR /var/www/html

# Clean up
RUN apt-get -y clean \
  && apt-get -y autoclean \
  && apt-get -y autoremove
