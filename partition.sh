#!bin/bash
echo "#######_____________________________PARTITIONS__________________________________########"
fdisk -l
echo "#####_________________creating partitons in /dev/sdb _______________________######"
cat << EOF | fdisk /dev/sdb 
n
p
1

+100M
w
EOF

echo "######--------------- partition of size 100MB is successfuly created---------------------#######"
echo"######---------------Formating  partition with ext4 filesysytem------------------------########"
mkfs.ext4  /dev/sdb1
echo "#####----------filesysytem formated succesfully-------------------------######"
echo "#####--------creating a directory for mounting---------------------------#######"
mkdir /dir1
echo "#####----------Making entry in /etc/fstab for permanent mounting--------------########"
echo "/dev/sdb1 /dir1  ext4 defaults 0 0" >> /etc/fstab
mount -a
mount 

echo "#######________________________creating swap partitions____________________________############"
echo "###-------creating a partition and adding that to swap partion----------------###"
cat << EOF | fdisk /dev/sdb
n
p
2

+100M
t
2
82
w
EOF

kpartx /dev/sdb
echo  "#######----------- swap partition of size 100 mb is successfully created------------########"
echo "########---------------formating the partition with swap file system-----------------##########"
mkswap  /dev/sdb2
echo "######------------Turning on the newly created swap space---------------#######"
swapon /dev/sdb2
swapon -s  #verify the swap space created
echo "#########------------Making the entry in /etc/fstab for permanent mounting---------------########"
echo "/dev/sdb2 swap swap  defaults 0 0 " >> /etc/fstab
free -g
echo "#######_____________________________LOGICAL VOLUME MANAGEMENT_______________________________#####"
echo "#####----------------creating partiton and adding tht to LVM-------------------#####"
cat << EOF | fdisk /dev/sdb
n
e
3

+100M
t
3
8e
w
EOF
echo
echo "###------------------lvm partition of size 100mb succesfully created-----------------------###"
kpartx /dev/sdb
echo "########--------------- pv creation---------------#####-"
pvcreate /dev/sdb3
pvdisplay
echo "###------------pv created successfully and dispalyed----------------------------####"
echo "###----------------creating volume  group of name - vg-------------------###"
vgcreate vg /dev/sdb3
vgdislay
echo "###-----------created and displayed volume group successfully -------------###"
echo "###----------creating logical volume of name  - vl and size 50M from volume group ---------####"
lvcreate -L 50M -n lv vg
lvdisplay
echo "###----------created  and displayed lv of size 50Mb succesfully-------###"
echo "##--------formating the partition  to ext4 filesysytem---------------------###"
mkfs.ext4 /dev/vg/lv
echo "####----------creating a directory for mounting-----------------------###"
mkdir /dir2
echo "###---------Making entry in /etc/fstab  for permanent mounting-----------###"
echo "/dev/vg/lv /dir2  ext4 defaults 0 0" >>/etc/fstab
mount -a
mount
echo "####_____created partition ,swap partition and LVM  partitions successfully__________###"
cat <<EOF | fdisk /dev/sdb
p
EOF




















