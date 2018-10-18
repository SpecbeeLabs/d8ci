FROM php:7.1-apache-stretch

# Common
RUN apt-get update \
  && apt-get install -y \
  openssh-client \
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

# Change working directory to webroot
WORKDIR /var/www/html

# Clean up
RUN apt-get -y clean \
  && apt-get -y autoclean \
  && apt-get -y autoremove
