#!/bin/bash

source ${CONFIG_PATH}

dateToday=$(date +%Y-%m-%d)

#BOOTSTRAP CHECKS
echo "####################Initiating $dateToday backup####################"

#Is SEAGATE harddisk mounted?

#Is disk even plugged?
echo "Checking for availability of $disk_label harddisk"
extDiskPlugged=$(lsblk -f | grep -i $disk_label | wc -l)

if [ "$extDiskPlugged" -eq 1 ]; then
  echo "Hard disk plugged -- will proceed"
else 
  echo "Hard disk not plugged -- please plug in your harddisk"
  exit 0
fi

#Disk is plugged in - mounting to external storage directory 

#device path
device=$(lsblk -f | grep -i $disk_label | cut -d' ' -f1 | sed 's/[^a-z0-9]*//g')
devPath="/dev/$device"

if [ -b "$devPath" ]; then
  echo "device path found -- mounting $devPath to $back_up_dir"
  mount $devPath $back_up_dir
else
  echo "device path not found"
  exit 0
fi

#Initiating writing of back up file
if [ ! -d "$back_up_dir/backup" ];then
  echo "Manually making backup folder in harddisk"
  mkdir -p "$back_up_dir/backup"
fi

echo "Proceeding with copying of files in VM!"

#Making back up now 
tar --xattrs --acls --one-file-system -cpzf "$back_up_dir/backup/archlinux-backup-$dateToday.tar.gz" --exclude=/proc --exclude=/sys --exclude=/dev --exclude=/run --exclude=/tmp / 

echo "Done copying -- proceeding with clean up: proceeding to retain $num_retain_files files"


#Cleaning up 
currentFiles=( $(ls -t "$back_up_dir/backup") )
to_delete=( "${currentFiles[@]: $num_retain_files}" )

for f in "${to_delete[@]}"; do
    echo "Deleting $f"
    rm -f "$back_up_dir/backup/$f"
done

echo "Script completed -- please remember to unmount later"

