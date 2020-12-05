# Skeleton build.sh script for new package.
# For reference about available fields, check the Termux Developer's Wiki page:
# https://github.com/termux/termux-packages/wiki/Creating-new-package

TERMUX_PKG_HOMEPAGE="https://github.com/davidmoreno/onion"
TERMUX_PKG_DESCRIPTION="onion package contains libonion, otemplate, opack and onion-crl."
TERMUX_PKG_LICENSE="GPLv2+"
TERMUX_PKG_LICENSE_FILE="onion/LICENSE.txt"
TERMUX_PKG_VERSION=
TERMUX_PKG_SRCURL=
TERMUX_PKG_SHA256=
TERMUX_PKG_DEPENDS="libgnutls, libgcrypt, zlib"
#TERMUX_PKG_BUILD_IN_SRC=true


# TERMUX_PKG_GIT_BRANCH=unstable
TERMUX_PKG_GIT_BRANCH=master
TERMUX_PKG_SKIP_SRC_EXTRACT=true

TERMUX_PKG_FORCE_CMAKE="true"

# Explicit version 
TERMUX_GIT_COMMIT=43128b03199518d4878074c311ff71ff0018aea8

TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
		-DTERMUX=true 
		-DONION_USE_SSL=true
		-DONION_USE_PAM=false
		-DONION_USE_PTHREADS=true
		-DONION_USE_PNG=false
		-DONION_USE_JPEG=false
		-DONION_USE_XML2=false
		-DONION_USE_SYSTEMD=false
		-DONION_USE_SQLITE3=false
		-DONION_USE_REDIS=false
		-DONION_USE_GC=false
		-DONION_USE_TESTS=false
		-DONION_EXAMPLES=false
		-DONION_USE_BINDINGS_CPP=false
		-DONION_POLLER=epoll
"

# We need to build otemplate binary on host to generate
# templates in other packages
TERMUX_PKG_HOSTBUILD="true"

# Minimal set for otemplate binary
TERMUX_PKG_EXTRA_HOSTBUILD_CONFIGURE_ARGS="
		-DONION_USE_SSL=false
		-DONION_USE_PAM=false
		-DONION_USE_PTHREADS=false
		-DONION_USE_PNG=false
		-DONION_USE_JPEG=false
		-DONION_USE_XML2=false
		-DONION_USE_SYSTEMD=false
		-DONION_USE_SQLITE3=false
		-DONION_USE_REDIS=false
		-DONION_USE_GC=false
		-DONION_USE_TESTS=false
		-DONION_EXAMPLES=false
		-DONION_USE_BINDINGS_CPP=false
"


termux_step_get_source() {
	mkdir -p "$TERMUX_PKG_SRCDIR"
	cd "$TERMUX_PKG_SRCDIR"

	git clone --depth=100 --branch "$TERMUX_PKG_GIT_BRANCH" \
		https://github.com/davidmoreno/onion \
		onion

	cd onion
	git checkout -b termux_build "${TERMUX_GIT_COMMIT}"
	git am "${TERMUX_PKG_BUILDER_DIR}/patches/termux_build.patch"
}

termux_step_host_build() {
	termux_setup_cmake

	mkdir -p $TERMUX_PKG_HOSTBUILD_DIR/onion
	mkdir -p $TERMUX_PKG_HOSTBUILD_DIR/build
	cd $TERMUX_PKG_HOSTBUILD_DIR/build
	cmake \
		$TERMUX_PKG_EXTRA_HOSTBUILD_CONFIGURE_ARGS \
		-DCMAKE_INSTALL_PREFIX="$TERMUX_PKG_HOSTBUILD_DIR/onion" \
		$TERMUX_PKG_SRCDIR/onion
	make -j 1
	make install

	echo " === Onion Hostbuild binary paths ==="
	echo "otemplate:  $TERMUX_PKG_HOSTBUILD_DIR/build/tools/otemplate/otemplate"
}

# Non hostbuild hooks
termux_step_configure() {
	mkdir -p "$TERMUX_PKG_BUILDDIR"
	cd "$TERMUX_PKG_BUILDDIR"
	cmake -DCMAKE_INSTALL_PREFIX="${TERMUX_PREFIX}" \
		-DCMAKE_CXX_FLAGS="-I /data/data/com.termux/files/usr/include" \
		$TERMUX_PKG_EXTRA_CONFIGURE_ARGS \
		"$TERMUX_PKG_SRCDIR/onion"
}

termux_step_make() {
	cd "$TERMUX_PKG_BUILDDIR"
	make
}

termux_step_make_install() {
	cd "$TERMUX_PKG_BUILDDIR"
	make install
}


