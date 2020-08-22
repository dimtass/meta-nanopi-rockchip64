require linux-stable.inc

LINUX_VERSION = "5.7"
PV = "5.7.17"

FILESEXTRAPATHS_prepend := "${THISDIR}/linux-stable_${LINUX_VERSION}:${THISDIR}/../../scripts:"

SRC_URI += " \
        git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git;branch=linux-${LINUX_VERSION}.y \
        ${ARMBIAN_URI} \
"
SRCREV = "3f45898cffc4e386952f3e4821810500adccea1f"

# If I don't do this then do_compile_kernelmodules fails with an
# error that <drv_types.h> is missing, while building the net/wireless
# drivers. I couldn't find the reason, but after a lot of testing
# I found this solution
B = "${S}"