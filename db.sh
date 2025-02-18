#!/bin/bash

hostnamectl set-hostname mariadb.example.com
yum install mariadb105-server -y
systemctl restart mariadb.service
systemctl enable mariadb.service