#!/bin/bash
# Edit line 16 for snorby database password

apt-get install apache2 libyaml-dev git-core default-jre imagemagick libmagickwand-dev wkhtmltopdf gcc g++ build-essential libssl-dev libreadline-gplv2-dev zlib1g-dev linux-headers-generic libsqlite3-dev libxslt1-dev libxml2-dev libmysqlclient-dev libmysql++-dev apache2-prefork-dev libcurl4-openssl-dev ruby1.9.3 ruby-text-format -y
gem install bundler 
gem install rails
gem install rake --version=0.9.2
gem uninstall rake --version=10.3.1

cd /var/www/
git clone http://github.com/Snorby/snorby.git
cd /var/www/snorby/config/ 
cp database.yml.example database.yml
cp snorby_config.yml.example snorby_config.yml
sed -i s/"\/usr\/local\/bin\/wkhtmltopdf"/"\/usr\/bin\/wkhtmltopdf"/g /var/www/snorby/config/snorby_config.yml
sed -i 's/password: "Enter Password Here"/password: " "/g'  /var/www/snorby/config/database.yml

cd /var/www/snorby/
bundle install --no-deployment
bundle install --deployment
rake snorby:setup

gem install passenger
passenger-install-apache2-module

echo "<VirtualHost *:80>" >> /etc/apache2/sites-available/snorby.conf
echo "   ServerAdmin admin@localhost" >> /etc/apache2/sites-available/snorby.conf
echo "   ServerName snorby.localhost" >> /etc/apache2/sites-available/snorby.conf
echo "   DocumentRoot /var/www/snorby/public" >> /etc/apache2/sites-available/snorby.conf
echo "  " >> /etc/apache2/sites-available/snorby.conf
echo "   <Directory "/var/www/snorby/public">" >> /etc/apache2/sites-available/snorby.conf
echo "           AllowOverride all" >> /etc/apache2/sites-available/snorby.conf
echo "           Order deny,allow" >> /etc/apache2/sites-available/snorby.conf
echo "           Allow from all" >> /etc/apache2/sites-available/snorby.conf
echo "           Options -MultiViews" >> /etc/apache2/sites-available/snorby.conf
echo "   </Directory>" >> /etc/apache2/sites-available/snorby.conf
echo "</VirtualHost>" >> /etc/apache2/sites-available/snorby.conf

a2dissite default
a2ensite snorby.conf
service apache2 reload
 
echo "LoadModule passenger_module /var/lib/gems/1.9.1/gems/passenger-4.0.41/buildout/apache2/mod_passenger.so" >> /etc/apache2/apache2.conf
echo "<IfModule mod_passenger.c>" >> /etc/apache2/apache2.conf
echo "PassengerRoot /var/lib/gems/1.9.1/gems/passenger-4.0.41" >> /etc/apache2/apache2.conf
echo "PassengerDefaultRuby /usr/bin/ruby1.9.1" >> /etc/apache2/apache2.conf
echo "</IfModule>" >> /etc/apache2/apache2.conf

