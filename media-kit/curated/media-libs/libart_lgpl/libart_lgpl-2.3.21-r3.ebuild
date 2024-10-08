# Distributed under the terms of the GNU General Public License v2

EAPI=7
GNOME_TARBALL_SUFFIX="bz2"
GNOME2_LA_PUNT="no"

inherit autotools gnome2 multilib-minimal

DESCRIPTION="A LGPL version of libart"
HOMEPAGE="https://www.levien.com/libart"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"

BDEPEND="virtual/pkgconfig"

# The provided tests are interactive only
RESTRICT="test"

MULTILIB_CHOST_TOOLS=(
	/usr/bin/libart2-config
)

src_prepare() {
	gnome2_src_prepare

	# Fix crosscompiling, bug #185684
	rm "${S}"/art_config.h || die
	eapply "${FILESDIR}"/${PN}-2.3.21-crosscompile.patch

	# Do not build tests if not required
	eapply "${FILESDIR}"/${PN}-2.3.21-no-test-build.patch

	mv configure.in configure.ac || die
	AT_NOELIBTOOLIZE=yes eautoreconf
}

multilib_src_configure() {
	ECONF_SOURCE=${S} \
	gnome2_src_configure \
		--disable-static
}

multilib_src_install() {
	gnome2_src_install
	find "${ED}" -type f -name '*.la' -delete || die
}
