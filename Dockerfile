FROM koalaphils/php:8-fpm

LABEL maintainer="admin@koalaphils.com" \
    version="2.0" \
    description="Automated plugins and themes installation for WordPress"
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    cron \
    rsync \
  && docker-php-ext-install -j "$(nproc)" mysqli \
  ;
COPY opt/php/*.ini /usr/local/etc/php/conf.d/
COPY --from=wordpress:cli /usr/local/bin/wp /usr/local/bin/wp
COPY --from=wordpress:fpm /usr/src /usr/src
COPY --from=wordpress:fpm /usr/local/bin/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY themes /usr/src/themes
COPY plugins /usr/src/plugins

RUN sed -i 's/exec\s*\"\$\@\"/source \/usr\/local\/bin\/post-install.sh/g' /usr/local/bin/docker-entrypoint.sh
COPY post-install.sh /usr/local/bin/post-install.sh
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["php-fpm"]
