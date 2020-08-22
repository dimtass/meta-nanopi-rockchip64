AUTHOR = "Dimitris Tassopoulos <dimtass@gmail.com>"

RK_UBOOT_IMAGE ?= "${IMAGE_BASENAME}-${MACHINE}-uboot.img"
RK_BOOT_IMAGE ?= "${IMAGE_BASENAME}-${MACHINE}-boot.img"

IDBLOADER_SEEK ?= "64"
UBOOT_IMG_SEEK ?= "16384"
TRUST_IMG_SEEK ?= "24576"
BOOT_IMG_SEEK ?= "32768"
BOOT_SPACE ?= "40960"
ROOTFS_IMG_SEEK ?= "262144"

RK_BL31 ?= "${BL31_BLOB}"
RK_DDR_BIN ?= "${DDR_BLOB}"
RK_MINILOADER_BIN ?= "${MINILOADER_BLOB}"
RK_TRUST_BIN ?= "trust.bin"
RK_IDBLOADER ?= "idbloader.img"
RK_UBOOT_IMG ?= "u-boot.img"

do_image_rkboot[depends] += " \
			u-boot-mkimage-native:do_populate_sysroot \
			rkbin-tools:do_populate_sysroot \
			rkbin-tools-native:do_populate_sysroot \
			parted-native:do_populate_sysroot \
			mtools-native:do_populate_sysroot \
			dosfstools-native:do_populate_sysroot \
			virtual/kernel:do_deploy \
			virtual/bootloader:do_deploy \
			gptfdisk-native:do_populate_sysroot \
			"

create_bootloader_bin() {
    set -x

    OFFSET="${IDBLOADER_SEEK}"
    BOOT_START=$(expr ${UBOOT_IMG_SEEK} - ${OFFSET})
    ATF_START=$(expr ${TRUST_IMG_SEEK} - ${OFFSET})

	rm -f ${WORKDIR}/${RK_UBOOT_IMAGE}

	# Burn bootloader
	loaderimage --pack --uboot ${DEPLOY_DIR_IMAGE}/${SPL_BINARY} ${DEPLOY_DIR_IMAGE}/${RK_UBOOT_IMG} 0x200000

	mkimage -n ${SOC_FAMILY} -T rksd -d ${DEPLOY_DIR_IMAGE}/${RK_DDR_BIN} ${DEPLOY_DIR_IMAGE}/${RK_IDBLOADER}
	cat ${DEPLOY_DIR_IMAGE}/${RK_MINILOADER_BIN} >>${DEPLOY_DIR_IMAGE}/${RK_IDBLOADER}

	trust_merger --replace bl31.elf ${DEPLOY_DIR_IMAGE}/${RK_BL31} ${DEPLOY_DIR_IMAGE}/trust.ini
	cp trust.bin ${DEPLOY_DIR_IMAGE}/${RK_TRUST_BIN}

	dd if=${DEPLOY_DIR_IMAGE}/${RK_IDBLOADER} of=${WORKDIR}/${RK_UBOOT_IMAGE} conv=notrunc,fsync seek=0
	dd if=${DEPLOY_DIR_IMAGE}/${RK_UBOOT_IMG} of=${WORKDIR}/${RK_UBOOT_IMAGE} conv=notrunc,fsync seek=${BOOT_START}
	dd if=${DEPLOY_DIR_IMAGE}/${RK_TRUST_BIN} of=${WORKDIR}/${RK_UBOOT_IMAGE} conv=notrunc,fsync seek=${ATF_START}

	cp ${WORKDIR}/${RK_UBOOT_IMAGE} ${DEPLOY_DIR_IMAGE}/${RK_UBOOT_IMAGE}
}

create_boot_part() {
    set -x

	# Create a vfat image with boot files
	rm -f ${WORKDIR}/${RK_BOOT_IMAGE}
	mkfs.vfat -n "${BOOTDD_VOLUME_ID}" -S 512 -C ${WORKDIR}/${RK_BOOT_IMAGE} ${BOOT_SPACE}

	mcopy -i ${WORKDIR}/${RK_BOOT_IMAGE} -s ${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE}-${MACHINE}.bin ::${KERNEL_IMAGETYPE}
	# Create folder for overlays
	mmd -i ${WORKDIR}/${RK_BOOT_IMAGE} ::/overlay
	
	# Get the dtbo overlays
	overlays=$(find ${DEPLOY_DIR_IMAGE}/ | grep -F ".dtbo" )
	# Add also the dtb with dtbo
	dtbs="${KERNEL_DEVICETREE} \n${overlays}"
	# Copy device tree file
	if test -n "${dtbs}"; then
		for DTS_FILE in ${dtbs}; do
			DTS_BASE_NAME=`basename ${DTS_FILE} | awk -F ".dtb" '{print $1}'`
			DTS_DIR_NAME=`dirname ${DTS_FILE}`
			# Copy all the dtbo files
			if [ "${DTS_FILE##*.}" = "dtbo" ]; then
				#bbwarn "copy ${DTS_BASE_NAME}.dtbo to boot.img::/${DTS_FILE}"
				mcopy -i ${WORKDIR}/${RK_BOOT_IMAGE} -s ${DEPLOY_DIR_IMAGE}/${DTS_BASE_NAME}.dtbo ::/overlay/${DTS_BASE_NAME}.dtbo
			fi
			if [ -e ${DEPLOY_DIR_IMAGE}/"${DTS_BASE_NAME}.dtb" ]; then
				bbnote "DTS_BASE_NAME: ${DTS_BASE_NAME}"
				bbnote "DTS_FILE: ${DTS_FILE}"
				bbnote "DTS_DIR_NAME: ${DTS_DIR_NAME}"
				if [ ${DTS_FILE} != ${DTS_BASE_NAME}.dtb ]; then
					mmd -i ${WORKDIR}/${RK_BOOT_IMAGE} ::/${DTS_DIR_NAME}
				fi
				mcopy -i ${WORKDIR}/${RK_BOOT_IMAGE} -s ${DEPLOY_DIR_IMAGE}/${DTS_BASE_NAME}.dtb ::/${DTS_FILE}
			fi
		done
	fi

	if [ -e "${DEPLOY_DIR_IMAGE}/fex.bin" ]; then
		mcopy -i ${WORKDIR}/${RK_BOOT_IMAGE} -s ${DEPLOY_DIR_IMAGE}/fex.bin ::script.bin
	fi
	if [ -e "${DEPLOY_DIR_IMAGE}/boot.scr" ]; then
		mcopy -i ${WORKDIR}/${RK_BOOT_IMAGE} -s ${DEPLOY_DIR_IMAGE}/boot.scr ::boot.scr
	fi
	if [ -e "${DEPLOY_DIR_IMAGE}/fixup.scr" ]; then
		mcopy -i ${WORKDIR}/${RK_BOOT_IMAGE} -s ${DEPLOY_DIR_IMAGE}/fixup.scr ::fixup.scr
	fi
	if [ -e "${DEPLOY_DIR_IMAGE}/rkEnv.txt" ]; then
		mcopy -i ${WORKDIR}/${RK_BOOT_IMAGE} -s ${DEPLOY_DIR_IMAGE}/rkEnv.txt ::rkEnv.txt
	fi

	# Add stamp file
	echo "${IMAGE_NAME}" > ${WORKDIR}/image-version-info
	mcopy -i ${WORKDIR}/${RK_BOOT_IMAGE} -v ${WORKDIR}/image-version-info ::

	cp ${WORKDIR}/${RK_BOOT_IMAGE} ${DEPLOY_DIR_IMAGE}/${RK_BOOT_IMAGE}
}

IMAGE_CMD_rkboot() {
    create_bootloader_bin
    create_boot_part
}

# addtask do_image_rkboot before do_image_wksbuild