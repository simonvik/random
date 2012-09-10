#!/bin/bash

BUILDENV="build/"
ROOTFS="${BUILDENV}/rootfs"
BOOTFS="${BUILDENV}/bootfs"
BOOTSIZE="64M"
IMAGE=""
MIRROR="http://http.debian.net/debian"

if [ $EUID -ne 0 ]; then
  echo "I can haz root?"
  exit 1
fi

#make build env
mkdir -p $BUILDENV

#set image
IMAGE="${BUILDENV}/rpi.img"

#Create empty image (200MiB)
dd if=/dev/zero of=$IMAGE bs=1MB count=400

#Mount it and stuff
DEVICE=`losetup -f --show $IMAGE`

fdisk $DEVICE << EOF
n
p
1

+$BOOTSIZE
t
c
n
p
2


w
EOF


losetup -d $DEVICE
device=`kpartx -va $IMAGE | sed -E 's/.*(loop[0-9])p.*/\1/g' | head -1`
device="/dev/mapper/${device}"
bootp=${device}p1
rootp=${device}p2


mkfs.vfat $bootp
mkfs.ext4 $rootp
mkdir -p $ROOTFS
mkdir -p $BOOTFS
mount $bootp $BOOTFS
mount $rootp $ROOTFS



#kpartx -d $image

