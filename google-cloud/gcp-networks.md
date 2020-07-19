# GCP - Networks

## VPC

Virtual Private Cloud

- A distinguish feature of GCP is that a VPC can span the globe without relying on the public internet.

Private Network Compute

Adds network to Compute Engine, Kubernetes Engine, and App Engine

Cloud VPC includes:

- Firewalls
- Routes
- Forwarding rules
- Configurations of IP address, external or internal
- Shared VPC
- Network Peering


## Cloud Load Balancing

Is a software service that can load balance HTTP, HTTPS, TCP/SSL, and UDP traffic
Supports external and internal load balancing.

Fully managed incoming traffic service

Distributes traffic across several VM instances

Benefits:

- Autoscaling
- Support heavy traffic
- Route traffic to closest instance
- Detect and remove unhealthy instance

Supported types:

- Global external: HTTP(S), SSL, and TCP
- Regional external: TCP/UDP within a region
- Regional internal: Between groups of instances in a region


### TYPES

- HTTP(S) Load Balancing: (Layer7, Global scope, distribute traffic by location or content)
- SSL Proxy
- TCP Proxy
- Network TCP/UDP: (Layer4, Regional, External traffic, forward rules by address/port/protocol or and target pool (VM instance group)
- Internal TCP/UDP: Same as Network LB, but for Internal traffic

Global: HTTP(S), SSL Proxy, and TCP Proxy
Regional: Internal TCP/UDP, and Network TCP/UDP

### TRAFFIC

External: HTTP(S), SSL Proxy, TCP Proxy, and Network TCP/UDP
Internal: Internal TCP/UDP


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


## Cloud Interconnect

Is a set of GCP services for connecting your existing networks to the Google network.

- Two types of connections: interconnects and peering

Interconnect with direct access to networks uses the Address Allocation for Private Internets standard (RFC1918) to connect to devices on you VPC. A direct network connection is maintained between an on-premise or hosted data center and one of Google's collocation facilities.

Alternatively, if an organization cannot achieve a direct interconnect with a Google facility, it could use Partner Interconnect. This service depends on third-party network provider connectivity between the company's data center and Google facility.