# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit eutils fortran-2 cmake-utils multilib flag-o-matic toolchain-funcs

DESCRIPTION="Reference implementation of LAPACK"
HOMEPAGE="http://www.netlib.org/lapack/"
SRC_URI="http://www.netlib.org/lapack/lapack-${PV}.tgz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="+deprecated"

DEPEND="app-eselect/eselect-lapack
	>=virtual/blas-3.6
	virtual/pkgconfig"
RDEPEND="${DEPEND}"

S="${WORKDIR}/lapack-${PV}"
PATCHES=( "${FILESDIR}/${P}-fix-build-system.patch" )

src_prepare() {
	cmake-utils_src_prepare

	ESELECT_PROF=reference

	# some string does not get passed properly
	sed -i \
		-e '/lapack_testing.py/d' \
		CTestCustom.cmake.in || die
	# separate ebuild to tmglib
	sed -i \
		-e '/lapack_install_library(tmglib)/d' \
		TESTING/MATGEN/CMakeLists.txt || die

	cp "${FILESDIR}"/eselect.lapack.reference-r1 "${T}"/eselect.lapack.reference || die
	sed -i -e "s:/usr:${EPREFIX}/usr:" "${T}"/eselect.lapack.reference || die
	if [[ ${CHOST} == *-darwin* ]] ; then
		sed -i -e 's/\.so\([\.0-9]\+\)\?/\1.dylib/g' \
			"${T}"/eselect.lapack.reference || die
	fi
}

src_configure() {
	local my_fcflags
	local gcc_version=$(gcc -dumpversion | cut -d'.' -f1 ) || die

	if [ $gcc_version -ge 10 ]; then
		my_fcflags='-fallow-argument-mismatch'
	else
		my_fcflags=''
	fi

	local mycmakeargs=(
		-Wno-dev
		-DUSE_OPTIMIZED_BLAS=ON
		-DBLAS_LIBRARIES="$($(tc-getPKG_CONFIG) --libs blas)"
		-DBUILD_DEPRECATED=$(usex deprecated)
		-DCMAKE_Fortran_FLAGS="$($(tc-getPKG_CONFIG) --cflags blas) $(get_abi_CFLAGS) ${FCFLAGS} ${my_fcflags}"
		-DBUILD_STATIC_LIBS=ON
		-DBUILD_SHARED_LIBS=ON
	)

	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile
}

src_install() {
	cmake-utils_src_install

	mkdir -p "${ED}/usr/$(get_libdir)/lapack/reference" || die
	mv "${ED}/usr/$(get_libdir)"/lib* "${ED}/usr/$(get_libdir)/pkgconfig"/* \
		"${ED}/usr/$(get_libdir)/lapack/reference" || die
	if [[ ${CHOST} == *-darwin* ]] ; then
		# modify install_names accordingly, bug #608266
		local lib
		for lib in "${ED}"/usr/$(get_libdir)/lapack/reference/*.dylib ; do
			install_name_tool -id "${lib#${D%/}}" "${lib}"
		done
	fi
	rmdir "${ED}/usr/$(get_libdir)/pkgconfig" || die

	eselect lapack add $(get_libdir) "${T}"/eselect.lapack.reference ${ESELECT_PROF}
}

pkg_postinst() {
	local p=lapack
	local current_lib=$(eselect ${p} show | cut -d' ' -f2)
	if [[ ${current_lib} == ${ESELECT_PROF} || -z ${current_lib} ]]; then
		# work around eselect bug #189942
		local configfile="${EROOT}"/etc/env.d/${p}/$(get_libdir)/config
		[[ -e ${configfile} ]] && rm -f ${configfile}
		eselect ${p} set ${ESELECT_PROF}
		elog "${p} has been eselected to ${ESELECT_PROF}"
	else
		elog "Current eselected ${p} is ${current_lib}"
		elog "To use ${p} ${ESELECT_PROF} implementation, you have to issue (as root):"
		elog "\t eselect ${p} set ${ESELECT_PROF}"
	fi
}
