#!/bin/bash
sudo su - 
timedatectl set-ntp true
timedatectl set-timezone UTC
systemctl restart chronyd || systemctl restart systemd-timesyncd
timedatectl   # Confirm NTP is synchronized
rpm --import https://yum.corretto.aws/corretto.key
curl -Lo /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo
yum install -y java-17-amazon-corretto-devel --nogpgcheck
#alternatives --config java

sysctl -w vm.max_map_count=262144
echo 'vm.max_map_count=262144' >> /etc/sysctl.conf

yum install wget unzip -y

cd /opt
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.6.1.59531.zip
unzip sonarqube-9.6.1.59531.zip
mv sonarqube-9.6.1.59531 sonarqube

useradd sonar
echo 'sonar   ALL=(ALL)       NOPASSWD: ALL' >> /etc/sudoers
chown -R sonar:sonar /opt/sonarqube
chmod -R 775 /opt/sonarqube

su - sonar
echo 'export JAVA_HOME=/usr/lib/jvm/java-17-amazon-corretto' >> ~/.bashrc
echo 'export PATH=$JAVA_HOME/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

java -version

cd /opt/sonarqube/bin/linux-x86-64/
sh sonar.sh start
sh sonar.sh status
