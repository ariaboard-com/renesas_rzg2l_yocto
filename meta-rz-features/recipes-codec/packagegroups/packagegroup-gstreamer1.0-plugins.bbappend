require include/codec/omx-control.inc

DEPENDS += "${@bb.utils.contains("USE_OMX_COMMON", "1", "gstreamer1.0-omx", "", d)}"

RDEPENDS_packagegroup-gstreamer1.0-plugins += " \
	gstreamer1.0-plugin-vspmfilter \
	${@bb.utils.contains("USE_OMX_COMMON", "1", "gstreamer1.0-omx", "", d)} \
"

