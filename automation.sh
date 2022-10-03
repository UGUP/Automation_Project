#!/bin/bash

#varibale declaration
myname="upma"
s3_bucket="upgrad-$myname"
format_timestamp="$myname-httpd-logs-$(date '+%d%m%Y-%H%M%S')"


#Updating the Package details and package list
echo "updating the packages" &&
sudo apt update -y > /dev/null &&

# Verifying if the apache2 server is already installed and installing if not installed
dpkg-query -l apache2 > /dev/null

if [ $? !=  0 ]
then
        echo "Installing the apache server"
        sudo apt install apache2
else
       echo "Apache server is already installed"
fi

#Verifying if the Apache2 is running and run it in case its not running
sudo systemctl status apache2 > /dev/null

if [ $? !=  0 ]
then
     echo "Start apache Server....."
     sudo systemctl start apache2.service
else
        echo "Apache server is running"
fi

#Verify if the Apache2 service is enabled an dif not enable the service
sudo systemctl status apache2.service > /dev/null

if [ $? != 0 ]
then
        echo "Enabling the service....."
        sudo systemctl enable apache2
else
        echo "The service is already enabled"
fi

#Creating thr tar of access logs and error logs into tmp directory

echo "Create tar file of the log files" &&
tar -cvzf /tmp/$format_timestamp.tar  /var/log/apache2/error.log /var/log/apache2/access.log &&

# Installing aws cli if not already installed

aws --version > /dev/null

if [ $? !=  0 ]
then
        sudo apt update > /dev/null &&
        sudo apt install awscli > /dev/null
else
        echo "awscli is already installed"
fi

# Copy the archive to the S3 bucket

echo "Copying the tar file to S3 bucket" &&
aws s3 cp /tmp/$format_timestamp.tar s3://${s3_bucket}/$format_timestamp.tar

