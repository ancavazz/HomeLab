if [ ! -f debian-12-generic-amd64.qcow2 ]
        then
        wget https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2
        fi

# Set the VM ID to operate on
VMID=9502
# Choose a name for the VM
TEMPLATE_NAME=K3S-Worker
# Choose the disk image to import
DISKIMAGE=debian-12-generic-amd64.qcow2
# Select Host disk
HOST_DISK=local-lvm
# Set dimension disk
DISKDIM=32G
# Set core number
CORE=2
# Set ram dimension
RAM=10240

# Create the VM
qm create $VMID --name $TEMPLATE_NAME --net0 virtio,bridge=vmbr0
# Set the OSType to Linux Kernel 6.x
qm set $VMID --ostype l26
# Import the disk
qm importdisk $VMID $DISKIMAGE $HOST_DISK
# Attach disk to scsi bus
qm set $VMID --scsihw virtio-scsi-pci --scsi0 $HOST_DISK:vm-$VMID-disk-0
# Set scsi disk as boot device
qm set $VMID --boot c --bootdisk scsi0
# Resize scsi0 disk
qm disk resize $VMID scsi0 $DISKDIM
qm set $VMID --cores $CORE --memory $RAM
# Create and attach cloudinit drive
qm set $VMID --ide2 $HOST_DISK:cloudinit
# Set serial console, which is needed by OpenStack/Proxmox
qm set $VMID --serial0 socket --vga serial0
# Enable Qemu Guest Agent
qm set $VMID --agent enabled=1 # optional but recommened

# Convert in template
qm template $VMID