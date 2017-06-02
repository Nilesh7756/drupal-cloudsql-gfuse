FROM almdemo/php:5.5.24-fpm

ENV NGINX_VERSION 1.10.2-1~jessie

RUN echo 'deb http://packages.dotdeb.org jessie all' >> /etc/apt/sources.list  \
    && echo 'deb-src http://packages.dotdeb.org jessie all' >> /etc/apt/sources.list \
    && curl -Ss https://www.dotdeb.org/dotdeb.gpg | apt-key add - \
    && echo 'deb http://nginx.org/packages/debian/ jessie nginx' >> /etc/apt/sources.list  \
    && echo 'deb-src http://nginx.org/packages/debian/ jessie nginx' >> /etc/apt/sources.list \
    && curl -Ss http://nginx.org/keys/nginx_signing.key | apt-key add - \
    && apt-get update \ 
    && apt-get install -y net-tools mysql-client\
    && apt-get install  --no-install-recommends --no-install-suggests -y  \ 
                                                nginx=$NGINX_VERSION \
    && rm -rf /var/lib/apt/lists/*

RUN echo "deb http://packages.cloud.google.com/apt gcsfuse-jessie main" >> /etc/apt/sources.list.d/gcsfuse.list \
    && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
    && apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -y gcsfuse libfuse2 fuse \
    && rm -rf /var/lib/apt/lists/*

ADD ./default.conf  /etc/nginx/conf.d/default.conf
ADD ./settings.php  /var/www/sites/default/settings.php
COPY health_check /var/www/sites/all/modules/

RUN mkdir /var/www/sites/default/files

WORKDIR /var/www/


ENV DRUPAL_VERSION 7.54
ENV DRUPAL_MD5 3068cbe488075ae166e23ea6cd29cf0f

##Drupal nstallation
RUN curl -fSL "https://ftp.drupal.org/files/projects/drupal-${DRUPAL_VERSION}.tar.gz" -o drupal.tar.gz \
	&& echo "${DRUPAL_MD5} *drupal.tar.gz" | md5sum -c - \
	&& tar -xz --strip-components=1 -f drupal.tar.gz \
	&& rm drupal.tar.gz \
	&& chown -R www-data:www-data sites \
        && chmod 777 -R sites

EXPOSE 80

COPY run.sh /usr/local/bin/run
RUN chmod +x /usr/local/bin/run
CMD ["/usr/local/bin/run"]
