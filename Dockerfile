FROM nginx:alpine

MAINTAINER ksungcaya

# install bash some cleanup
RUN apk add --no-cache --virtual bash \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && echo "daemon off;" >> /etc/nginx/nginx.conf \
    && rm /etc/nginx/conf.d/default.conf

# Add configuration files
ADD conf/nginx.conf /etc/nginx/nginx.conf

# add custom site configuration
RUN mkdir -p /etc/nginx/sites-custom
ADD sites/* /etc/nginx/sites-custom/

RUN mkdir /docker-entrypoint-initdb.d

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
RUN ln -s usr/local/bin/docker-entrypoint.sh / # backwards compat
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 80 443

CMD ["nginx"]
