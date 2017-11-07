FROM php:7.2-rc-apache-stretch
MAINTAINER Alexej Bondarenko <alexej.bondarenko@ersocon.net>

ENV PIWIK_VERSION 3.2.0

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        zip \
        unzip \
        wget \
        moreutils \
        dnsutils \
    && rm -rf /var/lib/apt/lists/*

# PHP gd module
RUN buildRequirements="libpng12-dev libjpeg-dev libfreetype6-dev" \
  && apt-get update && apt-get install -y ${buildRequirements} \
  && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/lib \
  && docker-php-ext-install gd \
  && apt-get purge -y ${buildRequirements} \
  && rm -rf /var/lib/apt/lists/*

# Additional PHP modules
RUN docker-php-ext-install pdo_mysql mbstring opcache

# PHP geoip module
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libgeoip-dev \
    && pecl install geoip \
    && echo "extension=geoip.so" > /usr/local/etc/php/conf.d/ext-geoip.ini \
    && rm -rf /var/lib/apt/lists/*
    
# GeoIP database
RUN wget -O misc/GeoIPCity.dat.gz http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz && \
    gunzip misc/GeoIPCity.dat.gz

    
CMD ["apache2-foreground"]
