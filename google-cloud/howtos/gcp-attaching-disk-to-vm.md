# Attaching a Disk to a Compute Engine VM in GCP

## Add a new disk to VM Instance

When creating a VM Instance, confirm you added a new disk

1. Under **Additional disks**, click **Add new disk**
2. Specify a name for the disk, configure the disk's properties, and select **Blank** as the Source type
3. Click **Done** to complete the disk's configuration
4. Click **Save** to apply your changes to the instance and add the new disk


## Formatting and mounting a non-boot disk

After you create and attach the new disk to a VM, you must format and mount the disk, so that the operating system can use the available storage space

### Connect to the VM

Connect to the VM via **SSH**

### Format the disk

In the terminal, use the **lsblk** command to list the disks that are attached to your instance and find the disk that you want to format and mount.

```
lsblk
```

Supposing we're attaching the device named "sdb". Format the disk using **mkfs** tool. This command deletes all data from the specified disk, so make sure that you specify the disk device correctly.

```
 sudo mkfs.ext4 -m 0 -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb
```

### Mount the disk

Create a directory that serves as the mount point for the new disk

```
sudo mkdir -p /mnt/disk2
```

Mount the disk to the instance

```
sudo mount -o discard,defaults /dev/sdb /mnt/disk2
```

## Configuring automatic mounting on VM restart

Create a backup of your current /etc/fstab file.

```
sudo cp /etc/fstab /etc/fstab.backup
```

Use the **blkid** command to list the UUID for the disk

```
sudo blkid /dev/sdb
```

Open the /etc/fstab file in a text editor and create an entry that includes the UUID. For example:

Adjust UUID_VALUE and /mnt/MNT_DIR accordingly

```
UUID=UUID_VALUE /mnt/MNT_DIR ext4 discard,defaults,nofail 0 2
```


## References

https://cloud.google.com/compute/docs/disks/add-persistent-disk#console