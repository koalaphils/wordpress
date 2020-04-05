FROM wordpress:latest

LABEL maintainer="mdprotacio@outlook.com" \
    version="1.0" \
    description="Automated plugins and themes installation for WordPress"

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    cron \
    rsync \
  ;
COPY --from=wordpress:cli /usr/local/bin/wp /usr/local/bin/wp
COPY themes /usr/src/themes
COPY plugins /usr/src/plugins

RUN sed -i 's/exec\s*\"\$\@\"/source \/usr\/local\/bin\/post-install.sh/g' /usr/local/bin/docker-entrypoint.sh
COPY post-install.sh /usr/local/bin/post-install.sh
