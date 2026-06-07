# Lab M9.04: Sharding and Horizontal Partitioning Strategy Design

This document formalizes the architectural analysis required to design a highly scalable, distributed storage system for four major enterprise datasets.

---

## 1. Sharding Concepts Review

### Horizontal vs. Vertical Partitioning
* **Horizontal Partitioning (Sharding):** Involves splitting a table **by rows** across multiple physical nodes. Each node (shard) shares the same schema but holds a distinct subset of data. This approach provides near-infinite scalability for storage capacity and write throughput. It is best used when database size or write velocity exceeds a single server's limits.
* **Vertical Partitioning:** Involves splitting a table **by columns**. Heavy, wide, or rarely accessed attributes (e.g., BLOBs, long descriptions) are isolated into a separate table on the same node to optimize RAM usage for frequently queried columns. It is limited by the maximum number of columns in a table.

### Sharding vs. Indexing
Indexing creates a specialized data structure (usually a B-Tree) on a single server to accelerate read performance. **Indexing does not increase storage capacity or write throughput**; it merely reduces query execution time. Sharding becomes necessary when physical hardware limits (Disk I/O, CPU, or Storage) of a single node are reached. In a distributed environment, both are used together: each shard maintains its own local indexes.

---

## 2. Shard Key Selection

### Dataset 1: User Accounts
* **Proposed Shard Key:** `user_id`
* **Sharding Strategy:** Hash-based sharding
* **Justification:** The `user_id` provides maximum cardinality and an even distribution of both read and write traffic. Hashing prevents any chronological or geographical grouping effects. 
* **Trade-offs:** Lookup queries using secondary identifiers (like `email` or `username` during login) become cross-shard operations. To mitigate this, a centralized, cached global lookup table or an external routing index mapping `email -> user_id` will be implemented.

### Dataset 2: Transaction Records
* **Proposed Shard Key:** `user_id`
* **Sharding Strategy:** Hash-based sharding
* **Justification:** Choosing `user_id` ensures that all historical financial transactions for a specific customer are co-located on the same physical shard. This completely eliminates the need for expensive distributed cross-shard `JOIN` operations when rendering a user's transaction history ledger.
* **Trade-offs:** High-volume "power users" or enterprise merchant accounts may generate a disproportionate volume of data compared to individual accounts, creating data skew.

### Dataset 3: IoT Sensor Data
* **Proposed Shard Key:** `device_id`
* **Sharding Strategy:** Hash-based sharding
* **Justification:** Choosing `device_id` prevents severe time-series hot spotting. Sharding by `timestamp` alone would cause 100% of the real-time write traffic to hit a single shard (the "present moment"), leaving past shards idle. Hashing by `device_id` spreads the heavy write traffic uniformly across all available nodes.
* **Trade-offs:** Global analytical queries spanning a specific time frame across *all* devices will require a costly scatter-gather operation across all shards.

### Dataset 4: Orders by Region
* **Proposed Shard Key:** `region`
* **Sharding Strategy:** Directory/Range-based sharding
* **Justification:** This strategy physically hosts European customers' data on European servers and US customers' data on US servers. This drastically reduces network latency for the end-user (geo-proximity) and seamlessly ensures compliance with local data sovereignty regulations (such as GDPR).
* **Trade-offs:** The size of the shards depends entirely on market size. If the `US` market accounts for 80% of business transactions, the US shard becomes a hot partition.

---

## 3. Risk Analysis and Mitigation Strategies

| Dataset | Hot Shards Risk | Rebalancing Risk | Query Routing Risk | Data Skew Risk | Mitigation Strategies |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **User Accounts** | Low (Hashing smoothly distributes login spikes). | High if node count changes (requires re-evaluating hashes). | Medium (Email-based queries need a router). | Low | Implement **Consistent Hashing** to minimize data movement when adding shards. Use a global lookup cache for email routing. |
| **Transactions** | High (High-volume corporate merchant accounts). | Medium | Low (Queries naturally target a specific `user_id`). | High | Apply a **Salting** technique (appending a random suffix to the shard key) exclusively for whale accounts to split their data across sub-shards. |
| **IoT Sensor Data** | Low (When based on `device_id`). | High (Massive historical volume to redistribute). | High (For global system-wide analytical reporting). | Low | Avoid pure chronological sharding. Offload broad analytical historical queries to an asynchronous OLAP system (Data Lake). |
| **Orders by Region**| High (Dominant economic regions saturate their node). | Low (Geopolitical boundaries rarely shift). | Low for local operations; High for global headquarter reports. | High | Sub-shard high-density markets using a composite key (`region + hash(customer_id)`) to rebalance the cluster weight. |

---

## 4. Final Design Summary Matrix

| Dataset | Shard Key | Strategy | Primary Benefit | Main Risk | Mitigation |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **User Accounts** | `user_id` | Hash-based | Flawless, uniform write load balancing. | Secondary identifier query latency. | Centralized global routing index / Cache. |
| **Transactions** | `user_id` | Hash-based | Lightning-fast local user ledger retrievals. | Enterprise power-users overloading nodes. | Shard key salting for massive corporate accounts. |
| **IoT Sensor** | `device_id` | Hash-based | Fluid real-time ingestion without time bottlenecks. | Slow system-wide analytical scans. | Asynchronous ETL replication to an OLAP Data Lake. |
| **Orders by Region**| `region` | Directory | Data sovereignty (GDPR) and ultra-low latency. | Extreme storage imbalance between continents. | Composite sub-sharding by Customer ID inside regions. |