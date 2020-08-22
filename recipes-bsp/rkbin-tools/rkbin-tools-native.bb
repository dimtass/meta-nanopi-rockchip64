# Copyright (C) 2019, Fuzhou Rockchip Electronics Co., Ltd
# Released under the MIT license (see COPYING.MIT for the terms)
require rkbin-tools.inc
inherit native deploy

DESCRIPTION = "Rockchip binary tools"

do_compile[depends] += "virtual/bootloader:do_deploy"

SRCREV_rkbin = "${AUTOREV}"
SRCREV_tools = "${AUTOREV}"
SRCREV_FORMAT ?= "rkbin_tools"

INSANE_SKIP_${PN} = "already-stripped"

# The pre-built tools have different link loader, don't change them.
UNINATIVE_LOADER := ""

do_install () {
	install -d ${D}/${bindir}

	cd ${S}/tools

	install -m 0755 firmwareMerger ${D}/${bindir}
	install -m 0755 kernelimage ${D}/${bindir}
	install -m 0755 loaderimage ${D}/${bindir}
	install -m 0755 mkkrnlimg ${D}/${bindir}
	install -m 0755 resource_tool ${D}/${bindir}
	install -m 0755 rkdeveloptool ${D}/${bindir}
	install -m 0755 trust_merger ${D}/${bindir}
}
