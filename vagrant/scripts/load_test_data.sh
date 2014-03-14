#!/bin/sh

cd /var/ngeob_autotest

python manage.py loaddata /var/data/cloudsat_new/cloudsat_fixture.json

tmpdir=`mktemp -d`

#find /var/data/cloudsat/ -name 'cloudsat_2014012*' -exec unzip {} -d ${tmpdir} \;
find /var/data/cloudsat/ -name 'cloudsat_20140124150000_37519.zip' -exec unzip {} -d ${tmpdir} \;

find ${tmpdir} -name '*tif' -exec mv {} /var/www/store/ \;

find ${tmpdir} -name '*xml' -exec python manage.py ngeo_ingest {} -v3 \;

rm -rf ${tmpdir}
