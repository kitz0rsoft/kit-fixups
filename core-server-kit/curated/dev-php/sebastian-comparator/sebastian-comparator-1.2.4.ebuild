# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

MY_PN="${PN/sebastian-//}"

DESCRIPTION="Compare PHP values for equality"
HOMEPAGE="https://phpunit.de"
SRC_URI="https://github.com/sebastianbergmann/${MY_PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE=""

S="${WORKDIR}/${MY_PN}-${PV}"

RDEPEND="dev-php/fedora-autoloader
	<dev-php/sebastian-diff-2.0
	<dev-php/sebastian-exporter-3.0
	>=dev-lang/php-5.6:*
"
src_install() {
	insinto /usr/share/php/SebastianBergmann/Comparator
	doins -r src/*
	doins "${FILESDIR}/autoload.php"
}
