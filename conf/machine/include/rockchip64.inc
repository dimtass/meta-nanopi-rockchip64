include conf/machine/include/arm/arch-armv8a.inc
include conf/machine/include/soc-family.inc

KERNEL_IMAGETYPE ?= "Image"

UBOOT_BINARY ?= "u-boot.itb"

KERNEL_DEVICETREE ?= "${ROCKCHIP64_KERNEL_DEVICETREE}"

OVERLAY_PREFIX ?= "rockchip"

SERIAL_CONSOLES = "1500000;ttyS2 1500000;ttyGS0"

PREFERRED_PROVIDER_virtual/kernel ?= "linux-stable"
PREFERRED_VERSION_linux-stable ?= "5.7%"

PREFERRED_VERSION_u-boot ?= "v2020.07%"
PREFERRED_RPROVIDER_u-boot-fw-utils ?= "u-boot-fw-utils"
PREFERRED_VERSION_u-boot-fw-utils ?= "v2020.07%"