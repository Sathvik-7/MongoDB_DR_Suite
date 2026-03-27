# 🍃 Enterprise MongoDB Sharded Cluster & DR Suite

A fully operational 10-node Sharded MongoDB environment simulating High Availability (HA) automatic failovers and Disaster Recovery (DR) data restoration mechanisms, executed entirely through Docker Compose and automated Python pipelines.

---

## 🏗️ The 10-Node Distributed Architecture

To properly showcase MongoDB's horizontal scaling and redundancy, the environment spins up exactly 10 containerized `mongod`/`mongos` instances:

1. **Config Servers (`cfgrs`):** 3-node Replica Set storing vital cluster metadata.
2. **Shard 1 (`shard1rs`):** 3-node Replica Set handling ~50% of the hashed data.
3. **Shard 2 (`shard2rs`):** 3-node Replica Set handling the remaining ~50% of the data.
4. **Query Router (`mongos`):** 1 instance directing traffic from the Python Application to the correct underlying shard.

---

## 📁 Project Structure

Here is the exact structure of the suite and what each component is responsible for:

```text
MongoDB_Master_DR_Suite/
│
├── 1_Sharded_Cluster_Setup/
│   └── init-cluster.ps1          # Binds replica sets and registers shards to the router.
│
├── 2_Traffic_Simulator/
│   └── Traffic_Simulator.py      # Python script injecting real-time retail transaction data.
│
├── 3_HA_Failover_Test/
│   └── Failover_Instructions.md  # Guide to manually killing nodes to test zero-downtime HA.
│
├── 4_Automated_Backups/
│   └── 03_AutoBackup.py          # Python mock-cron job executing full cluster logical backups.
│
├── 5_Disaster_And_Recovery/
│   ├── 04_The_Disaster.js        # Malicious script to completely wipe the transactions collection.
│   └── 05_The_Rescue.ps1         # Restoration script utilizing mongorestore.
│
├── docker-compose.yml            # Core definitions for the 10 containers and custom networking.
└── README.md                     # Project documentation.
```

---

## 🚀 Execution Phases

### 1. Cluster Initialization & Setup
The `docker-compose.yml` file builds the virtual network and cluster nodes. 
The `1_Sharded_Cluster_Setup/init-cluster.ps1` script binds the replica sets together, registers the shards to the `mongos` router, creates the `EnterpriseSales` mock database, and heavily configures a Hashed Shard Key on a `Transactions` collection to enforce even data distribution.

### 2. Live Application Traffic Integration
The `2_Traffic_Simulator/Traffic_Simulator.py` utilizes `pymongo` to safely connect to the `mongos` router. It continuously injects random retail transactions, demonstrating live, distributed data ingestion.

### 3. Automated Backup Pipeline
`4_Automated_Backups/03_AutoBackup.py` acts as a mock background cron job. It executes a seamless cluster-wide logical backup (`mongodump`) by securely interacting with the query router container.

### 4. High Availability (HA) Failover Demonstration
The instructions in `3_HA_Failover_Test/Failover_Instructions.md` walk the user through intentionally assassinating the Primary node of Shard-1 via Docker, causing a rigorous background election and proving that the Python Application experiences zero data loss during node failure!

### 5. Disaster Simulation & Rescue Operation
1. The user executes `5_Disaster_And_Recovery/04_The_Disaster.js` to maliciously drop the entire transactions collection. 
2. The user initiates `05_The_Rescue.ps1`, which interfaces with `mongorestore` to pull down the safely guarded dump file and cleanly recover the enterprise data.

---

## 💻 How to Run This Project Locally

**Prerequisite:** You MUST have Docker Desktop installed and running.

1. **Spin up the Cluster:** Run `docker-compose up -d` in the root directory. Wait ~15 seconds.
2. **Bind the Nodes:** Execute `.\1_Sharded_Cluster_Setup\init-cluster.ps1` in PowerShell.
3. **Pimp the Data:** Run `python 2_Traffic_Simulator\Traffic_Simulator.py`. Let it run in the background.
4. **Take the Backup:** Run `python 4_Automated_Backups\03_AutoBackup.py`. Look for the timestamp folder it generates. 
5. *(Optional) Test Failover:* Follow the instructions in `Failover_Instructions.md`.
6. **Trigger the Catastrophe:** `docker exec -it mongos mongosh --port 27017 < .\5_Disaster_And_Recovery\04_The_Disaster.js`
7. **Rescue the Database:** Run `.\5_Disaster_And_Recovery\05_The_Rescue.ps1` and provide the backup timestamp.
8. **Verify Rescue:** Ensure the data is back to life!

---
*Created by a Database Engineer specializing in Distributed NoSQL Systems, Sharding Architectures, High Availability, and Automations.*
