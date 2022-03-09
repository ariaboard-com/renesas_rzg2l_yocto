# We want to enable all as default
USE_RENESAS_GLES ?= "1"
USE_RENESAS_OPENCL ?= "1"

PREFERRED_PROVIDER_virtual/libgles1 = "${@oe.utils.conditional('USE_RENESAS_GLES', '1', 'mali-library', 'mesa',d)}"
PREFERRED_PROVIDER_virtual/libgles2 = "${@oe.utils.conditional('USE_RENESAS_GLES', '1', 'mali-library', 'mesa',d)}"
PREFERRED_PROVIDER_virtual/egl = "${@oe.utils.conditional('USE_RENESAS_GLES', '1', 'mali-library', 'mesa',d)}"
PREFERRED_PROVIDER_virtual/libgbm = "${@oe.utils.conditional('USE_RENESAS_GLES', '1', 'mali-library', 'mesa',d)}"
PREFERRED_PROVIDER_virtual/libopencl ?= "${@oe.utils.conditional('USE_RENESAS_OPENCL', '1', 'mali-library', '', d)}"
MULTI_PROVIDER_WHITELIST_append = " virtual/libegl virtual/egl virtual/libgles1 virtual/libgles2 virtual/libgbm "

IMAGE_INSTALL_append = " ${@oe.utils.conditional('USE_RENESAS_OPENCL', '1', ' libopencl ', '', d)} "
