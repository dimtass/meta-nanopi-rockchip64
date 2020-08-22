require rkbin-tools.inc

DESCRIPTION = "Rockchip binary loader"

PV = "1.0.0+git${SRCPV}"

PACKAGE_ARCH = "${MACHINE_ARCH}"

# Check needed variables
python () {
    if not d.getVar('DDR_BLOB'):
        raise bb.parse.SkipPackage('DDR_BLOB is not specified!')
    if not d.getVar('MINILOADER_BLOB'):
        raise bb.parse.SkipPackage('MINILOADER_BLOB is not specified!')
    if not d.getVar('BL31_BLOB'):
        raise bb.parse.SkipPackage('BL31_BLOB is not specified!')
}

inherit deploy

do_deploy () {
	install -m 0644 ${S}/${RK_BIN_DIR}/${DDR_BLOB} ${DEPLOYDIR}/${DDR_BLOB}
	install -m 0644 ${S}/${RK_BIN_DIR}/${MINILOADER_BLOB} ${DEPLOYDIR}/${MINILOADER_BLOB}
	install -m 0644 ${S}/${RK_BIN_DIR}/${BL31_BLOB} ${DEPLOYDIR}/${BL31_BLOB}
}
addtask deploy before do_build after do_compile
