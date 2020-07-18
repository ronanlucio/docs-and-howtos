# Terraform - Basics

## TERRAFORM COMMANDS

1. Access https://terraform.io
2. Click on **Docs** and select **Terraform CLI**
3. Click on **Commands (CLI)**

### Most common used commands
- **apply**: Builds or changes infrastructure
- **console**: Interactive console
- **destroy**: Destroy infrastructure
- **fmt**: Rewrites config files in canonical format
- **get**: Downloads and installs modules
- **graph**: Creates a visual graph of resources
- **import**: Imports existing infrastructure
- **init**: Initializes a Terraform configuration
- **outpout**: Reads an output from a state file
- **plan**: Generates and shows a plan
- **providers**: Prints the providers used
- **push**: Uploads this Terraform module
- **refresh**: Updates local state file
- **show**: Inspects Terraform state or plan
- **taint**: Manually marks a resource for recreation

## FIRST EXERCISE - DOWNLOAD A CONTAINER IMAGE

### Create a directory
```
$ mkdir -p terraform/basics
$ cd terraform/basics
```

### Create the first script
Create a "main.tf" file with the following content:
```
	# Download the latest Ghost image
	resource "docker_image" "image_id" {
		name = "ghost:latest"
	}
```

### Initialize terraform configuration
```
$ terraform init
```

### Validate the terraform file
```
$ terraform validate
```

### List providers in the folder
```
$ ls .terraform/plugins/linux_amd64/
or
$ terraform providers
```

### Check the terraform plan (without applying it)
```
$ terraform plan
```

useful flags for plan:
- -out=path : writes a plan file to the given path. This can be used ad input to the apply command
- -var 'foo=bar' : Set a variable in the Terraform configuration. This flag can be set multiple times
so you can use

```
$ terraform plan -out=myplan
```

### Execute the plan / Apply terraform configuration

```
$ terraform apply
```

usuful flags for apply:
- -auto-aprprove: This skips interactive approval of plan before applying
- -var 'foo=bar' : This sets a variable in the Terraform configuration. It can be set multiple times
so you can use

```
$ terraform apply myplan
```

to test it:

```
$ docker image ls
$ terraform show
```

### To destroy everything we created in the plan
```
$ terraform destroy
```

to test it:

```
$ docker image ls
$ terraform show
```

## SECOND EXERCISE - START A CONTAINER

Edit the main.tf file as below:

```
# Download the latest Ghost image
resource "docker_image" "image_id" {
	name = "ghost:latest"
}

# Start the Container
resource "docker_container" "container_id" {
	name = "ghost_blog
	image = "${docker_image.image_id.latest"
	ports {
		internal = "2368"
		external = "80"
	}
}
```

### Validate the terraform file
```
$ terraform validate
```

### Check the plan
```
$ terraform plan
```

### Apply the changes
```
$ terraform apply
```

### Verifiy if everything is running properly
```
$ docker container ls
```

### Destroy it all
```
$ terraform destroy
```

## THIRD EXERCISE - CONSOLE AND OUTPUT

### Interacting with console
```
$ terraform console
```

Get container's name
```
> docker_container.container_id.name
```

Get container's ip address
```
> docker_container.container_id.ip_address
```

Exit console
```
CTRL-C
```

### To output attrbutes values, add the content below to the main.tf file
```
#Output the IP Address of the Container
output "ip_address" {
	value       = "${docker_container.container_id.ip_address}"
	description = "The IP for the container."
}

#Output the Name of the Container
output "container_name" {
	value       = "${docker_container.container_id.name}"
	description = "The name of the container."
}
```

and apply the plan:

```
$ terraform validate
$ terraform plan
$ terraform apply
```
