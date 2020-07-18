# Terraform - Variables

To create a variable to use in a terraform plan, use blocks as below in to your main.tf file:
```
variable [NAME] {
	[OPTION] = "[VALUE]"
}
```

**Arguments**: Within the block body (between { }) is the configuration for the variable, which accepts the following arguments:
- **type** (Optional): If set, this defines the type of the variable. Valid values are string, list, and map.
- **default** (Optional): This sets a default value for the variable. If no default is provided, Terraform will raise an error if a value is not provided by the caller.
- **description** (Optional): A human-friendly description for the variable.

## EXERCISE ONE

As an example, create a file main.tf with the following content:
---

```
#Define variables
variable "image_name" {
  description = "Image for container."
  default     = "ghost:latest"
}

variable "container_name" {
  description = "Name of the container."
  default     = "blog"
}

variable "int_port" {
  description = "Internal port for container."
  default     = "2368"
}

variable "ext_port" {
  description = "External port for container."
  default     = "80"
}

# Download the latest Ghost Image
resource "docker_image" "image_id" {
  name = "${var.image_name}"
}

# Start the Container
resource "docker_container" "container_id" {
  name  = "${var.container_name}"
  image = "${docker_image.image_id.latest}"
  ports {
    internal = "${var.int_port}"
    external = "${var.ext_port}"
  }
}

#Output the IP Address of the Container
output "ip_address" {
  value       = "${docker_container.container_id.ip_address}"
  description = "The IP for the container."
}

output "container_name" {
  value       = "${docker_container.container_id.name}"
  description = "The name of the container."
}
```

---

And apply the plan passing the variable as parameters:

```
$ terraform validate
$ terraform plan
$ terraform apply -var 'container_name=ghost_blog' -var 'ext_port=8080'
```

To destroy it, you'll also have to inform the parameters

```
$ terraform destroy -var 'ext_port=8080
```

## EXERCISE TWO - BREAKING OUT OUR VARIABLES AND OUTPUTS

Split the content in three files:

variables.tf

```
#Define variables
variable "container_name" {
  description = "Name of the container."
  default     = "blog"
}
variable "image_name" {
  description = "Image for container."
  default     = "ghost:latest"
}
variable "int_port" {
  description = "Internal port for container."
  default     = "2368"
}
variable "ext_port" {
  description = "External port for container."
  default     = "80"
}
```


main.tf

```
# Download the latest Ghost Image
resource "docker_image" "image_id" {
  name = "${var.image_name}"
}

# Start the Container
resource "docker_container" "container_id" {
  name  = "${var.container_name}"
  image = "${docker_image.image_id.latest}"
  ports {
    internal = "${var.int_port}"
    external = "${var.ext_port}"
  }
}
```


outputs.tf

```
#Output the IP Address of the Container
output "ip_address" {
  value       = "${docker_container.container_id.ip_address}"
  description = "The IP for the container."
}

output "container_name" {
  value       = "${docker_container.container_id.name}"
  description = "The name of the container."
}
```


Execute and save the plan

```
$ terraform validate
$ terraform plan -out=tfplan -var container_name=ghost_blog
$ terraform apply tfplan
```

Destroy it

```
$ terraform destroy -auto-approve -var container_name=ghost_blog
```


## USING MAP

variables.tf

```
#Define variables
variable "env" {
  description = "env: dev or prod"
}

variable "image_name" {
  type        = "map"
  description = "Image for container."
  default     = {
    dev  = "ghost:latest"
    prod = "ghost:alpine"
  }
}

variable "container_name" {
  type        = "map"
  description = "Name of the container."
  default     = {
    dev  = "blog_dev"
    prod = "blog_prod"
  }
}

variable "int_port" {
  description = "Internal port for container."
  default     = "2368"
}
variable "ext_port" {
  type        = "map"
  description = "External port for container."
  default     = {
    dev  = "8081"
    prod = "80"
  }
}
```


main.tf

```
# Download the latest Ghost Image
resource "docker_image" "image_id" {
  name = "${lookup(var.image_name, var.env)}"
}

# Start the Container
resource "docker_container" "container_id" {
  name  = "${lookup(var.container_name, var.env)}"
  image = "${docker_image.image_id.latest}"
  ports {
    internal = "${var.int_port}"
    external = "${lookup(var.ext_port, var.env)}"
  }
```

Execute the commands:

```
$ terraform validate
$ terraform plan -out=tfdev_plan -var env=dev
$ terraform apply tfdev_plan
$ terraform destroy destroy -var env=prod -auto-approve
```

## TEST vars

```
$ export TF_VAR_env=prod
$ terraform console
> lookup(var.ext_port, var.env)
$ unset TF_VAR_env
```

## OTHER WAYS TO WORK WITH VARIABLES

So, after defining a varible block, basically use can assign these values as:

1. hardcode on terraform file referring as var.[NAME]
2. pass via command line as
```
$ terraform plan -var 'region=us-east-1'
```
3. createing a terraform.tfvars specifing its contents as below:
```
region = "us-east-1"
```
4. if you create a .tfvars file using another filename, you're supposed to specify it on the command line:
```
$ terraform apply -var-file="secrets.tfvars" -var-file="prod.tfvars"
```
5. You can also pass variable values from environment variables. To do it, create you environment variables prefixing with TF_VAR_. 
   In the example above, you're supposed to create a environment variables TF_VAR_region=us-east-1

## VARIABLE TYPES

To use list variables, declare as>
```
cidrs = [ "10.0.0.0/16", "10.1.0.0/16" ] 
```

