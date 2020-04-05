# WordPress Installation

##Description
This repository is to help speedup the installation and restoration of WordPress site using docker. This should help WordPress mainteners to install the plugins and themes that they would normally install across various WordPress sites they maintain.

### Additional Environment Variables
We have added additional ENV variables so we could set some defaults for installation. The following are the new variables:

* WORDPRESS_URL - this is the WordPress URL of your site
* WORDPRESS_TITLE - this would be the title of the site
* WORDPRESS_ADMIN_USER - this would be the initial admin username
* WORDPRESS_ADMIN_PASS - this would be the password of the admin user
* WORDPRESS_ADMIN_EMAIL - this should be the email of the admin user
* WORDPRESS_BACKUP - this is the schedule of the backup in cron standard format

### Additional volume
An additional volume will have to be defined in case you want to use automated backup to another disk/volume for the `wp-content` and `.htaccess` and should be mounted to `/backup`.

### How it works
The base image for the container is the [wordpress official image](https://hub.docker.com/_/wordpress/).

The following are the steps it does:

1. The script checks for backup directory and restore it on /var/www/html if there is any
    1. If the WordPress site is already installed, then it will just sync the `/var/www/html` to the `/backup` directory
    1. Otherwise, it will install WordPress.
1. Installation of WordPress is a series of the following steps:
    1. Install the WordPress core using the new Environment variables specified above
    1. Initially set some `wp_options` so the site is not discoverable yet and to set `permalink` settings
    1. Install Plugins
    1. Install Themes
    1. Set default theme.
    
### Configuring default Plugins and Themes
`plugins/pluginx.txt` a list of all the plugins you wanted to get installed by default one for each line
`themes/default.txt` the default theme to be used for the installation

Additionally, you can add some custom `zip` files on plugins and themes directory for them to be installed automatically. 

### How to get started?
A `docker-compose.yml` has been added to get you started.