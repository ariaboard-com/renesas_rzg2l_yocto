DESCRIPTION = "Linux kernel for the RZG2 based board"

require recipes-kernel/linux/linux-yocto.inc

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/:"
COMPATIBLE_MACHINE = "(smarc-rzg2l|rzg2l-dev|rzg2lc-dev|smarc-rzg2lc)"

KERNEL_URL = " \
    git://github.com/ariaboard-com/renesas_rzg2l_kernel.git"
BRANCH = "rzg2l-cip41"
SRCREV = "2d2d60057164c9eed4a7017a113038044cba32ad"

SRC_URI = "${KERNEL_URL};protocol=ssh;nocheckout=1;branch=${BRANCH}"
#SRC_URI_append = "\
#	file://patches.scc \
#"
LIC_FILES_CHKSUM = "file://COPYING;md5=bbea815ee2795b2f4230826c0c6b8814"
LINUX_VERSION ?= "4.19.165"

PV = "${LINUX_VERSION}+git${SRCPV}"
PR = "r1"

KBUILD_DEFCONFIG = "novotech_defconfig"
KCONFIG_MODE = "alldefconfig"

do_kernel_metadata_af_patch() {
	# need to recall do_kernel_metadata after do_patch for some patches applied to defconfig
	rm -f ${WORKDIR}/defconfig
	do_kernel_metadata
}

addtask do_kernel_metadata_af_patch after do_patch before do_kernel_configme

# Fix race condition, which can causes configs in defconfig file be ignored
do_kernel_configme[depends] += "virtual/${TARGET_PREFIX}binutils:do_populate_sysroot"
do_kernel_configme[depends] += "virtual/${TARGET_PREFIX}gcc:do_populate_sysroot"
do_kernel_configme[depends] += "bc-native:do_populate_sysroot bison-native:do_populate_sysroot"

# Fix error: openssl/bio.h: No such file or directory
DEPENDS += "openssl-native"
