#!/bin/bash

# Clones a gold image, faster than deploying a new one
# Used in Linux Systems
# Very particular, used in my LAB, but with few modifications can be used anywhere
# Tested on: CentOS 7 Minimum Server
#            Ubuntu 14.04

# Created by: Jonatas B.
# Last mod: 20-11-2014

disk_pool="sdb1-guests"
disk_pool_path="/guests/"
gold_disk="centos7-gold.qcow2"
gold_name="centos7-gold"
gold_xml="/tmp/gold.xml"
gold_vnc_port="5903"
dest_disk="centos7-02.qcow2"
dest_name="centos7-02"
dest_vnc_port="5905"

# Ensure that gold is turnned off
virsh destroy "$gold_name" &> /dev/null

# Dump XML info from gold
virsh dumpxml "$gold_name" > "$gold_xml" 

# Make modifications on the XML file
sed -i "s/"$gold_name"/"$dest_name"/" $gold_xml
sed -i "/\<uuid\>/d" $gold_xml 
sed -i "/\<mac address\>/d" $gold_xml
sed -i "s/"$gold_disk"/$dest_disk/" $gold_xml
sed -i "s/'vnc' port='$gold_vnc_port'/'vnc' port='$dest_vnc_port'/" $gold_xml

# Cloning the gold disk
virsh vol-clone --pool "$disk_pool" "$gold_disk" "$dest_disk" &> /dev/null

# Preparing the disk
virt-sysprep -a "$disk_pool_path" "$dest_disk" &> /dev/null

# Define the guest
virsh define "$gold_xml" &> /dev/null

# Start the guest
virsh start "$dest_name" &> /dev/null

# Delete MXL
rm -rfv "$gold_xml" &> /dev/null
