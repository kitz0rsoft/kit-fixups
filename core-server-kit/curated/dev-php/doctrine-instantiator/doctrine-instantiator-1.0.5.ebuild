# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

MY_PN="${PN/doctrine-//}"

DESCRIPTION="Utility to instantiate objects in PHP without invoking their constructors"
HOMEPAGE="https://github.com/doctrine/instantiator"
SRC_URI="https://github.com/doctrine/${MY_PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE=""

S="${WORKDIR}/${MY_PN}-${PV}"

RDEPEND="dev-php/fedora-autoloader
	>=dev-lang/php-5.6:*"

src_install() {
	insinto /usr/share/php/
	doins -r src/*
	insinto /usr/share/php/Doctrine/Instantiator
	doins "${FILESDIR}/autoload.php"
}
