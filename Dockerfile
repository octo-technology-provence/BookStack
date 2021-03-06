FROM php:7.1-apache-stretch

ENV BOOKSTACK=BookStack \
    BOOKSTACK_VERSION=0.25.5 \
    BOOKSTACK_HOME="/var/www/bookstack"

RUN apt-get update && apt-get install -y git zlib1g-dev libfreetype6-dev libjpeg62-turbo-dev libmcrypt-dev libpng-dev wget libldap2-dev libtidy-dev unzip\
   && docker-php-ext-install pdo pdo_mysql mbstring zip tidy \
   && docker-php-ext-configure ldap \
   && docker-php-ext-install ldap \
   && docker-php-ext-configure gd --with-freetype-dir=usr/include/ --with-jpeg-dir=/usr/include/ \
   && docker-php-ext-install gd \
   && cd /var/www && curl -sS https://getcomposer.org/installer | php \
   && mv /var/www/composer.phar /usr/local/bin/composer \
   && wget https://github.com/octo-technology-provence/BookStack/archive/v${BOOKSTACK_VERSION}.zip -O ${BOOKSTACK}.zip \
   && unzip ${BOOKSTACK}.zip && mv BookStack-${BOOKSTACK_VERSION} ${BOOKSTACK_HOME} && rm ${BOOKSTACK}.zip  \
   && cd $BOOKSTACK_HOME && composer install \
   && chown -R www-data:www-data $BOOKSTACK_HOME \
   && apt-get -y autoremove \
   && apt-get clean \
   && rm -rf /var/lib/apt/lists/* /var/tmp/* /etc/apache2/sites-enabled/000-*.conf

#COPY php.ini /usr/local/etc/php/php.ini
COPY bookstack.conf /etc/apache2/sites-enabled/bookstack.conf
RUN a2enmod rewrite

COPY docker-entrypoint.sh /
RUN chmod 777 /docker-entrypoint.sh

WORKDIR $BOOKSTACK_HOME

EXPOSE 80

VOLUME ["$BOOKSTACK_HOME/public/uploads","$BOOKSTACK_HOME/public/storage"]

ENTRYPOINT ["/docker-entrypoint.sh"]