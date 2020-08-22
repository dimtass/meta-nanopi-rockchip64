DESCRIPTION="Upstream's U-boot configured for allwinner devices"
AUTHOR = "Dimitris Tassopoulos <dimtass@gmail.com>"
LICENSE = "GPLv2+"

require recipes-bsp/u-boot/u-boot.inc

FILESEXTRAPATHS_prepend := "${THISDIR}/files:${THISDIR}/../../scripts:"

DEPENDS += "bc-native dtc-native swig-native python3-native bison-native flex-native"

COMPATIBLE_MACHINE = "(rk3328)"

DEFAULT_PREFERENCE = "1"

EXTRA_OEMAKE += ' HOSTLDSHARED="${BUILD_CC} -shared ${BUILD_LDFLAGS} ${BUILD_CFLAGS}" '

SRC_URI = " \
        git://gitlab.denx.de/u-boot.git;branch=master \
        file://armbian-patcher.sh \
        file://patches-${SOC_FAMILY}-${UBOOT_VERSION} \
    "

S = "${WORKDIR}/git"
B = "${WORKDIR}/build"
do_configure[cleandirs] = "${B}"