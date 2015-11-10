#!/bin/bash
export IP=$(docker-machine ip dev)

function MappingShakespeare() {
curl -XPUT http://$IP:9200/shakespeare -d '
{
 "mappings" : {
  "_default_" : {
   "properties" : {
    "speaker" : {"type": "string", "index" : "not_analyzed" },
    "play_name" : {"type": "string", "index" : "not_analyzed" },
    "line_id" : { "type" : "integer" },
    "speech_number" : { "type" : "integer" }
   }
  }
 }
}
'
}

function LoadAccounts() {
curl -XPOST $IP':9200/bank/accounts/_bulk?pretty' --data-binary @data/accounts.json
}

function LoadShakeSpeare() {
curl -XPOST $IP':9200/shakespeare/_bulk?pretty' --data-binary @data/shakespeare.json
}

function LoadLogs() {
curl -XPOST $IP':9200/_bulk?pretty' --data-binary @data/logstash.json
}

# Wait for a certain service to become available
function waitForService() {
while true; do
  if ! nc -z $1 $2
  then
    echo "Service $1:$2 not available, retrying..."
    sleep 1
  else
    echo "Service $1:$2 is available"
    break;
  fi
done;
}

#!/bin/bash
docker rm -f $(docker ps -aq)
docker-compose --x-networking up -d
waitForService $IP 9200
MappingShakespeare
LoadAccounts
LoadShakeSpeare
LoadLogs
echo "kibana is available at $IP:5601"
curl $IP':9200/_cat/indices?v'