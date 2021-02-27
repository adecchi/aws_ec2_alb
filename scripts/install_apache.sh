#!/bin/bash
sudo yum install -y httpd
sudo service httpd start
sudo chkconfig httpd on
echo "<h1>APCHE2 Deployed via Terraform</h1>" | sudo tee /var/www/html/index.html