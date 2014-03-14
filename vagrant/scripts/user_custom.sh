#!/bin/sh -e

# Add your custom configuration below.

# Add alias
cat << EOF >> /root/.bashrc
alias l="ls -lah"
EOF
cat << EOF >> /home/vagrant/.bashrc
alias l="ls -lah"
EOF

# Create gltf folder, which is then exported via httpd
mkdir /var/www/cache/gltf
chown vagrant.vagrant /var/www/cache/gltf
