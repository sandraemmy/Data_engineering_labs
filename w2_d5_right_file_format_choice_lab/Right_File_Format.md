# Lab M10.04: Data Platform File Format Selection Strategy

This document establishes the strategic architectural choices for selecting file formats across five critical data flows within a large enterprise data platform.

---

## 1. Scenario-by-Scenario Deep Dive Analysis

### Scenario 1: Streaming Clickstream Ingestion
* **Characteristics:** High-velocity streaming, continuous append-only writes, schema evolution, exploratory read patterns, human-readable debugging needs.
* **Format Evaluation:**
  * *CSV:* Fast at writes but poor at managing nested structural variations and lacks nested objects.
  * *Parquet/ORC:* Highly inefficient for raw streaming writes; columnar formats require assembling rows in memory blocks before flushing to disk, which hurts real-time performance.
  * *JSON:* **Perfect fit.** Naturally flexible for multi-nested events, handles unexpected key-value additions seamlessly, and is natively human-readable.
* **Decision:** **JSON**

### Scenario 2: Daily Sales Analytics
* **Characteristics:** High-volume daily batch ingestion (billions of rows), highly analytical read pattern (aggregations on 5-10 specific columns out of 50+), extreme storage and cost optimization needs.
* **Format Evaluation:**
  * *CSV/JSON:* Scanning entire rows just to aggregate a single column forces heavy, unnecessary Disk I/O, resulting in poor query performance and high cloud compute costs.
  * *ORC:* Excellent option, but deeply tied to the Apache Hive ecosystem.
  * *Parquet:* **Perfect fit.** Industry-standard columnar storage with native column pruning and row group filtering. It delivers massive compression ratios and integrates flawlessly with modern distributed engines like Apache Spark and Trino.
* **Decision:** **Parquet**

### Scenario 3: Data Exchange with External Partners
* **Characteristics:** Moderate data volume, strict universal interoperability, human-readability requirement, fixed and predictable stable schema.
* **Format Evaluation:**
  * *JSON:* Good alternative, but parsing text objects introduces slightly more complexity for legacy systems compared to flat text.
  * *Parquet/ORC:* Unsuitable; requires partners to use specialized distributed frameworks or specific SDKs.
  * *CSV:* **Perfect fit.** The lowest common denominator in data exchange. Any program—from legacy enterprise systems to standard Microsoft Excel—can consume a flat CSV natively without specialized toolchains.
* **Decision:** **CSV**

### Scenario 4: Ad-Hoc Analyst Exploration
* **Characteristics:** Unpredictable queries, discovery-driven exploration of raw structures, small-to-medium volumes, immediate read/inspect capabilities.
* **Format Evaluation:**
  * *Parquet/ORC:* Requires setting up a query engine (such as Athena or DuckDB) just to view basic text lines.
  * *CSV:* Rigid if the dataset contains complex nested structures.
  * *JSON:* **Perfect fit.** Allows data analysts to visually preview the raw file topology using standard command-line tools (like `head` or `jq`) or any lightweight text viewer, enabling quick iteration.
* **Decision:** **JSON**

### Scenario 5: Long-Term Archival Storage
* **Characteristics:** High volume, cold data storage, compliance-driven, rare analytical lookups, append-only immutable files, storage cost is the paramount constraint.
* **Format Evaluation:**
  * *CSV/JSON:* Inefficient text representation wasting expensive petabyte-scale storage space.
  * *Parquet:* Great compression, but its compression algorithms are typically optimized for fast analytical query throughput over maximum space reduction.
  * *ORC:* **Perfect fit.** Optimized Row Columnar format features superior compression strip structures and advanced dictionary encoding (such as ZSTD/Snappy compression blocks). It yields a smaller byte footprint on disk than Parquet, minimizing cold storage costs while remaining queryable via SQL.
* **Decision:** **ORC**

---

## 2. Comprehensive Decision Table

| Scenario | Selected Format | Primary Justification | Read Pattern | Write Pattern | Schema | Performance | Interoperability | Trade-offs & Alternatives |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Streaming Clickstream** | **JSON** | Fast write speed and infinite schema flexibility for application logging. | Exploratory ad-hoc queries | Streaming, high throughput append | Highly fluid, evolving | Low latency ingestion, slower analytical scans | Highly compatible, human-readable | *Trade-off:* High storage footprint. *Alternative:* Avro is better for raw streaming but sacrifices human readability. |
| **Daily Sales Analytics** | **Parquet** | Industry-standard column pruning and dictionary encoding for analytical queries. | Columnar aggregations, BI dashboards | Batch processing (Daily) | Rigid, fixed schema | Fast read execution, optimal compression | Standard among modern data tools | *Trade-off:* High memory overhead during serialization writes. *Alternative:* ORC. |
| **Data Exchange** | **CSV** | Absolute universal cross-platform compatibility across third parties. | Row-based filtering / Loading | Batch export | Well-defined, static | Low-to-medium processing speed | Universal; works natively with any system | *Trade-off:* Lack of metadata or data types, risk of formatting drift. *Alternative:* XML/JSON. |
| **Ad-Hoc Exploration** | **JSON** | Zero configuration required to read raw schema properties instantly. | Inspecting raw structures, profiling | Irregular manual ingestion | Unknown, unstructured | Quick line previews, slow large aggregates | Universal text editor support | *Trade-off:* Highly verbose format. *Alternative:* CSV if data is strictly flat. |
| **Long-Term Archive** | **ORC** | Superior compression density, minimizing long-term storage expenditures. | Occasional compliance analytical lookups | Append-only batch archiving | Immutable, highly stable | Slower writes, compressed analytical reads | Requires Hadoop/Hive ecosystem tools | *Trade-off:* Limited tool ecosystem support compared to Parquet. *Alternative:* Parquet with ZSTD. |

---

## 3. Detailed Justification Matrix

### Format: Streaming Clickstream Ingestion
* **Selected Format:** JSON
* **Read/write patterns:** Clickstream data writes continuously at an intense rate. Stream ingestion engines can write text payloads like JSON with minimal computational overhead. Parquet is unviable here because it requires caching large chunks of data in memory to create row groups before saving.
* **Schema evolution:** Web applications change constantly. Front-end engineers regularly append new event keys. JSON naturally supports structural additions without causing fatal parser exceptions down the pipeline.
* **Performance:** Writing JSON is incredibly lightweight for ingestion microservices, ensuring near zero-latency persistence.
* **Interoperability:** JSON provides immediate readability for developers troubleshooting downstream consumers.
* **Trade-offs:** JSON files consume significant storage space. The architectural solution is to capture raw data in JSON within the **Bronze (Raw)** data lake zone, then run an orchestration job to clean and compact it into Parquet files in the **Silver/Gold** zones.

### Format: Daily Sales Analytics
* **Selected Format:** Parquet
* **Read/write patterns:** In analytics, users rarely select every single column (`SELECT *`). They typically request queries like "Total Revenue by Product Group". Parquet allows the system to skip irrelevant columns entirely (*Column Pruning*) and isolate only the required data blocks from disk.
* **Schema evolution:** Enterprise transactions maintain a reliable, strict schema. Parquet files embedded with metadata self-describe their column formats safely.
* **Performance:** Drastically accelerates BI tooling, analytical queries, and complex aggregations on large datasets.
* **Interoperability:** Natively supported across all modern cloud data engines (Spark, Snowflake, Presto, Databricks).
* **Trade-offs:** Generating Parquet files is heavy on memory and CPU during the batch write process, which is acceptable since the job executes once per day.

### Format: Data Exchange with External Partners
* **Selected Format:** CSV
* **Read/write patterns:** Data volume is moderate and flat. Partners query these files linearly or load them into external tracking databases.
* **Schema evolution:** Handled via a documented API contract. The schema remains predictable and stationary.
* **Performance:** Completely adequate for moderate files where data structure is linear.
* **Interoperability:** Perfect. CSV avoids forcing downstream business clients to configure specialized technology stacks.
* **Trade-offs:** Escaping commas, newlines, and managing encoding types (UTF-8 vs ASCII) requires rigorous parsing rules to prevent corruption.

### Format: Ad-Hoc Analyst Exploration
* **Selected Format:** JSON
* **Read/write patterns:** Analysts explore data sequentially to check properties and inspect nested records without prior knowledge of the file layout.
* **Schema evolution:** Unknown. Analysts apply *Schema-on-Read* techniques to parse variables dynamically.
* **Performance:** Fast for checking small portions of a file; not built for large analytics aggregations.
* **Interoperability:** Universally supported by local command-line tools (`jq`), IDE extension viewers, and programming scripts.
* **Trade-offs:** File sizes are large due to repetitive metadata headers, which is acceptable for low-volume sandbox environments.

### Format: Long-Term Archival Storage
* **Selected Format:** ORC
* **Read/write patterns:** Writes are done once via cold archival jobs. Read requests occur rarely, usually triggered by sudden financial or legal compliance audits.
* **Schema evolution:** Completely frozen and immutable.
* **Performance:** Superior indexing properties (Stripe statistics) allow deep analytical inquiries to complete successfully when needed.
* **Interoperability:** Confined mostly to Hadoop, Hive, or open-source query platforms, which fits enterprise data platform infrastructure perfectly.
* **Trade-offs:** Slower creation times and less software integration compared to Parquet, but optimal for minimizing long-term storage costs.

---

## 4. Reusable Decision Framework

Use this framework to guide future file format selection decisions within the data platform: