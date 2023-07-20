FROM debian:bullseye-slim

# Should be no need to modify beyond this point, unless you need to patch something or add more apps
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
RUN apt-get update && apt-get upgrade -y && apt-get install -y wget gnupg2
RUN bash -c 'echo "deb https://packages.sury.org/php/ bullseye main" > /etc/apt/sources.list.d/sury-php.list'
RUN bash -c 'wget -qO - https://packages.sury.org/php/apt.gpg | apt-key add -'
RUN apt-get update && apt-get install -y  \
  apache2 \
  busybox \
  bzip2 \
  curl \
  libapache2-mod-php8.0 \
  libmagickcore-6.q16-6-extra \
  make \
  mariadb-client \
  npm \
  patch \
  php8.0-apcu \
  php8.0-bcmath \
  php8.0-curl \
  php8.0-gd \
  php8.0-gmp \
  php8.0-imagick \
  php8.0-intl \
  php8.0-mbstring \
  php8.0-mysql \
  php8.0-mysqli \
  php8.0-pdo \
  php8.0-redis \
  php8.0-xml \
  php8.0-zip \
  redis-tools \
  ssl-cert \
  unzip \
  vim

RUN set -ex; \
    \
    mkdir -p /var/spool/cron/crontabs; \
    echo '* * * * * php -f /var/www/html/replicationcron.php' > /var/spool/cron/crontabs/www-data


RUN apt update && apt install ssl-cert
RUN a2enmod rewrite ssl

COPY --chown=root:root ./000-default.conf /etc/apache2/sites-available/
COPY --chown=root:root ./mysql.dmp /
RUN usermod -a -G tty www-data

RUN mkdir /var/www/html/data; \
    chown -R www-data:root /var/www; \
    chmod -R g=u /var/www

COPY ./lookup-server-1.1.2.tar.gz /tmp
RUN cd /tmp && tar xfv lookup-server-1.1.2.tar.gz && mv lookup-server/server/* /var/www/html

