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

COPY ./lookup-server-1.1.0.tar.gz /tmp
RUN cd /tmp && tar xfv lookup-server-1.1.0.tar.gz && mv lookup-server/server/* /var/www/html/ 

