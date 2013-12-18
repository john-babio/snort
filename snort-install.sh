#!/bin/bash
sudo apt-get -y install wget libpcap0.8-dev git libpcre3-dev g++ bison mysql-server flex make autoconf libtool libmysqlclient-dev

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
sudo ./configure --prefix=/usr/local/snort --enable-gre --enable-mpls --enable-targetbased --enable-ppm --enable-perfprofiling --enable-zlib --enable-active-response --enable-normalizer --enable-reload --enable-react --enable-flexresp3 && sudo make && sudo make install
sudo mkdir /var/log/snort
sudo mkdir /var/snort
sudo groupadd snort
sudo useradd -g snort snort
sudo chown snort:snort /var/log/snort

#Supply Oinkcode
#http://www.snort.org/reg-rules/snortrules-snapshot-2955.tar.gz/<oinkcode> -O /tmp/snortrules-snapshot-2955.tar.gz
sudo tar zxvf /tmp/snortrules-snapshot-2955.tar.gz -C /usr/local/snort
sudo mkdir /usr/local/snort/lib/snort_dynamicrules
sudo cp /usr/local/snort/so_rules/precompiled/Ubuntu-12-04/x86-64/2.9.5.5/* /usr/local/snort/lib/snort_dynamicrules
sudo touch /usr/local/snort/rules/white_list.rules
sudo touch /usr/local/snort/rules/black_list.rules
sudo ldconfig

sudo sed -i 's/var RULE_PATH ..\/rules/var RULE_PATH \/usr\/local\/snort\/rules/g' /usr/local/snort/etc/snort.conf
sudo sed -i 's/var SO_RULE_PATH ..\/so_rules/var SO_RULE_PATH \/usr\/local\/snort\/so_rules/g' /usr/local/snort/etc/snort.conf
sudo sed -i 's/var PREPROC_RULE_PATH ..\/preproc_rules/var PREPROC_RULE_PATH \/usr\/local\/snort\/preproc_rules/g' /usr/local/snort/etc/snort.conf
sudo sed -i 's/var WHITE_LIST_PATH ..\/rules/var WHITE_LIST_PATH \/usr\/local\/snort\/rules/g' /usr/local/snort/etc/snort.conf
sudo sed -i 's/var BLACK_LIST_PATH ..\/rules/var BLACK_LIST_PATH \/usr\/local\/snort\/rules/g' /usr/local/snort/etc/snort.conf
sudo sed -i 's/dynamicpreprocessor directory \/usr\/local\/lib\/snort_dynamicpreprocessor/dynamicpreprocessor directory \/usr\/local\/snort\/lib\/snort_dynamicpreprocessor/g' /usr/local/snort/etc/snort.conf
sudo sed -i 's/dynamicengine \/usr\/local\/lib\/snort_dynamicengine\/libsf_engine.so/dynamicengine \/usr\/local\/snort\/lib\/snort_dynamicengine\/libsf_engine.so/g' /usr/local/snort/etc/snort.conf
sudo sed -i 's/dynamicdetection directory \/usr\/local\/lib\/snort_dynamicrules/dynamicdetection directory \/usr\/local\/snort\/lib\/snort_dynamicrules/g' /usr/local/snort/etc/snort.conf
sudo sed -i 's/# preprocessor sfportscan: proto  { all } memcap { 10000000 } sense_level { low }/preprocessor sfportscan: proto  { all } memcap { 10000000 } sense_level { low }/g' /usr/local/snort/etc/snort.conf
sudo sed -i 's/# output log_unified2: filename snort.log, limit 128, nostamp/output unified2: filename snort.u2, limit 128/g' /usr/local/snort/etc/snort.conf
sudo sed -i 's/# include $PREPROC_RULE_PATH\/preprocessor.rules/include $PREPROC_RULE_PATH\/preprocessor.rules/g' /usr/local/snort/etc/snort.conf
sudo sed -i 's/# include $PREPROC_RULE_PATH\/decoder.rules/include $PREPROC_RULE_PATH\/decoder.rules/g' /usr/local/snort/etc/snort.conf
sudo sed -i 's/# include $PREPROC_RULE_PATH\/sensitive-data.rules/include $PREPROC_RULE_PATH\/sensitive-data.rules/g' /usr/local/snort/etc/snort.conf

git clone https://github.com/firnsy/barnyard2.git /tmp/barnyard2
cd /tmp/barnyard2
sudo autoreconf -fvi -I ./m4
sudo ./configure --with-mysql --with-mysql-libraries=/usr/lib/x86_64-linux-gnu
sudo make && sudo make install
sudo cp etc/barnyard2.conf /usr/local/snort/etc
sudo mkdir /var/log/barnyard2
sudo chmod 666 /var/log/barnyard2
sudo touch /var/log/snort/barnyard2.waldo
sudo chown snort.snort /var/log/snort/barnyard2.waldo

sudo sed -i 's/exit 0/ifconfig eth1 0.0.0.0 up promisc/g' /etc/rc.local 
sudo echo "/usr/local/snort/bin/snort -D -u snort -g snort -c /usr/local/snort/etc/snort.conf -i eth1" >> /etc/rc.local
sudo echo "/usr/local/bin/barnyard2 -c /usr/local/snort/etc/barnyard2.conf -d /var/log/snort -f snort.u2 -w /var/log/snort/barnyard2.waldo" >> /etc/rc.local
sudo echo "exit 0" >> /etc/rc.local
sudo sed -i 's/config reference_file:      \/etc\/snort\/reference.config/config reference_file:      \/usr\/local\/snort\/etc\/reference.config/g' /usr/local/snort/etc/barnyard2.conf
sudo sed -i 's/config classification_file: \/etc\/snort\/classification.config/config classification_file: \/usr\/local\/snort\/etc\/classification.config/g' /usr/local/snort/etc/barnyard2.conf
sudo sed -i 's/config gen_file:            \/etc\/snort\/gen-msg.map/config gen_file:            \/usr\/local\/snort\/etc\/gen-msg.map/g' /usr/local/snort/etc/barnyard2.conf
sudo sed -i 's/config sid_file:            \/etc\/snort\/sid-msg.map/config sid_file:            \/usr\/local\/snort\/etc\/sid-msg.map/g' /usr/local/snort/etc/barnyard2.conf
sudo sed -i 's/#config hostname:   thor/config hostname:   localhost/g' /usr/local/snort/etc/barnyard2.conf
sudo sed -i 's/#config interface:  eth0/config interface:  eth1/g' /usr/local/snort/etc/barnyard2.conf
sudo sed -i 's/#   output database: log, mysql, user=root password=test dbname=db host=localhost/output database: log, mysql, user=snorby password=test dbname=snorby host=localhost/g' /usr/local/snort/etc/barnyard2.conf




