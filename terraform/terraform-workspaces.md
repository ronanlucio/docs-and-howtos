
# WORKING WITH WORKSPACES

Terraform commands:
workspace: New, list, select and delete Terraform workspaces

Workspace subcommands:
- **delete**: Delete a workspace
- **list**: List Workspaces 
- **new**: Create a new workspace
- **select**: Select a workspace 
- **show**: Show the name of the current workspace

### Create a dev workspace:
```
$ terraform workspace new dev
```

### Plan the dev deployment:
```
$ terraform plan -out=tfdev_plan -var env=dev
```

### Apply the dev deployment:
```
$ terraform apply tfdev_plan
```

### Change workspaces:
```
$ terraform workspace new prod
```

### Plan the prod deployment:
```
$ terraform plan -out=tfprod_plan -var env=prod
```

### Apply the prod deployment:
```
$ terraform apply tfprod_plan
```

### Select the default workspace:
```
$ terraform workspace select default
```

### Find what workspace we are using:
```
$ terraform workspace show
```

### Select the dev workspace:
```
$ terraform workspace select dev
```

### Destroy the dev deployment:
```
$ terraform destroy -var env=dev
```
