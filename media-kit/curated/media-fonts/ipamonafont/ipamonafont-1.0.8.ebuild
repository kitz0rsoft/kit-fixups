# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit font

MY_PN="opfc-ModuleHP-1.1.1_withIPAMonaFonts"

DESCRIPTION="Hacked version of IPA fonts, which is suitable for browsing 2ch"
HOMEPAGE="https://web.archive.org/web/20190326123924/http://www.geocities.jp/ipa_mona/"
SRC_URI="http://freebsd.sin.openmirrors.asia/pub/FreeBSD/ports/local-distfiles/hrs/${MY_PN}-${PV}.tar.gz"

LICENSE="grass-ipafonts mplus-fonts public-domain"
SLOT="0"
KEYWORDS="*"
IUSE=""

S="${WORKDIR}"

FONT_SUFFIX="ttf"
FONT_S="${S}/${MY_PN}-${PV}/fonts"
