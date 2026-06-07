# Business Scenarios

Scenario 1: Core Banking Transaction System



Recommended storeage type: RDBMS like PostgreSQL or Oracle Database

justification:

* Data structure requirements: banking data are highly structured, previsible and relational
* Query patterns: The system requires complex transactional queries(OLTP) involving aggregations and 

joins that are critical for auditing . Standard SQL excels in this area.

* Consistency needs: only an RDBMS guarantees strict adherence to ACID properties 
* Scalability requirements: Although NoSQL scales more easily, modern RDBMSs handle very high transaction volumes through sharding, primary/secondary replication, or via distributed relational databases 
* Trade-offs considered: Schema flexibility, The cost of scalability





Scenario 2: E-commerce Product Catalog





Recommended storage type: Document Store : MongoDB,Amazon DocumentDB

Justification 

* Data structure requirements: The lack of a fixed schema (schemaless) means new product categories or attributes can be added instantly without the need for database migration.
* Query patterns:  Users search for products by ID, category or via filters. JSON documents allow all product information (description, price, reviews, images) to be retrieved in a single read query, eliminating the need for costly joins
* Consistency needs: The product catalogue does not require strict ACID consistency down to the millisecond. The BASE model (eventual consistency) is more than sufficient: if updating a product description takes 1 second to propagate across all servers, this does not impact the business.
* Scalability requirements
* Trade-offs considered: Document Stores excel at horizontal scalability (sharding). The catalogue can be distributed across multiple servers to handle massive read traffic, particularly during sales periods or Black Friday.





Scenario 3: Telecom Call Detail Records 



Recommended storage type: Wide-column store ex: Apache Cassandra

Justification covering:

* Data structure requirements:  CDR records have a relatively stable structure (caller ID, called party ID, timestamp, duration, network type). The column family format allows billions of rows to be stored on disk in a highly compressed and efficient manner.
* Query patterns: The system is optimised for searches by key and by time range (e.g. retrieving a user’s calls between 1 and 5 June). By defining time as the clustering key, the required data is read contiguously from the disk, avoiding full scans.
* Consistency needs:  The BASE model (Eventual Consistency) is ideal here: if it takes two seconds for a call record to become visible to the overall billing system, this is not a problem, provided no calls are lost.
* Scalability requirements:  This is Cassandra’s strong point. Thanks to its decentralised architecture (masterless / peer-to-peer), write capacity increases in a strictly linear fashion: if you double the number of servers, you double the supported write speed. It handles petabytes of data with ease.
* Trade-offs considered: No complex ad-hoc queries



Scenario 4: Social Network Relationship Graph



Recommended storage type: Graph database ex: Neo4j

Justification covering:

* Data structure requirements: The data is inherently interconnected and non-tabular. The graph model (nodes for users, edges for relationships/actions, and properties to store details such as the date of the meeting) corresponds exactly to the business reality of a social network.
* Query patterns:  Graph query languages (such as Cypher or Gremlin) allow these patterns to be written in three lines of code, whereas SQL would require dozens of lines of recursive JOINs.
* Consistency needs: Eventual consistency (BASE) is widely acceptable. If a user clicks ‘Follow’ and it takes their friend 500 milliseconds to see the update to their follower list on another server, the user experience is not ruined. Availability and browsing speed take precedence.
* Scalability requirements:  Modern graph databases support partitioning and replication. 
* Trade-offs considered: Not at all suited to aggregate calculations



Scenario 5: IoT Sensor Data Ingestion



Recommended storage type: 

Justification covering:

* Data structure requirements: IoT data has a fixed, immutable structure (append-only), consisting of a timestamp, identifiers (e.g. sensor ID, machine type) and numerical measurements (e.g. temperature, voltage). TSDBs are specifically designed for this timestamp/value pair format
* Query patterns :  Queries involve filtering and aggregating data over specific time ranges to populate real-time graphs (e.g. calculating the moving average of a sensor over the last 10 minutes). TSDBs have native time-window functions that are much faster than traditional SQL.
* Consistency needs:  As with the IoT in general, eventual consistency (BASE) is more than sufficient.
* Scalability requirements:The system must handle a massive and constant write throughput
* Trade-offs considered: Unsuitable for relational data or updates







