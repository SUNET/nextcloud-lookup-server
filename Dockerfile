FROM php:7.4-apache-bullseye


RUN set -ex; \
    \
    mkdir -p /var/spool/cron/crontabs; \
    echo '* * * * * php -f /var/www/html/replicationcron.php' > /var/spool/cron/crontabs/www-data

RUN docker-php-ext-install mysqli pdo pdo_mysql

RUN apt update && apt install ssl-cert
RUN a2enmod rewrite ssl 

COPY --chown=root:root ./000-default.conf /etc/apache2/sites-available/
COPY --chown=root:root ./mysql.dmp /
RUN usermod -a -G tty www-data

RUN mkdir /var/www/html/data; \
    chown -R www-data:root /var/www; \
    chmod -R g=u /var/www

ENV LOOKUP_VERSION 1.1.0

ADD --chown=www-data:root https://github.com/nextcloud/lookup-server/archive/refs/tags/v${LOOKUP_VERSION}.tar.gz .

RUN tar -xzf v${LOOKUP_VERSION}.tar.gz lookup-server-${LOOKUP_VERSION}/server --strip-components=2; \
    rm v${LOOKUP_VERSION}.tar.gz
