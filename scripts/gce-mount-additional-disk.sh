#!/bin/bash

# Create disk for storing influxdb-data
DISK_NAME="influxdb2-disk"
DISK_SIZE_GB=20
ZONE="australia-southeast1-b"
DISK_TYPE="pd-ssd"
LABELS="server=true,service-type=monitoring"

gcloud compute disks create $DISK_NAME \
    --zone=$ZONE \
    --size="${DISK_SIZE_GB}GB" \
    --type=$DISK_TYPE \
    --labels $LABELS

# Attach disk to the instance
INSTANCE_NAME="influxdb2"
gcloud compute instance attach-disk $INSTANCE_NAME --disk $DISK_NAME

# Formatting and mouting disk
# First, SSH into VM instance
# Second, execute commands below to format the disk

DEV_NAME=$(lsblk | grep disk | tail -n 1 | awk '{print $1}')
echo "Device name is: ${DEV_NAME}"

# Do not format if its the VM's boot disk
if [[ "$DEV_NAME" != "sda" ]]; then

    # Confirm there's no file system on the disk
    FILE_RESULT=$(file -s /dev/${DEV_NAME} | awk '{print $2}')

    # Format disk in case there's no file system
    if [[ "$FILE_RESULT" == "data" ]]; then
        sudo mkfs.ext4 -m 0 -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/${DEV_NAME}
    fi
fi

# Create the mounting point
DIR_NAME="/data"
if [[ -d DIR_NAME ]]; then
    echo "info: mounting poing ${DIR_NAME} already exists"
else
    sudo mkdir -p /${DIR_NAME}
fi

# Mount disk
sudo mount -o discard,defaults /dev/${DEV_NAME} ${DIR_NAME}

# Grant read and write permissions to the disk for all users
sudo chmod a+w ${DIR_NAME}

# Reboot
sudo reboot

# Add disk to /etc/fstab to automatically mount on VM restart
# Backup current /etc/fstab
sudo cp /etc/fstab /etc/fstab.backup

# Get disk's UUID
UUID_VALUE=$(blkid /dev/${DEV_NAME} | awk '{print $2}')
# Remove double quotes
UUID_VALUE=${UUID_VALUE//\"/}
# Remove "UUID=" prefix
UUID_VALUE=${UUID_VALUE//UUID=/}

# Add mount entry to /etc/fstab
if grep -q ${UUID_VALUE} /etc/fstab; then
    echo "/etc/fstab already contains a UUID entry. /etc/fstab NOT CHANGED"
else
    echo "UUID=${UUID_VALUE} ${DIR_NAME} ext4 discard,defaults 0 2" | sudo tee -a /etc/fstab
fi

# Now we have a disk created and formatted, let's create an instance template

# Create instance template
TEMPLATE_NAME="influxdb2-template"
gcloud compute instance-templates create $TEMPLATE_NAME \
    --machine-type e2-small \
    --image-family ubuntu-2004-lts \
    --image-project ubuntu-os-cloud \
    --boot-disk-size 20GB \
    --disk name=${DISK_NAME},mode=rw,auto-delete=no \
    --tags influxdb

# or, to create an instance template from an existent VM
TEMPLATE_NAME="influxdb2-template"
SOURCE_INSTANCE_NAME="influxdb2-base"
SOURCE_INSTANCE_ZONE="us-central1-a"
gcloud compute instance-templates create $TEMPLATE_NAME \
    --source-instance $SOURCE_INSTANCE_NAME \
    --source-instance-zone $SOURCE_INSTANCE_ZONE \
    --configure-disk device-name=$DISK_NAME,instantiate-from=source-image,auto-delete=no \
    --tags influxdb


# CREATE MANAGED INSTANCE GROUPS

# Create a Managed Instance Group
MIG_NAME="influxdb2-mig"
gcloud compute instance-groups managed create $MIG_NAME \
    --base-instance-name $INSTANCE_NAME
    --size 1 \
    --template $TEMPLATE_NAME \
    --zone $SOURCE_INSTANCE_ZONE \
    --stateful-disk device-name=$DISK_NAME

# Set named-ports
# Named ports are key:value pair metadata representing the service name and 
# the port that it's running on. Named ports can be assigned to an instance group,
# which indicates that the service is available on all instances in the group. 
# This information is used by the HTTP Load Balancing service that will be
# configured later.
gcloud compute instance-groups set-named-ports $MIG_NAME \
    --named-ports influxdb:8086


# CONFIGURE AUTOHEALING

# To improve the availability of the application itself and to verify it is
# responding, configure an autohealing policy for the managed instance groups.

# Create a health check that repairs the instance if it returns "unhealthy" 3 consecutive times
gcloud compute health-checks create http influxdb2-hc \
    --port 8088 \
    --request-path=/ \
    --check-interval 30s \
    --healthy-threshold 1 \
    --timeout 10s \
    --unhealthy-threshold 3

# Create a firewall rule to allow the health check probes to connect to influxdb on port 8086
gcloud compute firewall-rules create allow-health-check-influxdb \
    --allow tcp:8086 \
    --source-ranges 130.211.0.0/22,35.191.0.0/16 \
    --network default

# Apply the health checks to their respective services
gcloud compute instance-groups managed update $MIG_NAME \
    --health-check influxdb2-hc \
    --initial-delay 300


# CREATE HTTP LOAD BALANCER

# Create health checks that will be used to determine which instances are
# capable of serving traffic for each service:
gcloud compute http-health-checks create influxdb2-ui-hc \
  --request-path / \
  --port 8086

# Create backend services that are the target for load-balanced traffic.
# The backend services will use the health checks and named ports you created
gcloud compute backend-services create influxdb2-ui \
  --http-health-checks influxdb2-ui-hc \
  --port-name influxdb2 \
  --global

gcloud compute backend-services add-backend influxdb2-ui \
  --instance-group $MIG_NAME \
  --instance-group-zone $ZONE \
  --global

# Create a URL map. The URL map defines which URLs are directed to which backend services
gcloud compute url-maps create influxdb2-map \
  --default-service influxdb2-ui

# Create a path matcher to allow access to  influxdb home (/) path to route
# to their respective service
gcloud compute url-maps add-path-matcher influxdb2-map \
   --default-service influxdb2-ui \
   --path-matcher-name influxdb2-ui \
   --path-rules "/"

# Create the proxy which ties to the URL map
gcloud compute target-http-proxies create influxdb2-proxy \
  --url-map influxdb2-map

# Create a global forwarding rule that ties a public IP address and port to the proxy
gcloud compute forwarding-rules create influxdb2-http-rule \
  --target-http-proxy influxdb2-proxy \
  --ports 8086 \
  --global



# SCALING INSTANCES

# Automatically Resize by Utilization
gcloud compute instance-groups managed set-autoscaling webapp-frentend-mig \
  --max-num-replicas 10 \
  --target-load-balancing-utilization 0.60

gcloud compute instance-groups managed set-autoscaling webapp-backend-mig \
  --max-num-replicas 10 \
  --target-load-balancing-utilization 0.60

# Enable Content Delivery Network
gcloud compute backend-services update webapp-fe-frontend \
    --enable-cdn --global


# UPDATING


