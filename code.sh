#!/bin/bash

# Ensure script runs as root
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

echo "Starting setup..."
###################################################################################
##################################     mongodb    ##################################
###################################################################################

# Install DNF package manager (if not already installed)
sudo yum install dnf -y

# Copy the MongoDB repository configuration file to the YUM repository directory
cp mongodb-org-7.0.repo /etc/yum.repos.d/mongodb-org-7.0.repo

# Install MongoDB while disabling the AppStream repository to avoid conflicts
dnf --disablerepo=AppStream install -y mongodb-org

# Update MongoDB configuration to allow external connections by replacing 127.0.0.1 with 0.0.0.0
sed -i -e 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf

# Restart MongoDB service to apply the changes
systemctl restart mongod


###################################################################################
##################################     nodejs    ##################################
###################################################################################
# setup user
adduser spec

curl -sL https://rpm.nodesource.com/setup_16.x | bash -
yum install nodejs -y 

yum install git -y 
# shellcheck disable=SC2164
cd /home/spec/
git clone https://github.com/OpsInfinity/app.git
# shellcheck disable=SC2164
cd app/
cat package.sh | bash

# Configure MongoDB environment variables
db_user="prasad"
db_pass="123Prasad"

# mongodb end point or connection string

echo "Setting up environment variables..."
echo Environment="MONGO_ENDPOINT=mongodb+srv://$db_user:$db_pass@cluster0.3zmmc.mongodb.net/login-app-db?retryWrites=true&w=majority" >> /home/spec/app/files/spec.service


cp files/spec.service /etc/systemd/system/
systemctl restart spec

###################################################################################
##################################     nginx    ##################################
###################################################################################

sudo yum install epel-release -y
sudo yum install nginx -y 

# shellcheck disable=SC2216
yes | cp -rf files/nginx.conf /etc/nginx/nginx.conf
# shellcheck disable=SC2216
yes | cp -rf files/nodejs.conf /etc/nginx/conf.d/nodejs.conf
setenforce 0
systemctl restart nginx
# node .js > node.logs 2>&1 &
# ps -ef | grep "index.js" > run.log
