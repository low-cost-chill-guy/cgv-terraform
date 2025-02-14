#! /bin/bash
   yum install -y httpd
   echo "Hello Terraform" > /var/www/html/index.html
   systemctl start httpd
