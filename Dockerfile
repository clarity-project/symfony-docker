FROM php:5.6-apache

MAINTAINER Shishko Vladislav <13thmerlin@gmail.com>

RUN apt-get update && \
    apt-get install -y libmcrypt-dev libpq-dev netcat php5-mysql php5-curl php5-intl

RUN docker-php-ext-install \
        mcrypt \
        bcmath \
        mbstring \
        zip \
        opcache \
        pdo pdo_mysql

RUN usermod -u 1000 www-data

RUN yes | pecl install apcu xdebug-beta \
        && echo "extension=$(find /usr/local/lib/php/extensions/ -name apcu.so)" > /usr/local/etc/php/conf.d/apcu.ini \
        && echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini \
        && echo "xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/xdebug.ini \
        && echo "xdebug.remote_autostart=on" >> /usr/local/etc/php/conf.d/xdebug.ini \
        && echo "xdebug.remote_connect_back=on" >> /usr/local/etc/php/conf.d/xdebug.ini

COPY docker-config/php/php.ini /usr/local/etc/php/

ENV APACHE_SERVERADMIN admin@localhost
ENV APACHE_SERVERNAME sd
ENV APACHE_SERVERALIAS www.sd
ENV APACHE_DOCUMENTROOT /var/www/html/web
ENV APACHE_LOG_DIR /var/log/apache2

#add apache configuration for symfony web folder
ADD docker-config/apache/httpd.conf /etc/apache2/sites-available/001-default.conf
RUN ln -s /etc/apache2/sites-available/001-default.conf /etc/apache2/sites-enabled/

#mysql config file
COPY docker-config/mysql/my.cnf /etc/mysql/my.cnf

#copy sources to apache work dir
COPY . /var/www/html/