import pymongo
import time
import random
import datetime

# Connect securely to the Mongos router (Wait for it on port 27022 based on docker-compose)
CONNECTION_STRING = "mongodb://localhost:27022/"

def insert_random_transaction(collection):
    transaction = {
        # Using CustomerID as the Hashed Shard Key ensures even distribution across Shard 1 and Shard 2!
        "CustomerID": random.randint(100, 9999), 
        "ProductID": random.randint(10, 99),
        "Quantity": random.randint(1, 20),
        "Revenue": round(random.uniform(15.0, 900.0), 2),
        "TransactionDate": datetime.datetime.now(),
        "RegionID": random.randint(1, 5)
    }
    collection.insert_one(transaction)

if __name__ == "__main__":
    print("==========================================================")
    print(" Starting MongoDB Sharded Traffic Simulator...")
    print("==========================================================")
    
    try:
        # 5 second timeout to make failures obvious if docker is down
        client = pymongo.MongoClient(CONNECTION_STRING, serverSelectionTimeoutMS=5000)
        
        # Test connection by pinging the admin database
        client.admin.command('ping')
        print("Successfully connected to the 'mongos' Query Router!\n")
        
        db = client["EnterpriseSales"]
        collection = db["Transactions"]
        
        transactions_inserted = 0
        
        print("Pumping live transactions into the Sharded Cluster. Press Ctrl+C to stop.")
        while True:
            insert_random_transaction(collection)
            transactions_inserted += 1
            
            if transactions_inserted % 10 == 0:
                print(f"[{datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] Inserted {transactions_inserted} live documents...")
                
            # Random wait (1 to 3 seconds) to mimic organic web traffic
            time.sleep(random.uniform(0.5, 2.0))
            
    except pymongo.errors.ServerSelectionTimeoutError:
        print("CRITICAL DEPLOYMENT ERROR: Cannot reach Mongos router at localhost:27022.")
        print("Is `docker-compose up -d` running? Did you execute `init-cluster.ps1`?")
    except KeyboardInterrupt:
        print(f"\nSimulator stopped safely. Total documents inserted: {transactions_inserted}")
    except Exception as e:
        print(f"Unexpected application error: {e}")
