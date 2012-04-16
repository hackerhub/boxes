#!/bin/bash

apt-get -y install drush

# Drupal config on nginx
cd /etc/nginx/conf.d/
sudo wget -c https://raw.github.com/gist/2388530/744b58d090c856e40ca931c00737ac40f5bffca5/php
sudo wget -c https://raw.github.com/gist/2388123/53a866c16388ba8589f51d462884743f0e2f4574/drupal

# Vhost training.dev
cd /etc/nginx/sites-available/
sudo wget -c https://raw.github.com/gist/2388457/a27ad8fbe1eb8e8c52082394a31dd03093b596e5/training.dev
sudo ln -s /etc/nginx/sites-available/training.dev /etc/nginx/sites-enabled/training.dev
echo "127.0.0.1     training.dev" >> /etc/hosts

# Reload services
/etc/init.d/nginx reload
/etc/init.d/php5-fpm force-reload