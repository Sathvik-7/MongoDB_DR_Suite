import subprocess
import datetime
import os

print("==================================================")
print(" MongoDB Sharded Cluster Automated Backup ")
print("==================================================")

timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
# We save the backup inside the mongos docker container's mapped volume
backup_dir = f"/data/db/backups/Nightly_{timestamp}"

# Safely execute mongodump inside the mongos container without requiring local MongoDB tools installed
print(f"[{datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] Initiating cluster-wide mongodump via mongos router...")
dump_command = [
    "docker", "exec", "mongos", 
    "mongodump", "--port", "27017", "--out", backup_dir
]

try:
    result = subprocess.run(dump_command, capture_output=True, text=True, check=True)
    print("\nSUCCESS: Database Sharded Cluster backup completed.")
    print(f"Backup securely stored temporarily inside the mongos container at: {backup_dir}")
except subprocess.CalledProcessError as e:
    print(f"\nCRITICAL BACKUP FAILURE:\n{e.stderr}")
