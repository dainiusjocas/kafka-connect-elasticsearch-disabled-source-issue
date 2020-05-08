#!/bin/bash 

echo "Create Elasticsearch index template"
curl -s -XPUT "http://localhost:9200/_template/test-index" -H 'Content-Type: application/json' -d'{
  "index_patterns": ["test-index*"],
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 0
  },
  "mappings": {    
    "_source": {
      "enabled": false
    },
    "properties": {
      "props": {
        "type": "nested",
        "properties": {
          "attr": {
            "type": "keyword"
          }
        }
      }
    }  
  }
}' | jq

echo "Sleep for 2 seconds" 
sleep 2

echo "Create Kafka Connect connector"
curl -s -X PUT http://localhost:8088/connectors/test-connector/config -H "Content-Type: application/json" -d '{
  "connector.class": "io.confluent.connect.elasticsearch.ElasticsearchSinkConnector",
  "type.name": "_doc",
  "behavior.on.null.values": "delete",
  "errors.log.include.messages": "true",
  "tasks.max": "1",
  "topics": "test-topic",
  "key.ignore": "false",
  "errors.deadletterqueue.context.headers.enable": "true",
  "schema.ignore": "true",
  "behavior.on.malformed.documents": "warn",
  "errors.deadletterqueue.topic.name": "dlq-test-topic",
  "topic.index.map": "test-topic:test-index",
  "write.method": "upsert",
  "value.converter.schemas.enable": "false",
  "name": "test-connector",
  "errors.tolerance": "all",
  "errors.deadletterqueue.topic.replication.factor": "1",
  "value.converter": "org.apache.kafka.connect.json.JsonConverter",
  "connection.url": "http://elasticsearch:9200",
  "errors.log.enable": "true",
  "schemas.enable": "false"
}' | jq

echo "Send documents to Kafka via Kafka REST API" 
curl -s -X POST http://localhost:8082/topics/test-topic/partitions/0 -H "Accept: application/vnd.kafka.v2+json" -H "Content-Type: application/vnd.kafka.json.v2+json" -d '{
  "records": [
    {
      "value": {"attr": "value1", "props": [{"attr":"value1"}, {"attr":"value2"}]},
      "key": 0
    },
    {
      "value": {"attr": "value2", "props": [{"attr":"value3"}, {"attr":"value4"}]},
      "key": 0
    },
    {
      "value": {"attr": "value3", "props": [{"attr":"value5"}, {"attr":"value6"}]},
      "key": 0
    }
  ]
}' | jq

echo "Sleep for 2 seconds" 
sleep 2

echo "Get status of the connector, task should be running"
curl -s -X GET http://localhost:8088/connectors/test-connector/status | jq

echo "Sleep for 60 seconds"
sleep 60

echo "Get status of the connector, task should be failed"
curl -s -X GET http://localhost:8088/connectors/test-connector/status | jq
