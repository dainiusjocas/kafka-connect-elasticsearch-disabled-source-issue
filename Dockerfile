FROM confluentinc/cp-kafka-connect-base:5.5.0
RUN  confluent-hub install --no-prompt confluentinc/kafka-connect-elasticsearch:5.5.0
