#!/bin/bash
sudo apt-get -y install wget libpcap0.8-dev libpcre3-dev g++ bison flex make autoconf libtool libmysqlclient-dev

wget -O/tmp/snort-2.9.5.6.tar.gz http://www.snort.org/downloads/2665 
wget -O/tmp/daq-2.0.1.tar.gz http://www.snort.org/downloads/2657
wget -O/tmp/libdnet-1.12.tgz http://libdnet.googlecode.com/files/libdnet-1.12.tgz

cd /tmp
tar -xvf daq-2.0.1.tar.gz
tar -xvf snort-2.9.5.6.tar.gz
tar -xvf libdnet-1.12.tgz
cd /tmp/libdnet-1.12
sudo ./configure && sudo make && sudo make install

sudo ln -s /usr/local/lib/libdnet.1.0.1 /usr/lib/libdnet.1

cd /tmp/daq-2.0.1
sudo ./configure && sudo make && sudo make install

cd /tmp/snort-2.9.5.6
sudo ./configure --prefix=/etc/snort --enable-gre --enable-mpls --enable-targetbased --enable-ppm --enable-perfprofiling --enable-zlib --enable-active-response --enable-normalizer --enable-reload --enable-react --enable-flexresp3 && sudo make && sudo make install
sudo mkdir /var/log/snort
sudo mkdir /var/snort
sudo groupadd snort
sudo useradd -g snort snort
sudo chown snort:snort /var/log/snort

#If the rules file version changes just download them and alter the snortrules-snapshot-29xx.tar.gz
sudo tar zxvf /tmp/snortrules-snapshot-2955.tar.gz -C /etc/snort
sudo mkdir /etc/snort/lib/snort_dynamicrules
sudo cp /etc/snort/so_rules/precompiled/Ubuntu-12-04/x86-64/2.9.5.5/* /etc/snort/lib/snort_dynamicrules
sudo touch /etc/snort/rules/white_list.rules
sudo touch /etc/snort/rules/black_list.rules
sudo ldconfig
sudo mv /tmp/snort.conf /etc/snort/etc/


git clone https://github.com/firnsy/barnyard2.git /tmp/barnyard2
cd /tmp/barnyard2
sudo autoreconf -fvi -I ./m4
sudo ./configure --with-mysql --with-mysql-libraries=/usr/lib/x86_64-linux-gnu
sudo make && sudo make install
sudo cp etc/barnyard2.conf /etc/snort/etc
sudo mkdir /var/log/barnyard2
sudo chmod 666 /var/log/barnyard2
sudo touch /var/log/snort/barnyard2.waldo
sudo chown snort.snort /var/log/snort/barnyard2.waldo

sudo sed 's/ exit 0/ifconfig eth1 0.0.0.0 up promisc/g' /etc/rc.local > /etc/rc.local2
sudo echo "/usr/local/snort/bin/snort -D -u snort -g snort -c /usr/local/snort/etc/snort.conf -i eth1" >> /etc/rc.local2
sudo echo "/usr/local/bin/barnyard2 -c /usr/local/snort/etc/barnyard2.conf -d /var/log/snort -f snort.u2 -w /var/log/snort/barnyard2.waldo" >> /etc/rc.local2
sudo echo "exit 0" >> /etc/rc.local2
sudo mv /etc/rc.local2 /etc/rc.local

sudo sed 's/#config hostname:   thor/config hostname:   localhost/g' /etc/snort/etc/barnyard2.conf > /etc/snort/etc/barnyard1
sudo sed 's/#config interface:  eth0/config interface:  eth1/g' /etc/snort/etc/barnyard1 > /etc/snort/etc/barnyard-2
sudo sed 's/#   output database: log, mysql, user=root password=test dbname=db host=localhost/output database: log, mysql, user=snorby password=test dbname=snorby host=localhost/g' /etc/snort/etc/barnyard-2 > /etc/snort/etc/barnyard3 
sudo mv /etc/snort/etc/barnyard3 /etc/snort/etc/barnyard.conf
sudo rm /etc/snort/etc/barnyard1
sudo rm /etc/snort/etc/barnyard-2

