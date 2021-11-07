# Kubernetes Notes

## Set config default zone

```
gcloud config set compute/zone us-east4-b
```

## Enable admin access to the current user

```
gcloud container clusters get-credentials $CLUSTER_NAME --zone=us-east4-b
kubectl create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin
```

## Listing RoleBindings and ClusterRoleBindings per ServiceAccount

```
kubectl get rolebindings,clusterrolebindings \
--all-namespaces  \
-o custom-columns='KIND:kind,NAMESPACE:metadata.namespace,NAME:metadata.name,SERVICE_ACCOUNTS:subjects[?(@.kind=="ServiceAccount")].name'
```
