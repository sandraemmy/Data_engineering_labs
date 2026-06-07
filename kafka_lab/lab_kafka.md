Lab kafka



cd C:kafka

bin\\windows\\kafka-server-start.bat config\\server.properties



cd C:kafka

bin\\windows\\kafka-topics.bat --create --topic demo-topic --bootstrap-server localhost:9092 --partitions 1 --replication-factor 1



cd C:\\kafka

&#x20;bin\\windows\\kafka-topics.bat --create --topic group-demo --bootstrap-server localhost:9092 --partitions 3 --replication-factor 1



cd C:\\kafka

bin\\windows\\kafka-console-consumer.bat --bootstrap-server localhost:9092 --topic group-demo --group my-demo-group



cd C:\\kafka

bin\\windows\\kafka-console-consumer.bat --bootstrap-server localhost:9092 --topic group-demo --group my-demo-group



cd C:\\kafka

bin\\windows\\kafka-console-producer.bat --bootstrap-server localhost:9092 --topic group-demo



C:\\kafka> .\\bin\\windows\\kafka-console-producer.bat --bootstrap-server localhost:9092 --topic group-demo

>Hello

>i want

>to test my lab

>This is lab1 von lab



cd C:\\kafka

bin\\windows\\kafka-topics.bat --create --topic partition-demo --bootstrap-server localhost:9092 --partitions 3 --replication-factor 1



cd C:\\kafka

bin\\windows\\kafka-topics.bat --describe --topic partition-demo --bootstrap-server localhost:9092

resut :

Topic: partition-demo   TopicId: w0EDKGfTR6uWtRkXdtsehQ PartitionCount: 3     ReplicationFactor: 1    Configs:

&#x20;       Topic: partition-demo   Partition: 0    Leader: 0       Replicas: 0   Isr: 0  Elr: N/A        LastKnownElr: N/A

&#x20;       Topic: partition-demo   Partition: 1    Leader: 0       Replicas: 0   Isr: 0  Elr: N/A        LastKnownElr: N/A

&#x20;       Topic: partition-demo   Partition: 2    Leader: 0       Replicas: 0   Isr: 0  Elr: N/A        LastKnownElr: N/A



cd C:\\lkafka

bin\\windows\\kafka-topics.bat --create --topic chat-room --bootstrap-server localhost:9092 --partitions 1 --replication-factor 1



consumer

cd C:kafka

bin\\windows\\kafka-console-consumer.bat --bootstrap-server localhost:9092 --topic chat-room --from-beginning



bin\\windows\\kafka-console-producer.bat --bootstrap-server localhost:9092 --topic chat-room

&#x20;This is a live message



cd C:kafka

bin\\windows\\kafka-topics.bat --create --topic keys-demo --bootstrap-server localhost:9092 --partitions 3 --replication-factor 1



bin\\windows\\kafka-console-consumer.bat --bootstrap-server localhost:9092 --topic keys-demo --group keys-group



bin\\windows\\kafka-console-consumer.bat --bootstrap-server localhost:9092 --topic keys-demo --group keys-group



bin\\windows\\kafka-console-producer.bat --bootstrap-server localhost:9092 --topic keys-demo --property "parse.key=true" --property "key.separator=:"



Lab5:Consumer GRoupMonitoring:



bin\\windows\\kafka-consumer-groups.bat --bootstrap-server localhost:9092 --list



bin\\windows\\kafka-consumer-groups.bat --bootstrap-server localhost:9092 --describe --group keys-group



result :

GROUP           TOPIC           PARTITION  CURRENT-OFFSET  LOG-END-OFFSET  LAG             CONSUMER-ID     HOST            CLIENT-ID

keys-group      keys-demo       0          2               2               0               consumer-1...   /127.0.0.1      console-consumer

keys-group      keys-demo       1          1               1               0               consumer-1...   /127.0.0.1      console-consumer

keys-group      keys-demo       2          2               5               3               consumer-2...   /127.0.0.1      console-consumer



lab 5

bin\\windows\\kafka-topics.bat --create --topic retention-demo --bootstrap-server localhost:9092 --partitions 1 --replication-factor 1



bin\\windows\\kafka-console-producer.bat --bootstrap-server localhost:9092 --topic retention-demo



bin\\windows\\kafka-console-consumer.bat --bootstrap-server localhost:9092 --topic retention-demo --from-beginning



Lab 7: Offset Demo



mode latest:

bin\\windows\\kafka-console-consumer.bat --bootstrap-server localhost:9092 --topic retention-demo



mode beginning

bin\\windows\\kafka-console-consumer.bat --bootstrap-server localhost:9092 --topic retention-demo --from-beginning



lab 8

bin\\windows\\kafka-topics.bat --create --topic metadata-demo --bootstrap-server localhost:9092 --partitions 2 --replication-factor 1 --config retention.ms=3600000



bin\\windows\\kafka-topics.bat --describe --topic metadata-demo --bootstrap-server localhost:9092



result: 

Topic: metadata-demo  TopicId: A1b2C3d4E5f6G7h8  PartitionCount: 2  ReplicationFactor: 1  Configs: retention.ms=3600000

Topic: metadata-demo  Partition: 0  Leader: 0  Replicas: 0  Isr: 0

Topic: metadata-demo  Partition: 1  Leader: 0  Replicas: 0  Isr: 0





