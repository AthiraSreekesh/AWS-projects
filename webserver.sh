#!/bin/bash

hostnamectl set-hostname wordpress.example.com
yum install httpd php php-mysqlnd -y
systemctl restart httpd php-fpm
systemctl enable httpd php-fpm
wget https://wordpress.org/wordpress-6.3.tar.gz
tar -xvf wordpress-6.3.tar.gz
cp -r wordpress/*  /var/www/html/
cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
chown -R apache:apache /var/www/html/*