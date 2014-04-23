#!/bin/bash

sudo apt-get -y install wget git libpcap-dev git libpcre3-dev g++ bison mysql-server flex make autoconf libtool libmysqlclient-dev libssl-dev

wget -O/tmp/snort-2.9.6.0.tar.gz http://www.snort.org/downloads/2787 
wget -O/tmp/daq-2.0.2.tar.gz http://www.snort.org/downloads/2778
wget -O/tmp/libdnet-1.12.tgz http://libdnet.googlecode.com/files/libdnet-1.12.tgz
wget -O/tmp/pulledpork-0.6.1.tar.gz https://pulledpork.googlecode.com/files/pulledpork-0.6.1.tar.gz
wget -O/tmp/emerging.rules.tar.gz http://rules.emergingthreats.net/open/snort-2.9.0/emerging.rules.tar.gz

cd /tmp
tar -xvf daq-2.0.2.tar.gz
tar -xvf snort-2.9.6.0.tar.gz
tar -xvf libdnet-1.12.tgz
tar -xvf pulledpork-0.6.1.tar.gz
tar -xvf emerging.rules.tar.gz

cd /tmp/libdnet-1.12
sudo ./configure && sudo make && sudo make install

sudo ln -s /usr/local/lib/libdnet.1.0.1 /usr/lib/libdnet.1

cd /tmp/daq-2.0.2
sudo ./configure && sudo make && sudo make install

cd /tmp/snort-2.9.6.0
sudo ./configure --prefix=/usr/local/snort --enable-gre --enable-mpls --enable-targetbased --enable-ppm --enable-perfprofiling --enable-zlib --enable-active-response --enable-normalizer --enable-reload --enable-react --enable-flexresp3 && sudo make && sudo make install
sudo mkdir /var/log/snort
sudo mkdir /var/snort
sudo mkdir /usr/local/snort/etc
sudo mkdir /usr/local/snort/rules
sudo groupadd snort
sudo useradd -g snort snort
sudo chown snort:snort /var/log/snort
sudo cp -r /tmp/snort-2.9.6.0/preproc_rules /usr/local/snort/
sudo cp /tmp/snort-2.9.6.0/etc/snort.conf /usr/local/snort/etc/
sudo cp /tmp/snort-2.9.6.0/etc/threshold.conf /usr/local/snort/etc/
sudo cp /tmp/rules/sid-msg.map /usr/local/snort/etc/
sudo cp /tmp/rules/gen-msg.map /usr/local/snort/etc/
sudo cp /tmp/rules/unicode.map /usr/local/snort/etc/
sudo cp /tmp/rules/reference.config /usr/local/snort/etc/
sudo cp /tmp/rules/classification.config /usr/local/snort/etc/
sudo cp /tmp/rules/emerging.conf /usr/local/snort/etc/

sudo mkdir /usr/local/snort/lib/snort_dynamicrules
sudo touch /usr/local/snort/rules/white_list.rules
sudo touch /usr/local/snort/rules/black_list.rules
sudo touch /usr/local/snort/rules/local.rules
sudo ldconfig

sudo cpan Crypt::SSLeay
sudo cpan Switch

cp -r /tmp/pulledpork-0.6.1 /usr/local/snort/pulledpork

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

sudo sed -i 's/var WHITE_LIST_PATH ..\/rules/var WHITE_LIST_PATH \/usr\/local\/snort\/rules/g' /usr/local/snort/etc/snort.conf
sudo sed -i 's/var BLACK_LIST_PATH ..\/rules/var BLACK_LIST_PATH \/usr\/local\/snort\/rules/g' /usr/local/snort/etc/snort.conf
sudo sed -i 's/dynamicpreprocessor directory \/usr\/local\/lib\/snort_dynamicpreprocessor/dynamicpreprocessor directory \/usr\/local\/snort\/lib\/snort_dynamicpreprocessor/g' /usr/local/snort/etc/snort.conf
sudo sed -i 's/dynamicengine \/usr\/local\/lib\/snort_dynamicengine\/libsf_engine.so/dynamicengine \/usr\/local\/snort\/lib\/snort_dynamicengine\/libsf_engine.so/g' /usr/local/snort/etc/snort.conf
sudo sed -i 's/dynamicdetection directory \/usr\/local\/lib\/snort_dynamicrules/dynamicdetection directory \/usr\/local\/snort\/lib\/snort_dynamicrules/g' /usr/local/snort/etc/snort.conf
sudo sed -i 's/# output log_unified2: filename snort.log, limit 128, nostamp/output unified2: filename snort.u2, limit 128/g' /usr/local/snort/etc/snort.conf
sudo sed -i 's/# include $PREPROC_RULE_PATH\/preprocessor.rules/include $PREPROC_RULE_PATH\/preprocessor.rules/g' /usr/local/snort/etc/snort.conf
sudo sed -i 's/# include $PREPROC_RULE_PATH\/decoder.rules/include $PREPROC_RULE_PATH\/decoder.rules/g' /usr/local/snort/etc/snort.conf
sudo sed -i 's/# include $PREPROC_RULE_PATH\/sensitive-data.rules/include $PREPROC_RULE_PATH\/sensitive-data.rules/g' /usr/local/snort/etc/snort.conf
sudo sed -i 's/include $RULE_PATH/#include $RULE_PATH/g' /usr/local/snort/etc/snort.conf
echo 'include emerging.conf' >> /usr/local/snort/etc/snort.conf
sudo sed -i 's/var RULE_PATH ..\/rules/var RULE_PATH \/usr\/local\/snort\/rules/g' /usr/local/snort/etc/snort.conf
sudo sed -i 's/var SO_RULE_PATH ..\/so_rules/#var SO_RULE_PATH/g' /usr/local/snort/etc/snort.conf
sudo sed -i 's/var PREPROC_RULE_PATH ..\/preproc_rules/var PREPROC_RULE_PATH \/usr\/local\/snort\/preproc_rules/g' /usr/local/snort/etc/snort.conf
sudo sed -i 's/rule_url=https:\/\/www.snort/#rule_url=https:\/\/www.snort/g' /usr/local/snort/pulledpork/etc/pulledpork.conf
sudo sed -i 's/rule_url=https:\/\/rules.emergingthreats.net\/|etpro.rules.tar.gz|<et oinkcode>/#rule_url=https:\/\/rules.emergingthreats.net\/|etpro.rules.tar.gz|<et oinkcode>/g' /usr/local/snort/pulledpork/etc/pulledpork.conf
sudo sed -i 's/rule_path=\/usr\/local\/etc\/snort\/rules\/snort.rules/rule_path=\/usr\/local\/snort\/rules\/snort.rules/g' /usr/local/snort/pulledpork/etc/pulledpork.conf
sudo sed -i 's/local_rules=\/usr\/local\/etc\/snort\/rules\/local.rules/local_rules=\/usr\/local\/snort\/rules\/local.rules/g'  /usr/local/snort/pulledpork/etc/pulledpork.conf
sudo sed -i 's/sid_msg=\/usr\/local\/etc\/snort\/sid-msg.map/sid_msg=\/usr\/local\/snort\/etc\/sid-msg.map/g' /usr/local/snort/pulledpork/etc/pulledpork.conf
sudo sed -i 's/sorule_path=\/usr\/local\/lib\/snort_dynamicrules/sorule_path=\/usr\/local\/snort\/lib\/snort_dynamicrules/g' /usr/local/snort/pulledpork/etc/pulledpork.conf
sudo sed -i 's/snort_path=\/usr\/local\/bin\/snort/snort_path=\/usr\/local\/snort\/bin\/snort/g' /usr/local/snort/pulledpork/etc/pulledpork.conf
sudo sed -i 's/config_path=\/usr\/local\/etc\/snort\/snort.conf/config_path=\/usr\/local\/snort\/etc\/snort.conf/g' /usr/local/snort/pulledpork/etc/pulledpork.conf
sudo sed -i 's/sostub_path=\/usr\/local\/etc\/snort\/rules\/so_rules.rules/sostub_path=\/usr\/local\/snort\/rules\/so_rules.rules/g' /usr/local/snort/pulledpork/etc/pulledpork.conf
sudo sed -i 's/distro=FreeBSD-8.0/distro=Ubuntu-12-04/g' /usr/local/snort/pulledpork/etc/pulledpork.conf
sudo sed -i 's/# pid_path=\/var\/run\/snort.pid,\/var\/run\/barnyard.pid,\/var\/run\/barnyard2.pid/pid_path=\/var\/run\/snort_eth1.pid,\/var\/run\/barnyard2_eth1.pid/g' /usr/local/snort/pulledpork/etc/pulledpork.conf
sudo sed -i 's/# disablesid=\/usr\/local\/etc\/snort\/disablesid.conf/disablesid=\/usr\/local\/snort\/pulledpork\/etc\/disablesid.conf/g' /usr/local/snort/pulledpork/etc/pulledpork.conf
sudo sed -i 's/config reference_file:      \/etc\/snort\/reference.config/config reference_file:      \/usr\/local\/snort\/etc\/reference.config/g' /usr/local/snort/etc/barnyard2.conf
sudo sed -i 's/config classification_file: \/etc\/snort\/classification.config/config classification_file: \/usr\/local\/snort\/etc\/classification.config/g' /usr/local/snort/etc/barnyard2.conf
sudo sed -i 's/config gen_file:            \/etc\/snort\/gen-msg.map/config gen_file:            \/usr\/local\/snort\/etc\/gen-msg.map/g' /usr/local/snort/etc/barnyard2.conf
sudo sed -i 's/config sid_file:            \/etc\/snort\/sid-msg.map/config sid_file:            \/usr\/local\/snort\/etc\/sid-msg.map/g' /usr/local/snort/etc/barnyard2.conf
sudo sed -i 's/#config hostname:   thor/config hostname:   localhost/g' /usr/local/snort/etc/barnyard2.conf
sudo sed -i 's/#config interface:  eth0/config interface:  eth1/g' /usr/local/snort/etc/barnyard2.conf
sudo sed -i 's/#   output database: log, mysql, user=root password=test dbname=db host=localhost/output database: log, mysql, user=snorby password=test dbname=snorby host=localhost/g' /usr/local/snort/etc/barnyard2.conf
echo 'include $RULE_PATH/local.rules' >> /usr/local/snort/etc/emerging.conf
echo 'include $RULE_PATH/snort.rules' >> /usr/local/snort/etc/emerging.conf
echo 'include $RULE_PATH/so_rules.rules' >> /usr/local/snort/etc/emerging.conf
sudo sed -i 's/#include $RULE_PATH\/classification.config/include classification.config/g' /usr/local/snort/etc/emerging.conf
sudo sed -i 's/#include $RULE_PATH\/reference.config/include reference.config/g' /usr/local/snort/etc/emerging.conf
sudo sed -i 's/#var SSH_PORTS 22/var SSH_PORTS 22/g' /usr/local/snort/etc/emerging.conf
sudo echo "config classification: sdf,Sensitive Data,2" >> /usr/local/snort/etc/classification.config
sudo perl /usr/local/snort/pulledpork/pulledpork.pl -c /usr/local/snort/pulledpork/etc/pulledpork.conf



