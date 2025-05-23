#!/bin/bash -xv

yum install -y yum-utils

cat > /etc/yum.repos.d/nginx.repo << 'EOF'
[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/amzn2/$releasever/$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
priority=9
EOF

yum install -y nginx

systemctl enable nginx
systemctl start nginx