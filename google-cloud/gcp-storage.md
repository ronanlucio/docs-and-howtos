# Google Cloud Storage

## Service: Cloud Datastore

NoSQL document database

- Managed service and automatically takes care of replication, backups, and other administration tasks
- Supports transactions, indexes, and SQL-like queries
- Cloud Datastore is well suited to applications that demand high scalability and structured data and do not always need strong consistency when reading data. Product catalogs, user profiles, and user navigation history are examples of kinds of applications that use Cloud Datastore

## Service: Cloud SQL

Managed relational database service that allows users to set up MySQL and PostgreSQL databases on VMs without having to attend to database administration tasks, such as backing up databases or patching database software

- Includes management of replication and allows automatic failover, providing high available databases
- Old generation: up to 16GB of RAM and 500GB of data store
- New generation: up to 416GB of RAM and 10TB of data store

## Service: Cloud Spanner

Fully-managed, enterprise-grade, relational database service

- Scales horizontally like NoSQL databases
- Add nodes to increase throughput and queries per second

## Service: Cloud BigTable

Fully managed, massively scalable NoSQL database service for big data

- No SQL-like language available
- Single key per row
- Capable of holding hundreds of petabytes of information
- Columns wide enough for entire webpages of satellite imagery
- Dinamic changes cluster size without stopping and restarting

## Service: Cloud MemoryStore

Fully-managed, in-memory datastore service

- Redis protocol compatible
- Instance tier: "Basic" (does no provide high-availability) or "Standard" (includes a separate replica in a separate zone for high availability - cannot downgrade later)

## Service: Cloud Firestore

NoSQL database

- Managed service
- It's client libraries provide offline support, synchronization, and other features for managing data across mobile devices, IoT devices, and backend data stores.
For example, applications on mobile devices can be updated in real time as data in backend changes.
- Includes Datastore mode, which enables applications written for Datastore to work with Cloud Firebase as well
- On Native mode, Cloud Firestore provides real-time data synchronization and offline support

## GCP - Types of Storage Services

- Object Storage: Cloud Storage
- Filestore: Based on NFS
- Block Storage: It's commonly used in ephemeral and persistent disks attached to VMs
- Cache


## Service: Cloud Storage

- Binary Large Object (BLOB) storage
- Images, videos, audio files, documents, static websites, etc
- Automatic data encryption at rest and decryption on delivery

### Location Types

Multi-region, Dual-region or Regional

### Storage Class Types

- **Standard**: Optimized for performance and high frequency access
- **Nearline**: Fast, high durable storage for data accessed less than once a month
- **Coldline**: Fast, high durable storage for data access less the once a quarter
- **Archive**: Cost-effective storage, long-term preservation of data accessed less than once a year

### Feature: Object Lifecycle Management

Define conditions that trigger data deletion or transition to a cheaper storage class.

### Feature: Object Versioning

Continue to store old copies of objects when they are deleted or overwritten
Disabled by default

### Feature: Retention Policies

Define minimum retention periods that objects must be stored for before they're deletable.

### Feature: Object Holds

Place a hold on an object to prevent its deletion.

### Feature: Customer-managed encryption keys

Encrypt object data with encryption keys stored by the Cloud Key Management Service and managed by you

### Feature: Customer-supplied encryption keys

Encrypt object data with encryption keys created and managed by you.

### Feature: Uniform bucket-level access

Uniformly control access to your Cloud Storage resources by disabling object ACLs

### Feature: Requester Pays

Require accessors of your data to include a project ID to bill for network charges, operation charges, and retrieval fees.

### Feature: Pub/Sub Notifications for Cloud Storage

Send notifications to Pub/Sub when objects are created, updated, or deleted.

### Feature: Cloud Audit Logs with Clod Storage

Maintain admin activity logs and data access logs for your Cloud Storage resources.

### Buckets

By default buckets are private

To set object to publicc grant viewer permission to AllUsers group

Buckets can have lifecycles, which a rules to apply actions moving objects to different storage classes

Objects support signed URLs for temporary access