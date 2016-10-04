#!/bin/bash

set -e

# sudo rm export/tiles.mbtiles* &> /dev/null || true

echo "> import-external"
docker-compose -f docker-compose.simplify.yml up import-external # &> /dev/null

curl http://download.geofabrik.de/europe/switzerland-latest.osm.pbf -o ./import/zurich.osm.pbf

echo "> import-osm"
start_import_osm=$(date +%s.%N)
docker-compose -f docker-compose.simplify.yml up --build import-osm # &> /dev/null
end_import_osm=$(date +%s.%N)
echo "> import-sql"
start_import_sql=$(date +%s.%N)
docker-compose -f docker-compose.simplify.yml up --build import-sql # &> /dev/null
end_import_sql=$(date +%s.%N)
echo "> export"
start_export=$(date +%s.%N)
docker-compose run -e BBOX="8.34,47.27,8.75,47.53" -e MIN_ZOOM="8" -e MAX_ZOOM="14" export # &> /dev/null
end_export=$(date +%s.%N)
# echo "> patch"
# sudo ./tools/patch "./export/planet_2016-06-20_7088ce06a738dcb3104c769adc11ac2c_z0-z5.mbtiles" "./export/tiles.mbtiles" # &> /dev/null

echo "> import-osm duration: $(echo "$end_import_osm - $start_import_osm" | bc)"
echo "> import-sql duration: $(echo "$end_import_sql - $start_import_sql" | bc)"
echo "> export duration: $(echo "$end_export - $start_export" | bc)"

# echo "> serve"
# tileserver-gl-light export/tiles.mbtiles --port 8090 &> /dev/null
