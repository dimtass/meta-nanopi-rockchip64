require rockchip64.inc

SOC_FAMILY = "rk3328"
UBOOT_PATCHES ?= "rk3328"

RK_BIN_DIR = "rk33"
DDR_BLOB = "rk3328_ddr_333MHz_v1.16.bin"
MINILOADER_BLOB = "rk322xh_miniloader_v2.50.bin"
BL31_BLOB = "rk322xh_bl31_v1.42.elf"

SPL_BINARY = "u-boot-dtb.bin"

# Add the wks creation class. This will enable the custom
# wks file creation per image
IMAGE_FSTYPES += "ext4 rkboot wksbuild wic.bz2 wic.bmap"
IMAGE_CLASSES += "rk-boot-partition rk-create-wks"