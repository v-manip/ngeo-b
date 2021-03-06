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
mkdir -p /var/www/cache/gltf
chown vagrant.vagrant /var/www/cache/gltf

# Create Cloudsat sqlite.db
cat << EOF > /tmp/bootstrap_cloudsat.txt
create table if not exists tiles(
                        tileset text,
                        grid text,
                        x integer,
                        y integer,
                        z integer,
                        data text,
                        dim text,
                        ctime datetime,
                        primary key(tileset,grid,x,y,z,dim)
                    );

EOF
sqlite3 /var/www/cache/Cloudsat.sqlite < /tmp/bootstrap_cloudsat.txt
rm /tmp/bootstrap_cloudsat.txt
