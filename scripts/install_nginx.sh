#!/bin/bash
sudo amazon-linux-extras install -y nginx1
sudo amazon-linux-extras enable nginx1
sudo yum clean metadata
sudo yum install nginx
sudo systemctl restart nginx
sudo echo "<h1>Nginx Deployed via Terraform</h1>" | sudo tee vim /usr/share/nginx/html/index.html