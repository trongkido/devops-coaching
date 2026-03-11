#!/bin/bash

apt update
apt install -y mysql-server

systemctl enable mysql
systemctl start mysql
