SUMMARY = "Rockchip console image"
AUTHOR = "Dimitris Tassopoulos <dimtass@gmail.com>"
LICENSE = "MIT"

inherit core-image

CORE_IMAGE_EXTRA_INSTALL_append = " packagegroup-core-ssh-openssh"
IMAGE_FEATURES += "package-management \
            debug-tweaks \
            hwcodecs \
            ssh-server-openssh \
            "
IMAGE_LINGUAS = "en-us"

BUSYBOX_SPLIT_SUID = "0"

SDK_CONFLICT_PACKAGES = " \
    busybox \
    bash \
    pkgconfig \
"

# Most of the package groups are located in the classes/package-groups.inc
IMAGE_INSTALL += " \
    default-modules \
    merge-files \
    udev-automount \
    udev-python-gpio \
    usbreset \
    systemd \
    systemd-serialgetty \
    tar \
    wget \
    procps \
    udev \
    u-boot-fw-utils \
    kernel-base \
    kernel-modules \
	${@bb.utils.contains('REMOVE_SDK_CONFLICT_PKGS', '0', '${SDK_CONFLICT_PACKAGES}', '', d)} \
"
