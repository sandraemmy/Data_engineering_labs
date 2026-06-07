Markdown

### Step 1: Identify Entities

#### Subscriber
* **Purpose:** Represents a customer of the operator (caller or called party).
* **Attributes:** `subscriber_id` (INT), `phone_number` (VARCHAR), `first_name` (VARCHAR), `last_name` (VARCHAR), `registration_date` (DATE).
* **Candidate Keys:** `subscriber_id`, `phone_number`.

#### Call
* **Purpose:** Records each call detail record (CDR).
* **Attributes:** `call_id` (BIGINT), `caller_id` (INT), `receiver_id` (INT), `start_time` (TIMESTAMP), `duration_seconds` (INT), `call_type_id` (INT), `tower_id` (INT).
* **Candidate Keys:** `call_id`.

#### CallType
* **Purpose:** Categorises the call (Local, STD, ISD) for billing purposes.
* **Attributes:** `call_type_id` (INT), `call_type_name` (VARCHAR), `description` (TEXT), `rate_per_minute` (DECIMAL).
* **Candidate Keys:** `call_type_id`, `call_type_name`.

#### Tower (Base Station)
* **Purpose:** Identifies the network tower used during the call.
* **Attributes:** `tower_id` (INT), `tower_code` (VARCHAR), `location_name` (VARCHAR), `latitude` (DECIMAL), `longitude` (DECIMAL).
* **Candidate Keys:** `tower_id`, `tower_code`.

### Step 2: Design Keys & Relationships 

#### Cardinalities:
* **Subscriber → Call (caller):** 1:N (A subscriber can make multiple calls). `Call.caller_id` (FK). Required: Yes.
* **Subscriber → Call (receiver):** 1:N (A subscriber can receive multiple calls). `Call.receiver_id` (FK). Required: Yes.
* **CallType → Call:** 1:N (One call type applies to multiple calls). `Call.call_type_id` (FK). Required: Yes.
* **Tower → Call:** 1:N (One tower handles multiple calls). `Call.tower_id` (FK). Required: Yes.

### 3. Justification for Normalisation (3NF)
* **1NF:** Values are atomic (separation of `first_name` and `last_name`), no repeating groups.
* **2NF:** No partial dependencies. Non-key attributes depend on the entirety of their respective primary key.
* **3NF:** Removal of transitive dependencies. Details of the branch or tariff are not stored in the `Call` table but are isolated in their own dedicated tables. This avoids update anomalies (if a tariff changes, only a single row in `CallType` is modified).

### 4. Diagramme Entité-Relation (ERD)


erDiagram
    SUBSCRIBER ||--o{ CALL : "makes (caller)"
    SUBSCRIBER ||--o{ CALL : "receives (receiver)"
    CALL_TYPE ||--o{ CALL : "categorized as"
    TOWER ||--o{ CALL : "handled by"
 
    SUBSCRIBER {
        int subscriber_id PK
        string phone_number UK
        string first_name
        string last_name
        date registration_date
    }
 
    CALL {
        bigint call_id PK
        int caller_id FK
        int receiver_id FK
        timestamp start_time
        int duration_seconds
        int call_type_id FK
        int tower_id FK
    }
 
    CALL_TYPE {
        int call_type_id PK
        string call_type_name UK
        string description
        decimal rate_per_minute
    }
 
    TOWER {
        int tower_id PK
        string tower_code UK
        string location_name
        decimal latitude
        decimal longitude
    }