# =================================================================
# 1_Sharded_Cluster_Setup\init-cluster.ps1
# This script initializes the MongoDB Replica Sets and configures 
# the Query Router (mongos) to enable sharding successfully.
# =================================================================

Write-Host "Waiting 10 seconds for all containers to fully start up..."
Start-Sleep -Seconds 10

Write-Host "`n[1/5] Initializing Config Server Replica Set (cfgrs)..."
docker exec -it configsvr1 mongosh --port 27019 --eval "rs.initiate({_id: 'cfgrs', configsvr: true, members: [{_id: 0, host: 'configsvr1:27019'}, {_id: 1, host: 'configsvr2:27019'}, {_id: 2, host: 'configsvr3:27019'}]})"

Write-Host "`n[2/5] Initializing Shard 1 Replica Set (shard1rs)..."
docker exec -it shard1_node1 mongosh --port 27018 --eval "rs.initiate({_id: 'shard1rs', members: [{_id: 0, host: 'shard1_node1:27018'}, {_id: 1, host: 'shard1_node2:27018'}, {_id: 2, host: 'shard1_node3:27018'}]})"

Write-Host "`n[3/5] Initializing Shard 2 Replica Set (shard2rs)..."
docker exec -it shard2_node1 mongosh --port 27018 --eval "rs.initiate({_id: 'shard2rs', members: [{_id: 0, host: 'shard2_node1:27018'}, {_id: 1, host: 'shard2_node2:27018'}, {_id: 2, host: 'shard2_node3:27018'}]})"

Write-Host "`nWaiting 15 seconds for nodes to elect Primaries..."
Start-Sleep -Seconds 15

Write-Host "`n[4/5] Abstracting Shards into Mongos Router..."
docker exec -it mongos mongosh --port 27017 --eval "sh.addShard('shard1rs/shard1_node1:27018,shard1_node2:27018,shard1_node3:27018'); sh.addShard('shard2rs/shard2_node1:27018,shard2_node2:27018,shard2_node3:27018');"

Write-Host "`n[5/5] Creating EnterpriseSales Database & Sharding Collection by CustomerID..."
$initCmd = "
use EnterpriseSales;
sh.enableSharding('EnterpriseSales');
db.createCollection('Transactions');
sh.shardCollection('EnterpriseSales.Transactions', { CustomerID: 'hashed' });
print('Sharding Registration Complete!');
"
docker exec -it mongos mongosh --port 27017 --eval $initCmd

Write-Host "`n=========================================================="
Write-Host " SUCCESS! MongoDB 10-Node Sharded Cluster is READY!"
Write-Host "=========================================================="
