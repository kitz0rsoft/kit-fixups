# Distributed under the terms of the GNU General Public License v2

EAPI=7
DISTUTILS_OPTIONAL=yesplz
DISTUTILS_SINGLE_IMPL=yesplz
GENTOO_DEPEND_ON_PERL=no
PATCHSET=3
PYTHON_COMPAT=( python3_{6,7,8} )
WANT_AUTOMAKE=none
inherit autotools distutils-r1 perl-module systemd

DESCRIPTION="Software for generating and retrieving SNMP data"
HOMEPAGE="http://www.net-snmp.org/"
SRC_URI="
	https://dev.gentoo.org/~jsmolic/distfiles/${PN}-5.7.3-patches-3.tar.xz
	mirror://sourceforge/project/${PN}/${PN}/${PV}/${P}.tar.gz
"

# GPL-2 for the init scripts
LICENSE="HPND BSD GPL-2"
SLOT="0/40"
KEYWORDS="*"
IUSE="
	X bzip2 doc elf kmem ipv6 libressl lm_sensors mfd-rewrites minimal mysql
	netlink pcap pci perl python rpm selinux smux ssl tcpd ucd-compat zlib systemd
"
REQUIRED_USE="
	python? ( ${PYTHON_REQUIRED_USE} )
	rpm? ( bzip2 zlib )
"

COMMON_DEPEND="
	bzip2? ( app-arch/bzip2 )
	elf? ( dev-libs/elfutils )
	lm_sensors? ( sys-apps/lm_sensors )
	mysql? ( dev-db/mysql-connector-c:0= )
	netlink? ( dev-libs/libnl:3 )
	pcap? ( net-libs/libpcap )
	pci? ( sys-apps/pciutils )
	perl? ( dev-lang/perl:= )
	python? (
		$(python_gen_cond_dep '
			dev-python/setuptools[${PYTHON_MULTI_USEDEP}]
		')
		${PYTHON_DEPS}
	)
	rpm? (
		app-arch/rpm
		dev-libs/popt
	)
	ssl? (
		!libressl? ( >=dev-libs/openssl-0.9.6d:0= )
		libressl? ( dev-libs/libressl:= )
	)
	tcpd? ( >=sys-apps/tcp-wrappers-7.6 )
	zlib? ( >=sys-libs/zlib-1.1.4 )
"
DEPEND="
	${COMMON_DEPEND}
	doc? ( app-doc/doxygen )
"
RDEPEND="
	${COMMON_DEPEND}
	perl? (
		X? ( dev-perl/Tk )
		!minimal? ( dev-perl/TermReadKey )
	)
	selinux? ( sec-policy/selinux-snmp )
"
RESTRICT=test
PATCHES=(
	"${FILESDIR}"/${PN}-5.7.3-include-limits.patch
	"${FILESDIR}"/${PN}-5.8-do-not-conflate-LDFLAGS-and-LIBS.patch
	"${FILESDIR}"/${PN}-5.8-pcap.patch
	"${FILESDIR}"/${PN}-5.8.1-pkg-config.patch
	"${FILESDIR}"/${PN}-5.8.1-net-snmp-config-libdir.patch
	"${FILESDIR}"/${PN}-5.8.1-mysqlclient.patch
	"${FILESDIR}"/${PN}-5.9-MakeMaker.patch
	"${FILESDIR}"/${PN}-99999999-tinfo.patch
)

pkg_setup() {
	use python && python-single-r1_pkg_setup
}

src_prepare() {
	# snmpconf generates config files with proper selinux context
	use selinux && eapply "${FILESDIR}"/${PN}-5.1.2-snmpconf-selinux.patch

	mv "${WORKDIR}"/patches/0002-Respect-DESTDIR-for-pythoninstall.patch{,.disabled} || die
	mv "${WORKDIR}"/patches/0004-Don-t-report-CFLAGS-and-LDFLAGS-in-net-snmp-config.patch{,.disabled} || die
	eapply "${WORKDIR}"/patches/*.patch

	default

	eautoconf
}

src_configure() {
	# keep this in the same line, configure.ac arguments are passed down to config.h
	local mibs="host ucd-snmp/dlmod ucd-snmp/diskio ucd-snmp/extensible mibII/mta_sendmail etherlike-mib/dot3StatsTable"
	use lm_sensors && mibs="${mibs} ucd-snmp/lmsensorsMib"
	use smux && mibs="${mibs} smux"

	# Assume /etc/mtab is not present with a recent baselayout/openrc (bug #565136)
	use kernel_linux && export ac_cv_ETC_MNTTAB=/etc/mtab

	econf \
		$(use_enable !ssl internal-md5) \
		$(use_enable ipv6) \
		$(use_enable mfd-rewrites) \
		$(use_enable perl embedded-perl) \
		$(use_enable ucd-compat ucd-snmp-compatibility) \
		$(use_with bzip2) \
		$(use_with elf) \
		$(use_with kmem kmem-usage) \
		$(use_with mysql) \
		$(use_with netlink nl) \
		$(use_with pcap) \
		$(use_with pci) \
		$(use_with perl perl-modules INSTALLDIRS=vendor) \
		$(use_with python python-modules) \
		$(use_with rpm) \
		$(use_with ssl openssl) \
		$(use_with tcpd libwrap) \
		$(use_with zlib) \
		--disable-static \
		--enable-shared \
		--with-default-snmp-version="3" \
		--with-install-prefix="${D}" \
		--with-ldflags="${LDFLAGS}" \
		--with-logfile="/var/log/net-snmpd.log" \
		--with-mib-modules="${mibs}" \
		--with-persistent-directory="/var/lib/net-snmp" \
		--with-sys-contact="root@Unknown" \
		--with-sys-location="Unknown"
}

src_compile() {
	emake sedscript

	local subdir
	for subdir in snmplib agent/mibgroup agent apps .; do
		emake OTHERLDFLAGS="${LDFLAGS}" -C ${subdir} all
	done

	use doc && emake docsdox
}

src_install() {
	# bug #317965
	emake -j1 DESTDIR="${D}" install

	use python && python_optimize

	if use perl ; then
		perl_delete_localpod
		if ! use X; then
			rm "${D}"/usr/bin/tkmib || die
		fi
	else
		rm -f \
			"${D}"/usr/bin/fixproc \
			"${D}"/usr/bin/ipf-mod.pl \
			"${D}"/usr/bin/mib2c \
			"${D}"/usr/bin/net-snmp-cert \
			"${D}"/usr/bin/snmp-bridge-mib \
			"${D}"/usr/bin/snmpcheck \
			"${D}"/usr/bin/snmpconf \
			"${D}"/usr/bin/tkmib \
			"${D}"/usr/bin/traptoemail \
			"${D}"/usr/share/snmp/mib2c.perl.conf \
			"${D}"/usr/share/snmp/snmp_perl_trapd.pl \
			|| die
	fi

	dodoc AGENT.txt ChangeLog FAQ INSTALL NEWS PORTING README* TODO
	newdoc EXAMPLE.conf.def EXAMPLE.conf

	if use doc; then
		docinto html
		dodoc -r docs/html/*
	fi

	keepdir /var/lib/net-snmp

	newinitd "${FILESDIR}"/snmpd.init.2 snmpd
	newconfd "${FILESDIR}"/snmpd.conf snmpd

	newinitd "${FILESDIR}"/snmptrapd.init.2 snmptrapd
	newconfd "${FILESDIR}"/snmptrapd.conf snmptrapd

	if use systemd; then
		systemd_dounit "${FILESDIR}"/snmpd.service
		systemd_dounit "${FILESDIR}"/snmptrapd.service
	fi
	insinto /etc/snmp
	newins "${S}"/EXAMPLE.conf snmpd.conf.example

	# Remove everything not required for an agent.
	# Keep only the snmpd, snmptrapd, MIBs, headers and libraries.
	if use minimal; then
		rm -rf \
			"${D}"/**/*.pl \
			"${D}"/usr/bin/{encode_keychange,snmp{get,getnext,set,usm,walk,bulkwalk,table,trap,bulkget,translate,status,delta,test,df,vacm,netstat,inform,check,conf},fixproc,traptoemail} \
			"${D}"/usr/share/snmp/*.conf \
			"${D}"/usr/share/snmp/snmpconf-data \
			|| die
	fi

	find "${ED}" -name '*.la' -delete || die
}


