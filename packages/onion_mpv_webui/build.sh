# Skeleton build.sh script for new package.
# For reference about available fields, check the Termux Developer's Wiki page:
# https://github.com/termux/termux-packages/wiki/Creating-new-package

TERMUX_PKG_HOMEPAGE=
TERMUX_PKG_DESCRIPTION="Webinterface plugin for MPV"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_LICENSE_FILE="onion-mpv-webui/LICENSE"
TERMUX_PKG_VERSION=
TERMUX_PKG_SRCURL=
TERMUX_PKG_SHA256=
#TERMUX_PKG_DEPENDS=""
TERMUX_PKG_BUILD_DEPENDS="onion, libgnutls, libgcrypt"
#TERMUX_PKG_BUILD_IN_SRC=true

TERMUX_PKG_SKIP_SRC_EXTRACT=true

TERMUX_PKG_FORCE_CMAKE="true"

TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
		-DTERMUX=TRUE
		-DBUILD_ONION=FALSE
		"
		#BUILD_ONION is FALSE because this package depends on 'onion'

termux_step_get_source() {
	mkdir -p "$TERMUX_PKG_SRCDIR"
	cd "$TERMUX_PKG_SRCDIR"

	git clone --depth=1 \
		https://github.com/YggdrasiI/onion-mpv-webui
	rm onion-mpv-webui/Makefile

}

termux_step_pre_configure() {

	export ONION_HOST_BUILD=$TERMUX_PKG_SRCDIR/../../onion/host-build

	#export PATH=$PATH:$TERMUX_PKG_SRCDIR/../../onion/build/onion/bin/
	export OTEMPLATE_TAGSDIR=$ONION_HOST_BUILD/onion/lib/otemplate/templatetags
	export OTEMPLATE_BIN=$ONION_HOST_BUILD/onion/bin/otemplate
}

termux_step_configure() {
	mkdir -p "$TERMUX_PKG_BUILDDIR"
	cd "$TERMUX_PKG_BUILDDIR"

	cmake -DINSTALL_PATH="${TERMUX_PREFIX}" \
		-DCMAKE_INCLUDE_PATH="/data/data/com.termux/files/usr/include/" \
		-DCMAKE_LIBRARY_PATH="/data/data/com.termux/files/usr/lib/ " \
		$TERMUX_PKG_EXTRA_CONFIGURE_ARGS \
		-DOTEMPLATE="${OTEMPLATE_BIN}" \
		-DOTEMPLATE_TAGSDIR="${OTEMPLATE_TAGSDIR}" \
		"$TERMUX_PKG_SRCDIR/onion-mpv-webui"
}

termux_step_make() {
	cd "$TERMUX_PKG_BUILDDIR"
	make
}

termux_step_make_install() {
	cd "$TERMUX_PKG_BUILDDIR"
	make install
}
