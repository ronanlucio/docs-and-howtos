# Google Cloud - Security

## Cloud IAM

Cloud IAM lets administrators authorize who can take action on specific resources, giving you full control and visibility to manage cloud resources centrally.

### IAM - Best Practices

- Use projects to isolate resouces
- Predefined over primitive roles, when possible
- Grant role by smallest scope
- Grant Owner role only if need to change IAM policy. Otherwise, use Editor
- Limit project creation with Project Creator role. Limit to those who are also Billing Account User
- Thoroughly understand policy inheritance
- Use groups when possible
- Only allow corporate account access. Can add outsiders via Cloud Identity account
- Service accounts
    - Restrict service account access
    - Don't expose service account keys unnecessarily
    - Don't delete service accounts still in use
- If same role needed across multiple projects, grant at organization of folder level

### IAM - Notes

- **Predifined roles** are granular permissions granted to individual services
- **Primitive roles** are broad/project-wide role permission granted to individual services

## Cloud KMS

Cloud KMS is a cloud-hosted key management service that lets you manage cryptographic keys for your cloud services the same way you do on-premises. You can generate, use, rotate, and destroy AES256, RSA 2048, RSA 3072, RSA 4096, EC P256, and EC P384 cryptographic keys. Cloud KMS is integrated with Cloud Identity and Access Management and Cloud Audit Logs so that you can manage permissions on individual keys and monitor how these are used. Use Cloud KMS to protect secrets and other sensitive data that you need to store in Google Cloud Platform.

## Cloud Audit Logs

Cloud Audit Logs helps security teams maintain audit trails in Google Cloud Platform (GCP). With this tool, enterprises can attain the same level of transparency over administrative activities and accesses to data in Google Cloud Platform as in on-premises environments. Every administrative activity is recorded on a hardened, always-on audit trail, which cannot be disabled by any rogue actor. Data access logs can be customized to best suit your organization's need around monitoring and compliance.

## Identity-Aware Proxy (IAP)

Identity-Aware Proxy (IAP) can help you control access to your cloud and on-prem applications and VMs running on Google Cloud Platform (GCP). IAP works by verifying user identity and context of the request to determine if a user should be allowed to access an application or a VM. IAP is a building block toward zero trust access, an enterprise security model that enables every employee to work from untrusted networks without the use of a VPN

## Options to Access a Private Server

- Cloud VPN
- Bastion host
- Interactive serial console
- Enable Private Google Access

## Private Google Access

Enable private access (instances without external IP) to reach GCP services with internal IP

- Services include BigQuery, Cloud Storage, Pub/Sub, etc
- Does not apply to Google Cloud SQL
- Enable at subnet level

## Compute Engine: Giving OS access

- Compute Instance Admin has full control over GCE settings
- OS Login role gives OS access, but nothing else (principle of least privilege)

Requirements for granting OS access

- Two roles required ("Service Account User" and "OS Login" or "OS Login Admin")
- Add metadata to enable OS Login (key=enable-oslogin, value=TRUE)

Accessing instance after role granted

- User can user SSH button (if viewer role is also enabled)
- User can also use gcloud compute ssh [instance_name]

## Cloud Armor

Google network security service that builds on the Global HTTP(S) Load Balancing service

- Ability to allow or restrict access based on UP address
- Predefined rules to counter cross-site scripting attacks
- Ability to counter SQL injections attacks
- Ability to define rules at both level 3 and level 7
- Allows restrict access based on the geolocation of incoming traffic