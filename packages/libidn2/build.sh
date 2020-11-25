TERMUX_PKG_HOMEPAGE=https://www.gnu.org/software/libidn/#libidn2
TERMUX_PKG_DESCRIPTION="Free software implementation of IDNA2008, Punycode and TR46"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_VERSION=2.3.0
TERMUX_PKG_REVISION=2
TERMUX_PKG_SRCURL=https://mirrors.kernel.org/gnu/libidn/libidn2-$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=e1cb1db3d2e249a6a3eb6f0946777c2e892d5c5dc7bd91c74394fc3a01cab8b5
TERMUX_PKG_DEPENDS="libunistring, libandroid-support"
TERMUX_PKG_BREAKS="libidn2-dev"
TERMUX_PKG_REPLACES="libidn2-dev"

termux_step_post_configure() {
	# Remove problematic config flag in static lib.
	# Helps against error
	#  'version node not found for symbol _idn2_punycode_decode@IDN2_0.0.0'
	sed -i 's/#define HAVE_SYMVER_ALIAS_SUPPORT 1//' $TERMUX_PKG_BUILDDIR/config.h
}

