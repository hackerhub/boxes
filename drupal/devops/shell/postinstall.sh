#!/bin/bash

apt-get -y install drush

# Drupal config on nginx
cd /etc/nginx/conf.d/
sudo wget -c https://raw.github.com/gist/2388530/744b58d090c856e40ca931c00737ac40f5bffca5/php
sudo wget -c https://raw.github.com/gist/2388123/53a866c16388ba8589f51d462884743f0e2f4574/drupal

# Vhost training.dev
cd /etc/nginx/sites-available/
sudo wget -c https://raw.github.com/gist/2388457/a92f7a61192990c0fee30a15a0d13954d3644ebf/training.dev
sudo ln -s /etc/nginx/sites-available/training.dev /etc/nginx/sites-enabled/training.dev
echo "127.0.0.1     training.dev" >> /etc/hosts

# Vhost phpmyadmin.dev
cd /etc/nginx/sites-available/
sudo wget -c https://raw.github.com/gist/2415625/7d7a4faed70f9482162f0407f3fc515f9a23f9d4/phpmyadmin.dev
sudo ln -s /etc/nginx/sites-available/phpmyadmin.dev /etc/nginx/sites-enabled/phpmyadmin.dev
echo "127.0.0.1     phpmyadmin.dev" >> /etc/hosts

# Reload services
/etc/init.d/nginx reload
/etc/init.d/php5-fpm force-reload