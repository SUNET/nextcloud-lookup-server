FROM debian:bookworm-slim

# Should be no need to modify beyond this point, unless you need to patch something or add more apps
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
  apache2 \
  busybox \
  bzip2 \
  curl \
  gnupg2 \
  libapache2-mod-php8.2 \
  libmagickcore-6.q16-6-extra \
  make \
  mariadb-client \
  npm \
  patch \
  php8.2-apcu \
  php8.2-bcmath \
  php8.2-curl \
  php8.2-gd \
  php8.2-gmp \
  php8.2-imagick \
  php8.2-intl \
  php8.2-mbstring \
  php8.2-mysql \
  php8.2-mysqli \
  php8.2-pdo \
  php8.2-redis \
  php8.2-xml \
  php8.2-zip \
  redis-tools \
  ssl-cert \
  unzip \
  vim \
  wget

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

