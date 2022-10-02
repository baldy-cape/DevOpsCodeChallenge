#!/bin/sh
sudo yum update -y 
sudo yum install -y nginx 
sudo systemctl enable nginx
sudo systemctl start nginx

