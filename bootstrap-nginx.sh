#!/bin/sh
sudo amazon-linux-extras install nginx1
sudo systemctl enable nginx
sudo systemctl start nginx
echo "<h1>DevOps Code Challenge</H1>$(date)" >   /usr/share/nginx/html/index.html 
