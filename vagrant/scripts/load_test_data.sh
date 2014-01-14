 python manage.py loaddata /var/data/cloudsat_new/cloudsat_fixture.json 
 cp /var/data/cloudsat_new/*.tif /var/www/store/
 cd /var/ngeob_autotest

 python manage.py ngeo_ingest /var/data/cloudsat_new/br_Reflectivity_2013137113720_*.xml   -v3
 