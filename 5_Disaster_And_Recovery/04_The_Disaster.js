// ==============================================================
// MongoDB Master DR Suite
// Phase 5A: The Catastrophe
// ==============================================================

// Execute this via mongosh connected to the mongos router!
// Example: docker exec -it mongos mongosh --port 27017

use EnterpriseSales;

print("...Simulating malicious actor dropping the entire Transactions collection...");
db.Transactions.drop();

print("CRITICAL DATA DESTROYED.");

// Now quickly execute the PowerShell rescue script!
