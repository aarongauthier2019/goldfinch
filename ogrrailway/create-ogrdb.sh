#!/bin/sh
# Set database name and user
ARUSR=railway
ARDBN=ogrrailway

PATH=${PATH}:./bin

export ARUSR ARDBN
. bin/ar-env.sh

if [ x$(aqlx.sh 'return 0' 2> /dev/null) != x0 ]; then
    echo "an arangodb instance does not appear to be running on 'ar-server'"
    exit 2
fi

sh bin/createdb.sh

< great-britain-railway.ndjson arangoimp --file - --type json --batch-size 134217728 --progress true --server.username ${ARUSR} --server.authentication true --server.database ${ARDBN} --server.endpoint "tcp://"${ARSVR}":8529" --server.password "${ARPWD}" --collection fullosm2 --create-collection true --overwrite true

for i in fullnodes fullways fullrelations 
do    
    createcollection.sh ${i}
done

for i in fullnodes.aql fullways.aql fullrelations.aql 
do
    echo ${i}
    < ${i} aqlx.sh
done

creategeoindex.sh fullnodes
