# Google Cloud - Compute

## Compute Engine

### Preemptive VMs

- Cheaper
- Will be terminated within 24 hours
- May not always be available
- Cannot migrate to a regular VM

### Custom Machine Types

Custom machine types can have between 1 and 64 vCPUs and up to 6.5GB of memory
per vCPU

### Attach GPU to an Instance

GPU are used for math-intensive applications such visualization and machine learning)

- you must an instance in which GPU libraries have been installed or will be installed. For example, you can use one of the GCP image that has GPU libraries installed, including the Deep Learning images
- you must also verify that the instance will run in a zone that has GPUs available
- when attaching GPUs, it's best to use an image that has the necessary libraries installed
- you will need to customize the configuration for the machine type (number of vCPUs, CPU platform, memory, GPUs, GPU type

There are some restrictions to use GPU

- The CPU must be compatible with the selected GPU
- if you add GPU to a VM, you must set the instance to terminate during maintenance

### Instance Monitoring

Default VM monitoring pages you can monitor CPU utilization, network and disk usage

### Listing VM Instances

You can filter by labels, internal IP external IP, status, zone, network, delete protection, member of instance group, and member of unnamed instance group

### Security Tab

The Security section from Management tab, is possible if you want to use a Shielded VM and Secure Shell (SSH) keys.

Shielded VMs are configured to have additional security mechanisms like:

- Secure Boot
- Virtual Trusted Platform Module (vTPM)
- Integrity Monitoring


## App Engine 

### Standard vs Flexible

- **Standard** can scale to zero, no write to disk, can't add custom libraries
- **Flexible** runs on docker containers. Users can customize their runtime environments by configuring a container.

### Scaling

3 types of scaling: Automatic, manual or basic

Flexible doesn't supports basic scaling

Basic scaling:

- Support max instances
- Doesn't support min instances

Automatic scaling:

- Support min and max_instances
- min and max_idle_instances
- min and max_pending_latency
- max_concurrent_requests
- target_cpu_utilization
- target_throughput_utilization

### Split Traffic

Traffic on App Engine can be split by:

- IP address
- Cookie (GOOGAPPID)
- Random

## Kubernetes 

### System Requirements

Kubernetes Engine reserves memory resources as follows:

- 25% for the first 4GB
- 20% for the next 4GB, up to 8GB
- 10% for the next 8GB, up to 16GB
- 6% for the next 112GB, up to 128GB
- 2% of any memory above 128GB

CPU resources are reserved as follows:

- 6% of the first core
- 1% of the next core, up to 2 cores
- 0.5% of the next 2 cores, up to 4 cores
- 0.25% of any above 4 cores

### Deployment States

Processing, Completed or Failed

### Nodes and Pods

- Node: a VM instances that runs containers configured to run an application. When you create a cluster, you can specify a machine type, which defaults to n 1-standard-1.
- Pod: a single instance of a running process in a cluster. Pods contains at least one container. Pods may share networking and storage across containers. Pods are generally created in groups. Replicas are copies of pods and constitute a group of pods that are managed as a unit. Pods support autoscaling as well. Pods are considered ephemeral.
- Controller: is the mechanism that manages scaling and health monitoring

### Services

A service, in Kubernetes terminology, is an object that provides API endpoints with a stable IP address that allow applications to discover pods running a particular application. Services update when changes are made to pods, so they maintain an up-to-date list of pods pods running an application

### ReplicaSet

ReplicaSets are controllers for ensuring that the correct number of pods are running.

When ReplicaSet detects there aren't enough pods for an application or workload, it will create another. ReplicaSet are also used to update and delete pods

### Deployments

Deployments are sets of identical pods. The members of the set may change as some pods are terminated and others are started, but they are all running the same application. The pods all run the same application because they are created using the same pod template.

A pod template is a definition of how to run a pod. The description of how to define the pod is called pod specification. Kubernetes uses this this definition to keep a pod in the state specified in the template. Thais is, if the specification has a minimum number of pods that should be in the deployment and the number falls below that, then the additional pods will be added to the deployment by calling on a ReplicaSet.

There are four actions available for deployments on Cloud Console: autoscale, expose, rolling update, and scale

### StatefulSets

StatefulSets are like deployments, but they assign unique identifiers to pods. This enables Kubernetes to track which pod is used by which client and keep them together.
StatefulSets are used when an application needs a unique network identifier or stable persistent storage

### Jobs

Jobs is an abstraction about workload. Jobs create pods and run them until the application completes a workload. Job specifications are specified in a configuration file and include specifications about the container to use and what command to run.

### Kubernetes Monitoring

Stackdriver is GCP's comprehensive monitoring, logging, and alerting product. It can be used to monitor Kubernetes cluster.

When creating a cluster, be sure to enable Stackdriver monitoring and logging by selecting Advanced Options in the Create Cluster form in Cloud Console. 

Under Additional Features, choose Enable Logging Service and Enable Monitoring Service.

### Kubernetes Command-line

The basic command for working with Kubernetes is:

```
$ gcloud beta container
```

In addition to installing Cloud SDK, you will need to install the Kubernetes command-line tool kubectl to work with clusters from the command line. You can do this with the following command:

```
$ gcloud components install kubectl
```

To view the status of clusters from command-line, use **gcloud container** commands

To get information about Kubernetes managed objects, like nodes, pods, and containers, use the **kubectl** command

#### To get cluster details

```
$ gcloud container clusters describe --zone us-central1-a standard-cluster-1
```

#### Maintainance on nodes and pods

Via command-line, to list information about nodes and pods, use the kubectl command.
First, you need to ensure you have a properly configured kubeconfig file, which contains information on how to communicate with the cluster API. Run the command
This will configure the kubeconfig file on a cluster named standard-cluster-1 in the us-central1-a zone.

```
$ gcloud container clusters get-credentials --zone us-central1-a standard-cluster-1
```

After that you can use commands

```
kubectl get nodes
kubectl get pods
kubectl describe nodes
kubectl describe pods
```

#### Add, Modify and Remove nodes

To increase the size of the cluster from 3 to 5,use this command

```
$ gcloud container clusters resize standard-cluster-1 --node-pool default-pool
```

To enable autoscaling, use this command

```
gcloud container clusters update standard-cluster-1 --enable-autoscaling --min-nodes 1 --max-nodes 5 --zone us-central1-a --node-pool default-pool
```

#### Add, Modify and Remove pods

Pods are managed through deployments. A deployment includes a configuration parameter called "replicas", which are the number of pods running the application specified in the deployment.

You can use kubectl command to work with deployments

To list deployments:

```
$ kubectl get deployments
```

To add and remove pods, change the configuration of deployments using kubectl scale deployment command, specifying deployment name and number of replicas:

```
$ kubectl scale deployment nginx-1 --replicas 5
```

To have Kubernetes manage the number of pods based on load, use the autoscaling command

```
$ kubectl autoscale deployment nginx-1 --max 10 --min 1 --cpu-percent 80
```

To remove a deployment, use the delete deployment command:

```
$ kubectl delete deployment nginx-1
```

#### Services

To list services you can, on cloud console, select workloads on the navigation menu to display a list of deployments.

When you click the name of a deployment, you'll see details of that deployment, including a list of services.

Clicking the name of a service opens the detail form of the service.

From command-line, use kubectl get services command to list services

To add a service, use the "kubectl run" command to start a service.

```
$ kubectl run example --image=gcr.io/google/samples/hello-app:1.0 --port 8080
```

Services that need to be exposed to be accessible to resources outside the cluster, can be done with the command

```
$ kubectl expose deployment example --type="LoadBalancer"
```

To remove a service, use:

```
$ kubectl delete service
```
