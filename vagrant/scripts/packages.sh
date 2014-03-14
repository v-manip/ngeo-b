#!/bin/sh -e

# Update all the installed packages
yum update -y

# Install packages
yum install -y gdal gdal-python postgis Django14 proj-epsg
yum install -y python-lxml mod_wsgi httpd postgresql-server python-psycopg2 pytz
yum install -y libxml2 libxml2-devel libxml2-python mapserver mapserver-python pcre-devel.x86_64
yum install -y unzip

# Install some build dependencies
yum install -y gcc make gcc-c++ kernel-devel-`uname -r` zlib-devel \
               openssl-devel readline-devel perl wget httpd-devel pixman-devel \
               sqlite-devel libpng-devel libjpeg-devel libcurl-devel cmake \
               geos-devel fcgi-devel gdal-devel python-devel python-imaging \
               python-collada python-unittest2


# Attention: Make sure to not install mapcache, ngEO_Browse_Server, and 
# EOxServer from rpm packages!
# See development_installation.sh for installation.
