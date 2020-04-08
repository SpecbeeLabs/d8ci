FROM php:7.2-apache-stretch

# Common
RUN apt-get update && apt-get install -y \
  openssh-client \
  git \
  gnupg \
  imagemagick \
  libjpeg-dev \
  libpng-dev \
  libmagickwand-dev --no-install-recommends \
  mysql-client \
  wget \
  unzip \
  && docker-php-ext-configure \
    gd --with-png-dir=/usr --with-jpeg-dir=/usr \
  && docker-php-ext-install \
    gd \
    mbstring \
    mysqli \
    opcache \
    pdo \
    pdo_mysql \
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

# Change docroot since we use Composer Drupal project.
RUN sed -ri -e 's!/var/www/html!/var/www/html/docroot!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www!/var/www/html/docroot!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Install Robo CI.
RUN wget https://robo.li/robo.phar
RUN chmod +x robo.phar && mv robo.phar /usr/local/bin/robo

# Install Dockerize.
ENV DOCKERIZE_VERSION v0.6.0
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz

# Install ImageMagic to take screenshots.
RUN pecl install imagick \
    && docker-php-ext-enable imagick

# Install Chrome browser.
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
RUN dpkg -i google-chrome-stable_current_amd64.deb; apt-get -fy install

# Change working directory to webroot
WORKDIR /var/www/html

# Clean up
RUN apt-get -y clean \
  && apt-get -y autoclean \
  && apt-get -y autoremove
