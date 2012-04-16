# postinstall.sh created from Mitchell's official lucid32/64 baseboxes

date > /etc/vagrant_box_build_time

# Install Percona
# http://www.percona.com/doc/percona-server/5.5/installation/apt_repo.html
gpg --keyserver  hkp://keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A
gpg -a --export CD2EFD2A | sudo apt-key add -

echo deb http://repo.percona.com/apt lenny main >> /etc/apt/sources.list
echo deb-src http://repo.percona.com/apt lenny main >> /etc/apt/sources.list

# Apt-install various things necessary for Ruby, guest additions,
# etc., and remove optional things to trim down the machine.
apt-get -y update
apt-get -y upgrade
apt-get -y install linux-headers-$(uname -r) build-essential
apt-get -y install zlib1g-dev libssl-dev libreadline-gplv2-dev
apt-get -y install git-core

# Automatic password
# http://stackoverflow.com/questions/9743828/installing-percona-mysql-unattended-on-ubuntu
echo percona-server-server-5.5 percona-server-server-5.5/root_password password $dbpass | debconf-set-selections
echo percona-server-server-5.5 percona-server-server-5.5/root_password_again password $dbpass | debconf-set-selections
export DEBIAN_FRONTEND=noninteractive
apt-get -y install percona-server-server-5.5

apt-get -y install nginx
apt-get -y install imagemagick php5-fpm php5-mysql php5-common php5 php5-dev php-pear php5-curl php5-gd php5-imagick php5-mcrypt php5-suhosin
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

# If you want to compile and install nginx from source, issue the following
# commands to install the prerequisites:
#apt-get -y install libpcre3-dev libssl-dev sudo
apt-get clean

# Setup sudo to allow no-password sudo for "admin"
cp /etc/sudoers /etc/sudoers.orig
sed -i -e '/Defaults\s\+env_reset/a Defaults\texempt_group=admin' /etc/sudoers
sed -i -e 's/%admin ALL=(ALL) ALL/%admin ALL=NOPASSWD:ALL/g' /etc/sudoers

# Install NFS client
apt-get -y install nfs-common

# Install Ruby from source in /opt so that users of Vagrant
# can install their own Rubies using packages or however.
wget http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.2-p290.tar.gz
tar xvzf ruby-1.9.2-p290.tar.gz
cd ruby-1.9.2-p290
./configure --prefix=/opt/ruby
make
make install
cd ..
rm -rf ruby-1.9.2-p290

# Install RubyGems 1.7.2
wget http://production.cf.rubygems.org/rubygems/rubygems-1.8.11.tgz
tar xzf rubygems-1.8.11.tgz
cd rubygems-1.8.11
/opt/ruby/bin/ruby setup.rb
cd ..
rm -rf rubygems-1.8.11

# Installing chef & Puppet
/opt/ruby/bin/gem install chef --no-ri --no-rdoc
/opt/ruby/bin/gem install puppet --no-ri --no-rdoc

# Add /opt/ruby/bin to the global path as the last resort so
# Ruby, RubyGems, and Chef/Puppet are visible
echo 'PATH=$PATH:/opt/ruby/bin/'> /etc/profile.d/vagrantruby.sh

# Installing vagrant keys
mkdir /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
cd /home/vagrant/.ssh
wget --no-check-certificate 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' -O authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant /home/vagrant/.ssh

# Installing the virtualbox guest additions
VBOX_VERSION=$(cat /home/vagrant/.vbox_version)
cd /tmp
wget http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso
mount -o loop VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt

rm VBoxGuestAdditions_$VBOX_VERSION.iso

# Remove items used for building, since they aren't needed anymore
apt-get -y remove linux-headers-$(uname -r) build-essential
apt-get -y autoremove

# Zero out the free space to save space in the final image:
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

# Removing leftover leases and persistent rules
echo "cleaning up dhcp leases"
rm /var/lib/dhcp3/*

# Make sure Udev doesn't block our network
# http://6.ptmc.org/?p=164
echo "cleaning up udev rules"
rm /etc/udev/rules.d/70-persistent-net.rules
mkdir /etc/udev/rules.d/70-persistent-net.rules
rm -rf /dev/.udev/
rm /lib/udev/rules.d/75-persistent-net-generator.rules

echo "Adding a 2 sec delay to the interface up, to make the dhclient happy"
echo "pre-up sleep 2" >> /etc/network/interfaces
exit
