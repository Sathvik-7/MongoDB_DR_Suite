# ==============================================================
# MongoDB Master DR Suite
# Phase 5B: Disaster Recovery Rescue
# ==============================================================

Write-Host "=================================================="
Write-Host " MongoDB Disaster Recovery Rescue Operation"
Write-Host "=================================================="
Write-Host "Restoring the last known good mongodump backup from the mongos container..."

# We will prompt you for the specific folder name created by the 03_AutoBackup.py script
$backupFolder = Read-Host "Enter the exact timestamp folder name you wish to restore (e.g., Nightly_20260325_150000)"

$fullPath = "/data/db/backups/$backupFolder"

Write-Host "Initiating mongorestore via Docker Exec on path: $fullPath ..."

docker exec -it mongos mongorestore --port 27017 --drop $fullPath

Write-Host "`nRescue Operation Completed Successfully! Let's check the database."
Write-Host "Run the following code to verify data:"
Write-Host "docker exec -it mongos mongosh --port 27017 --eval `"use EnterpriseSales; db.Transactions.countDocuments();`""
