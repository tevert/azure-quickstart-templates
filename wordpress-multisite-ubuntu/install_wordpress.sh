#!/bin/bash

apt-get -y update

echo "Installing WordPress"

# Set up a silent install of MySQL
dbpass=$3

export DEBIAN_FRONTEND=noninteractive
echo mysql-server-5.6 mysql-server/root_password password $dbpass | debconf-set-selections
echo mysql-server-5.6 mysql-server/root_password_again password $dbpass | debconf-set-selections

# Install the LAMP stack and WordPress
apt-get -y install apache2 mysql-server php5 php5-mysql wordpress

# Setup WordPress
gzip -d /usr/share/doc/wordpress/examples/setup-mysql.gz
bash /usr/share/doc/wordpress/examples/setup-mysql -n wordpress localhost

ln -s /usr/share/wordpress /var/www/html/wordpress
mv /etc/wordpress/config-localhost.php /etc/wordpress/config-default.php

# Restart Apache
apachectl restart

echo "Done installing WordPress; beginning configuration"

# Grab the WordPress CLI utility and install it (http://wp-cli.org/)
sudo curl https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp
sudo chmod +x /usr/local/bin/wp

# Create the base site
serverRegion=$(echo "$5" | tr -d '[[:space:]]' | tr '[:upper:]' '[:lower:]')
serverUrl="http://$4.$serverRegion.cloudapp.azure.com/wordpress/"
siteName="Main Wordpress Site"
echo "Creating wordpress site at $serverUrl named $siteName with admin username $1"
sudo -u www-data wp core multisite-install --url="$serverUrl" --title="$siteName" --admin_user="$1" --admin_password="$2" --admin_email="$1@example.com" --skip-email --path=/var/www/html/wordpress --base=/wordpress

echo "Done configuring"
