# +--------+----------------+----------+-------------+---------+
# | Boot   | Terminology #1 | Actual   | Rockchip    | Image   |
# | stage  |                | program  |  Image      | Location|
# | number |                | name     |   Name      | (sector)|
# +--------+----------------+----------+-------------+---------+
# | 1      |  Primary       | ROM code | BootRom     |         |
# |        |  Program       |          |             |         |
# |        |  Loader        |          |             |         |
# |        |                |          |             |         |
# | 2      |  Secondary     | U-Boot   |idbloader.img| 0x40    | pre-loader
# |        |  Program       | TPL/SPL  |             |         |
# |        |  Loader (SPL)  |          |             |         |
# |        |                |          |             |         |
# | 3      |  -             | U-Boot   | u-boot.itb  | 0x4000  | including u-boot and atf
# |        |                |          | uboot.img   |         | only used with miniloader
# |        |                |          |             |         |
# |        |                | ATF/TEE  | trust.img   | 0x6000  | only used with miniloader
# |        |                |          |             |         |
# | 4      |  -             | kernel   | boot.img    | 0x8000  |
# |        |                |          |             |         |
# | 5      |  -             | rootfs   | rootfs.img  | 0x40000 |
# +--------+----------------+----------+-------------+---------+

AUTHOR = "Dimitris Tassopoulos <dimtass@gmail.com>"

IMAGE_ROOTFS_ALIGNMENT ?= "1024"

# u-boot image
RK_UBOOT_IMAGE ?= "${IMAGE_BASENAME}-${MACHINE}-uboot.img"
RK_BOOT_IMAGE ?= "${IMAGE_BASENAME}-${MACHINE}-boot.img"

# device will be used in u-boot and /etc/fstab
RK_STORAGE_DEVICE ?= "mmcblk0"

# This is the extra space for the rootfs
ROOT_EXTRA_SPACE ?= "4096"

# if you need swap file then add here the size of it
RK_SWAP_SIZE ?= "2048"

wks_build() {

    set -ex
    wks="${IMGDEPLOYDIR}/${IMAGE_BASENAME}.wks"

#### Common for all images
    cat >> "$wks" <<EOF
###
# This file is created by the rk-create-wks.bbclass script
# These are the partitions of the rk image
# Author: Dimitris Tassopoulos <dimtass@gmail.com>

bootloader --ptable gpt
part u-boot --source rawcopy --sourceparams="file=${RK_UBOOT_IMAGE}" --ondisk ${RK_STORAGE_DEVICE} --no-table --align 32
part /boot --source rawcopy --sourceparams="file=${RK_BOOT_IMAGE}" --ondisk ${RK_STORAGE_DEVICE} --fstype=vfat --label boot --align 1024 --active
part / --source rootfs --ondisk ${RK_STORAGE_DEVICE} --fstype=ext4 --label root --align 1024 --extra-space ${ROOT_EXTRA_SPACE}
EOF

#### Add swap file if SUNXI_SWAP_SIZE is set in rk-wks-defs.inc
    if [ ! -z "${RK_SWAP_SIZE}" ]; then
    cat >> "$wks" <<EOF
part swap --size ${RK_SWAP_SIZE} --ondisk ${RK_STORAGE_DEVICE} --label swap1 --fstype=swap --align 1024
EOF
    fi
}

IMAGE_CMD_wksbuild() {
    wks_build
}

# addtask do_image_wksbuild before do_rootfs_wicenv after do_image