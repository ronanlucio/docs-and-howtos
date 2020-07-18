# Google Cloud - Command-line

## Services

```
$ gcloud services list --available --sort-by="NAME"
$ gcloud services list --enabled --sort-by-"NAME"
$ gcloud services enable SERVICE_NAME
```

### Enable GKE API

```
$ gcloud services enable container.googleapis.com
```

## Create networks and subnets

```
$ gcloud compute networks list
$ gcloud compute networks subnets list

$ gcloud compute networks create mynetwork \
  --project=myproject \
  --subnet-mode=custom

$ gcloud beta compute networks subnets create mysubnet \
  --project=myproject \
  --network=mynetwork \
  --region=us-central1 \
  --range=172.28.0.0/24 \
  --enable-private-ip-google-access \
  --enable-flow-logs
```

## Firewall rules

```
$ gcloud compute firewall-rules create mynet-ssh \
  --network mynetwork \
  --allow tcp:22
  --source-ranges 192.168.1.12/32

$ gcloud compute firewall-rules create mynet-tdp \
  --network mynetwork \
  --allow tcp:3389
  --source-ranges 192.168.1.12/32

$ gcloud compute firewall-rules create mynetwork-internal-access \
  --network mynetwork \
  --allow tcp,udp,icmp \
  --source-ranges 10.28.0.0/24
```

## Storage

### list buckets
```
$ gsutil ls
```

### list all files in a bucket
```
$ gsutil ls gs://$BUCKET_NAME
```

### get bucket details
```
$ gsutil ls -L -b gs://BUCKET_NAME
```

### list all files ina bucket, including archived or versioned files
```
$ gsutil ls -a gs://$BUCKET_NAME
```

### make bucket
```
$ gsutil mb -p myproject -c regional -l us-central1 gs://mybucket/
```

### configure a bucket as a public bucket
```
$ gsutil iam ch allUsers:objectViewer gs://mybucket
```

### assign IAM role to a bucket
```
$ gsutil iam ch user:(user_email):(role1,role2) gs://(BUCKET)
```
 
### remove IAM role from a bucket
```
$ gsutil iam ch -d user:(user_email):(role1,role2) gs://(BUCKET)
```

### remove all roles from bucket for given user:
```
$ gsutil iam ch -d user:(user_email) gs://(BUCKET)
```

### delete all ACLS fro bucket for given user
```
$ gsutil acl ch -d (user_email) gs://(BUCKET)
```

### view buckets permissions
```
$ gsutil iam get gs://mybucket
```

### copy/upload a file to bucket
```
$ gsutil cp test.txt gs://mybucket/
```

### move a file from one bucket to another
```
$ gsutil mv gs://mybucket1/test.txt gs://mybucket2/
```

### create a signed URL for temporary access
first, create a service account and download the json key
```
$ gsutil signurl -d 10m key.json gs://mybucket/myfile
```

### check current versioning policy
```
$ gsutil versioning get gs://$BUCKET_NAME
```

### enable object versioning
```
$ gsutil versioning set on gs://$BUCKET_NAME
```

### download current lifecycle policy to local machine to edit:
```
$ gsutil lifecycle get gs://$BUCKET_NAME > lifecycle.json
```

### set new lifecycle policy after making above edits:
```
$ gsutil lifecycle set lifecycle.json gs://$BUCKET_NAME
```

## PubSub

```
$ gcloud pubsub topics create my-topic-name --project myprojec
```

## Compute Engine

### Add a user ssh key to access the instance
```
$ gcloud compute instances add-metadata $INSTANCE_NAME --metadata-from-file ssh-keys=pub_keys.txt
```

### create a snapshot from a disk
```
$ gcloud compute disks snapshot $DISK_NAME --snapshot-names $NEW_NAME --zone us-central1-a
```

### list snapshots
```
$ gcloud compute snapshots list
```

### view details from a snapshot
```
$ gcloud compute snapshots describe $SNAPSHOT_NAME
```

### create a disk from a snapshot
```
$ gcloud compute disks create $DISK_NAME \
  --source-snapshot $SNAPSHOT_NAME \
  --zone us-central1-a
```

### resize a disk
```
$ gcloud compute disks rezise (disk_name) size=100 --zone=us-central1-a
```

### attach a disk to an instance
```
$ gcloud compute instances attach-disk (instance_name) --disk=(disk_name) --zone=(zone)
```

### create instance from a disk
```
$ gcloud compute instances create $INSTANCE_NAME \
  --disk name=$DISK_NAME,boot=yes \
  --zone us-central1-a \
  --tags=http-server
```

### create instance
```
$ gcloud compute instance create $INSTANCE_NAME \
  --image-family=ubuntu-1804-lts \
  --image-project=ubuntu-os-cloud \
  --zone=asia-south1-b \
  --machine-type=g1-small \
  --tags=http-server
```

## Kubernetes

### create a cluster
```
$ gcloud container clusters create (cluster_name) --num-nodes=2
```

### authenticate kubectl to point do the cluster
```
$ gcloud container clusters get-credentials (cluster_name)
```

### upgrade version of kubernetes cluster
```
$ gcloud container clusters upgrade (cluster_name)
```

### enable autoscaling for our kubernetes cluster
```
$ gcloud container clusters update (cluster_name) --enable-autoscaling --min-nodes 2 --max-nodes 8
```

### resize the kubernetes cluster setting a static number of nodes
```
$ gcloud container clusters resize --size=3 --zone=us-central1-b $CLUSTER_NAME
```

### list cluster
```
$ gcloud container clusters list
```

### deploy an application to kubernetes
```
$ kubectl create deployment hello-la --image=gcr.io/$DEVSHELL_PROJECT_ID/hello-la:v1
```

### list pods
```
$ kubectl get pods
```

### create a load balancer and expose the application
```
$ kubectl expose deployment (deployment_name) --type=LoadBalancer --port 80 --target-port 80
```

### find our load balancer frontend IP address
```
$ kubectl get services
```

### get details about a specific pod
```
$ kubectl describe pod $POD_NAME
```

### list nodes
```
$ kubectl get nodes
```

### get details about a specific node
```
$ kubectl describe node $NODE_NAME
```

### view logs on pod
```
$ kubectl logs (POD_ID)
```

### run a command inside a container
```
$ kubectl exec -it $POD_NAME -- /bin/ls -l
```

### deploy a new container to kubernetes
```
$ kubectl run demo --image=nginx --port 80
```

### list deployments
```
$ kubectl get deployments
```

### get details about a deployment
```
$ kubectl describe deployment $DEPLOYMENT_NAME
```

### delete a specific deployment
```
$ kubectl delete deployment $DEPLOYMENT_NAME
```

### scale up deployments adding a static number of replicas
```
$ kubectl scale deployment hello-la --replicas=3
```

### set autoscaling to out deployments
```
$ kubectl autoscale deployment (deployment_name) --max 6 --min 4 --cpu-percent 50
```

### update a deployment image
```
$ kubectl set image deployment/myapp myapp=gcr.io/$DEVSHELL_PROJECT_ID/myapp:v2
```

## App Engine

### list versions
```
$ gcloud app versions list
```

### split traffic in 50% between 2 versions:
```
$ gcloud app services --set-traffic default --splits=v1=.5,v2=.5
```
NOTE: where "default" is the service name

### split the traffic and set to split randomly
```
$ gcloud app services --set-traffic default --splits=v1=.5,v2=.5 --split-by=random
or
$ gcloud app services --set-traffic default --splits=v1=.5,v2=.5 --split-by=cookie
```

### list logs
```
$ gcloud app logs tail -s default
```

### delete an app version
```
$ gcloud app versions delete $VERSION
```

## IAM

### get project's policies
```
$ gcloud projects get-iam-policy (PROJECT_ID) > (filename).yaml
```

### updated IAM policy from updated file
```
$ gcloud projects set-iam-policy PROJECT_ID (filename).yaml
```

### Add single binding without downloading file
```
$ gcloud projects add-iam-policy-binding PROJECT_ID --member user:(user's email) --role roles/editor
```

## Deployment Manager

### create a deployment
```
$ gcloud deployment-manager deployments create (deployment_name) --config (config_file.yaml)
```

### delete deployment
```
$ gcloud deployment-manager deployments delete (deployment_name)
```

### preview a configuration without actually deploying it
```
$ gcloud deployment-manager deployments delete --preview (deployment_name)
```

### deploying a previewed deployment
```
$ gcloud deployment-manager deployments update (deployment_name)
```

## Containers and Images

### build a docker image
```
$ docker build -t gcr.io/$DEVSHELL_PROJECT_ID/myapp:v1 .
```

### list images
```
$ docker images
```

### authenticate gcloud as a docker credential helper
```
$ gcloud auth configure-docker
```

### push docker container into Container Registry
```
$ docker push gcr.io/$DEVSHELL_PROJECT_ID/myapp:v1
```
