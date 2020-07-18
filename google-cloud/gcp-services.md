# Google Cloud - Main Services

## Setting Location

Setting the location for one of the following services also sets the location for the others. After you set your project's default GCP resource location, you cannot change it

## Location of Firebase Realtime Database

Default GCP resource location does not apply to Firebase Realtime Database

## Location of Cloud Storage

Default GCP resource location only applies to your default Cloud Storage bucket. If you're on the Blaze plan, you can create multiple buckets, each with its own location.

## Multi-region locations

A multi-region location is a general geographical area, such as the United States. Data in a multi-region location is replicated in multiple regions. Within a region, data is replicated across zones.

Select a multi-region location to maximize the availability and durability of your database. Multi-region locations can withstand the loss of entire regions and maintain availability without losing data.

Firebase supports the following multi-region GCP resource locations: us-central and europe-west

## Cloud Storage

Objects (files, static websites)

## Cloud Datastore

NoSQL

## Cloud SQL

MySQL and PostgreSQL

## Cloud Dataflow

Fully managed service to create pipelines for data processing
Can handle streaming (live) or batch (archived) data
Based on Apache Beam
Serverless

## Cloud Dataproc

Fully managed cluster data processing
Compatible with Apache Hadoop, Spark and Hive
Can scale cluster up or down without stopping the job
More control to DevOps operations

## Cloud PubSub

Fully managed messaging middleware service
Allows secure and high available messages between independent aps
Works with both Google Cloud and external services
Full range of communication:
- One to many
- Many to one
- Many to many
Both push and pull options
Use cases: streaming data, event notifications, asynchronous workflows, etc

## Cloud DataLab

Interactive data analysis and machine learning environment
Package as container and runs in a VM instance
Based on Jupyter Notebooks
Notebooks:
- Contain code, docs in markdown, and code results
- Code results can be text, image, Javascript, or HTML
- Can be shared with team members
- Collections of cells containing code or markdown

## Cloud DataStudio

Interactive report and big data visualizer
Creates dashboards, charts, and tables
Connects to Cloud BigQuery, Cloud Spanner, Cloud SQL, and Cloud Storage
Stores shareable files in Google Drive

## Cloud CDN

Accelerates delivery from Compute Engine and Cloud Storage

Lowers network latency, offloads origin servers, and reduces serving costs

Features included:

- Offers SSL with no additional cost
- Supports cache invalidation
- Cache-to-cache filling supported
- 
General availability caches to 10GB, Large Object Caching (beta) to 5TB

Caching considerations:

- Caching is reactive
- Caches cannot be pre-loaded
- Once enabled, caching is automatic
- HTTP(S) load balancer is required

## Cloud AI

Collection of services and APIs designed to facilitate machine learning

Includes hardware accelerators: TPU (TensorFlow Processing Unit)

Primary service: Cloud Machine Learning Engine (ML Engine)

- Training
    - Trains computer models to recognize patterns in data
    - Supports TensorFlow, scikit-learn, and XGBoost
- Prediction
    - Online: Real-time processing with fully managed ML Engines
    - Online: No Docker container required & supports multiple frameworks
    - Batch: For asynchronous operations
    - Batch: Scales to terabytes of data

## Cloud Data Transfer

Range of options available for transferring data to Google Cloud:

Online Transfer: console upload, JSON REST API, gsutil

Storage Transfer Service:

- Imports online data to Cloud Storage
- Supports transfer of objects from AWS S3
- 
Transfer Appliance:

- Physical device loaded on-prem and shipped to Google data center
- Single device can hold petabyte of data
- Far faster then online transfer for large amounts of data

## Cloud BigQuery

Fully managed data warehouse for big data

- Near real-time interactive analysis of massive datasets
- Analyze terabytes of data in seconds
- Standard SQL supported
- Storage and computing handled and billed separetely
- Query public or commercial dataset with your own
- External services queries: Cloud Storage, Cloud Bigtable & Google Drive
- Automatic data replication
- Modify data with Data Definition Language
- Use cases: real-time inventory, predictive digital marketing, analytical events

## Stackdriver

- Collection of 5 services
- Monitoring
- Debug
- Trace
- Logging
    - Auditing logs:
    - Who did what, where, when?
    - Cannot be deleted
    - Admin activity - administrative actions
    - Security-focused logs
    - no charge
    - 400 days retention period
- Error reporting
- Export to Cloud Storage for backup
- Export to BigQuery for analysis
- Export to Pub/Sub to use with other applications
    - Exports only add new data since sink creation, not older
    - It's not on real-time, consider a delay