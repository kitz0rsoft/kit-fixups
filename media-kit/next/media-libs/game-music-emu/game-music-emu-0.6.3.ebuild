# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="Video game music file emulators"
HOMEPAGE="https://bitbucket.org/mpyne/game-music-emu/wiki/Home"
SRC_URI="https://bitbucket.org/mpyne/game-music-emu/downloads/${P}.tar.xz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"
IUSE=""

DOCS=( changes.txt design.txt gme.txt readme.txt )

src_configure() {
	local mycmakeargs=(
		-DENABLE_UBSAN=off # disabled so that if gcc[-sanitize] it does not fail to compile
	)
	cmake_src_configure
}
