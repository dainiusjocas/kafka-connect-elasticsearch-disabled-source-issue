# 
kafka-connect-elasticsearch-disabled-source-issue 

There is an issue with the Kafka Connect Elasticsearch sink connector, when target index configuration is managed with the index templates and the template specifies that index has `_source` disabled.

After a ~60 seconds of normal operation connector gets into `FAILED` state.

Steps to reproduce:
1. In terminal 1 run `make run-dev-env`
2. Wait for about 1 minute until docker-compose cluster with Kafka, Kafka Connect, Kafka REST Proxy, and Elasticsearch starts up.
3. In terminal 2 run `make simulate` the output should be similar to the one bellow.

NOTE: sometimes there is no error.
 
```
./script.sh                                                               
Create Elasticsearch index template
{
  "acknowledged": true
}
Create Kafka Connect connector
{
  "name": "test-connector",
  "config": {
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
  },
  "tasks": [],
  "type": "sink"
}
Send documents to Kafka via Kafka REST API
{"offsets":[{"partition":0,"offset":0,"error_code":null,"error":null},{"partition":0,"offset":1,"error_code":null,"error":null}],"key_schema_id":null,"value_schema_id":null}Sleep for 2 seconds
Get status of the connector, task should be running
{
  "name": "test-connector",
  "connector": {
    "state": "RUNNING",
    "worker_id": "connect:8088"
  },
  "tasks": [
    {
      "id": 0,
      "state": "RUNNING",
      "worker_id": "connect:8088"
    }
  ],
  "type": "sink"
}
Sleep for 60 seconds
Get status of the connector, task should be failed
{
  "name": "test-connector",
  "connector": {
    "state": "RUNNING",
    "worker_id": "connect:8088"
  },
  "tasks": [
    {
      "id": 0,
      "state": "FAILED",
      "worker_id": "connect:8088",
      "trace": "org.apache.kafka.connect.errors.ConnectException: Exiting WorkerSinkTask due to unrecoverable exception.\n\tat org.apache.kafka.connect.runtime.WorkerSinkTask.deliverMessages(WorkerSinkTask.java:568)\n\tat org.apache.kafka.connect.runtime.WorkerSinkTask.poll(WorkerSinkTask.java:326)\n\tat org.apache.kafka.connect.runtime.WorkerSinkTask.iteration(WorkerSinkTask.java:228)\n\tat org.apache.kafka.connect.runtime.WorkerSinkTask.execute(WorkerSinkTask.java:196)\n\tat org.apache.kafka.connect.runtime.WorkerTask.doRun(WorkerTask.java:184)\n\tat org.apache.kafka.connect.runtime.WorkerTask.run(WorkerTask.java:234)\n\tat java.util.concurrent.Executors$RunnableAdapter.call(Executors.java:511)\n\tat java.util.concurrent.FutureTask.run(FutureTask.java:266)\n\tat java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1149)\n\tat java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)\n\tat java.lang.Thread.run(Thread.java:748)\nCaused by: org.apache.kafka.connect.errors.ConnectException: Bulk request failed: [{\"type\":\"document_source_missing_exception\",\"reason\":\"[_doc][0]: document source missing\",\"index_uuid\":\"fPD5WWOUT3OQbB4UbIb6Hw\",\"shard\":\"0\",\"index\":\"test-index\"}]\n\tat io.confluent.connect.elasticsearch.bulk.BulkProcessor$BulkTask.execute(BulkProcessor.java:438)\n\tat io.confluent.connect.elasticsearch.bulk.BulkProcessor$BulkTask.call(BulkProcessor.java:389)\n\tat io.confluent.connect.elasticsearch.bulk.BulkProcessor$BulkTask.call(BulkProcessor.java:375)\n\tat java.util.concurrent.FutureTask.run(FutureTask.java:266)\n\tat java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1149)\n\tat java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)\n\tat java.lang.Thread.run(Thread.java:748)\n\tat io.confluent.connect.elasticsearch.bulk.BulkProcessor$BulkProcessorThread.run(BulkProcessor.java:370)\n"
    }
  ],
  "type": "sink"
}
```
