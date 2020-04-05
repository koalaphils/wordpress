#!/bin/bash
set +e
set -x

## Restore from backup if there is a backup
if [ -d /backup ]; then
  rsync -arShCiu --include 'wp-config.php' --include 'wp-content**' --include '.htaccess' --exclude '*' /backup/ /var/www/html
fi

## Check if WordPress is already installed
su -s /bin/bash www-data -c "wp core is-installed"
if [ "$?" != "0" ]; then
  echo WordPress not yet installed, will install

  su -s /bin/bash www-data -c "wp --url=\"${WORDPRESS_URL}\" --title=\"${WORDPRESS_TITLE}\" --admin_user=\"${WORDPRESS_ADMIN_USER}\" --admin_password=\"${WORDPRESS_ADMIN_PASS}\" --admin_email=\"${WORDPRESS_ADMIN_EMAIL}\" --skip-email core install \
    && wp option set permalink_structure '/%postname%/' \
    && wp option set blog_public 0 \
    && wp plugin install --activate `cat /usr/src/plugins/plugins.txt | awk '{print $1}' ORS=' '` `find /usr/src/plugins -name '*.zip' | awk '{print \"\\\"\" $1 \"\\\"\"}' ORS=' '`"

  ## Install Themes
  su -s /bin/bash www-data -c "wp theme install --force `find /usr/src/themes -name '*.zip' | awk '{print \"\\\"\" $1 \"\\\"\"}' ORS=' '`"
  if [ -f /usr/src/themes/default.txt ]; then
    su -s /bin/bash www-data -c "wp theme activate `cat /usr/src/themes/default.txt`"
  fi

else
  echo WordPress is already installed.
fi

## Schedule backup
if [ -d /backup ]; then
  ##Initial sync to backup
  rsync -arShCiu --include 'wp-config.php' --include 'wp-content**' --include '.htaccess' --exclude '*' /var/www/html/ /backup
  ##Scheduled backup
  echo "${WORDPRESS_BACKUP} www-data rsync -arShCiu --include 'wp-config.php' --include 'wp-content**' --include '.htaccess' --exclude '*' /var/www/html/ /backup" | tee /cronjob
  crontab /cronjob
  cron -L 8
fi

exec "$@"
