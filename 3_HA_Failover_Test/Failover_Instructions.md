# MongoDB High Availability (HA) Failover Demonstration

One of the primary enterprise benefits of MongoDB Replica Sets is **automatic failover** without application downtime. Here is how to test and prove it works in your cluster natively:

### Step 1: Start the Traffic Simulator
Run the overarching python simulator in a terminal:
```bash
python "d:\Traffic_Simulator.py"
```
You will see live data continuously streaming into the cluster.

### Step 2: Identify the Primary Node
Run the following command to check the Replica Set status of Shard 1 to see which node is the heavily targeted `PRIMARY`:
```bash
docker exec -it shard1_node1 mongosh --port 27018 --eval "rs.status()"
```

### Step 3: Assassinate the Primary!
In a new terminal window, ruthlessly kill the primary Docker container (e.g., if `shard1_node1` was Primary):
```bash
docker stop shard1_node1
```

### Step 4: Observe the Resiliency (The Magic)
Look back at your Python Traffic Simulator terminal. You may see a brief 1 to 3-second pause or a brief ServerSelectionTimeout warning as the Replica Set holds a rigorous background election and immediately promotes `shard1_node2` or `shard1_node3` to become the new Primary. 

**Within seconds, the Python script will automatically resume inserting data. Zero data impact to the end user!**

### Step 5: Bring the Node Back
Run the start command to bring the fallen node back from the dead:
```bash
docker start shard1_node1
```
It will seamlessly rejoin the cluster as a `SECONDARY` node and immediately sync the missing data via the Oplog.
