# Creating a Kubernetes Cluster VPC-Native and Workload Identity Enabled

### Notes regarding to VPC-Native clusters:

- It uses the subnet's primary IP address range for all node IP addresses.
- It uses one secondary IP address range for all Pod IP addresses.
- It uses another secondary IP address range for all Service (cluster IP) addresses.


### Setting default values

```
gcloud config set project $PROJECT_ID
gcloud config set compute/zone $COMPUTE_ZONE
gcloud config set compute/region $COMPUTE_REGION
gcloud components update
```


### Listing available kubernetes cluster versions

```
gcloud container get-server-config
```


### Creating the GKE Cluster in and existing subnet

```
export CLUSTER_NAME=my-gke-cluster
export REGION=us-east4
export SUBNET_NAME=default
export POD_IP_RANGE="10.20.0.0/14"
export SERVICES_IP_RANGE="10.24.0.0/20"
export KUBERNETES_VERSION="1.20.10-gke.301"

gcloud container clusters create $CLUSTER_NAME \
  --region=$REGION \
  --enable-ip-alias \
  --subnetwork=$SUBNET_NAME \
  --cluster-ipv4-cidr=$POD_IP_RANGE \
  --services-ipv4-cidr=$SERVICES_IP_RANGE
  --workload-pool=${PROJECT_ID}.svc.id.goog
  --cluster-version=$KUBERNETES_VERSION
```

[Creating a VPC-native cluster](https://cloud.google.com/kubernetes-engine/docs/how-to/alias-ips)

[Using Workload Identity](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity)


# Creating a Nood Pool with Workload Identity

```
export CLUSTER_NAME="my-gke-cluster"
export NODE_POOL_NAME=services-pool
export NUM_NODES=3
export MACHINE_TYPE=e2-highmem-4
export REGION=us-east4
export KUBERNETES_VERSION="1.20.10-gke.301"
export PROJECT_ID

gcloud container node-pools create $NODE_POOL_NAME \
  --cluster=$CLUSTER_NAME \
  --region=$REGION \
  --num-nodes=$NUM_NODES \
  --machine-type=$MACHINE_TYPE \
  --node-version=$KUBERNETES_VERSION \
  --workload-metadata=GKE_METADATA \
  --project=$PROJECT_ID
```

### Authenticating Workdload Identity to Google Cloud

```
export CLUSTER_NAME="my-gke-cluster"
export NAMESPACE="default"
export K8S_SERVICE_ACCOUNT="app_account"
export GCP_SERVICE_ACCOUNT="app_account"
export PROJECT_ID

gcloud container clusters get-credentials $CLUSTER_NAME
kubectl create namespace $NAMESPACE
kubectl create serviceaccount $K8S_SERVICE_ACCOUNT --namespace $NAMESPACE

# Create a Google Service Account to use for the application
gcloud iam service-accounts create $GCP_SERVICE_ACCOUNT --project=$PROJECT_ID

# Allow the Kubernetes service account to impersonate the Google service account
gcloud iam service-accounts add-iam-policy-binding \
    --role roles/iam.workloadIdentityUser \
    --member "serviceAccount:$PROJECT_ID.svc.id.goog[$NAMESPACE/$K8S_SERVICE_ACCOUNT]" \
    ${GCP_SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com

# Add the iam.gke.io/gcp-service-account=GSA_NAME@PROJECT_ID annotation to the Kubernetes service account, 
# using the email address of the Google service account.
kubectl annotate serviceaccount $K8S_SERVICE_ACCOUNT \
    --namespace $NAMESPACE \
    iam.gke.io/gcp-service-account=${GCP_SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com
```

#### Verify the service accounts are configured correctly

Verify the service accounts are configured correctly by creating a Pod with the Kubernetes service account
that runs the OS-specific container image, then connect to it with an interactive session.

1. Create a file named wi-test.yaml with the content below

```
apiVersion: v1
kind: Pod
metadata:
  name: workload-identity-test
  namespace: ${NAMESPACE}
spec:
  containers:
  - image: google/cloud-sdk:slim
    name: workload-identity-test
    command: ["sleep","infinity"]
  serviceAccountName: ${K8S_SERVICE_ACCOUNT}
```

2. Create a Pod

```
kubectl apply -f wi-test.yaml
```

3. Open an interactive session in the Pod:

```
kubectl exec -it workload-identity-test --namespace $NAMESPACE -- /bin/bash
```

4. You are now connected to an interactive shell within the created Pod. Run the following command inside the Pod:

```
gcloud auth list
```

If the service accounts are correctly configured, the Google service account email address
is listed as the active (and only) identity. This demonstrates that by default,
the Pod uses the Google service account's authority when calling Google Cloud APIs.


#### Using Workload Identity from your code

Authenticating to Google Cloud services from your code is the same process
as authenticating using the [Compute Engine metadata server](https://cloud.google.com/compute/docs/storing-retrieving-metadata). 
When you use Workload Identity, your requests to the instance metadata server
are routed to the [GKE metadata server](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity#gke_mds).
Existing code that authenticates using the instance metadata server (like code using
the [Google Cloud client libraries](https://cloud.google.com/docs/authentication/production#obtaining_credentials_on_compute_engine_kubernetes_engine_app_engine_flexible_environment_and_cloud_functions)) 
should work without modification.
