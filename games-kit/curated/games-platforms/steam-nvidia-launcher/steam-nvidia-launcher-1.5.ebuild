# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Funtoo's Docker-based Steam environment for NVIDIA systems."
HOMEPAGE="https://www.funtoo.org/Steam"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="amd64"

GITHUB_REPO="steam-launcher"
GITHUB_USER="funtoo"
GITHUB_TAG="7238bc4f32d249540dc0bc0b3541e585317f1523"
SRC_URI="https://www.github.com/${GITHUB_USER}/${GITHUB_REPO}/tarball/${GITHUB_TAG} -> ${PN}-${GITHUB_TAG}.tar.gz"

RDEPEND="
	app-emulation/nvidia-docker
	app-emulation/nvidia-container-runtime
	x11-apps/xhost"

src_unpack() {
	unpack ${A}
	mv "${WORKDIR}/${GITHUB_USER}-${GITHUB_REPO}"-??????? "${S}" || die
}

src_install() {
	dobin steam-nvidia-launcher
}

pkg_postinst() {
	einfo "Please visit https://www.funtoo.org/Steam for steps on how to configure your system."
	einfo
	einfo "Pulseaudio will require some slight configuration changes, and you will need to add"
	einfo "your regular user account to the docker group."
}
