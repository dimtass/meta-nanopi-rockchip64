DESCRIPTION="Upstream's U-boot configured for allwinner devices"
AUTHOR = "Dimitris Tassopoulos <dimtass@gmail.com>"

require u-boot-rockchip64.inc

UBOOT_VERSION = "2020.07"

SRCREV = "2f5fbb5b39f7b67044dda5c35e4a4b31685a3109"
PV = "v${UBOOT_VERSION}+git${SRCPV}"