# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python2_7 )

inherit autotools python-single-r1

DESCRIPTION="ilmbase Python bindings"
HOMEPAGE="http://www.openexr.com"
SRC_URI="https://github.com/openexr/openexr/releases/download/v${PV}/${P}.tar.gz"
LICENSE="BSD"

SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+numpy"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="${PYTHON_DEP}
	~media-libs/ilmbase-${PV}:=
	$(python_gen_cond_dep '
		>=dev-libs/boost-1.62.0-r1[python(+),${PYTHON_MULTI_USEDEP}]
		numpy? (
			|| (
				dev-python/numpy-python2[${PYTHON_MULTI_USEDEP}]
				>=dev-python/numpy-1.10.4[${PYTHON_MULTI_USEDEP}]
			)
		)
	')
"
DEPEND="${RDEPEND}
	${PYTHON_DEP}
	>=virtual/pkgconfig-0-r1"

PATCHES=(
	"${FILESDIR}/${P}-link-pyimath.patch"
	"${FILESDIR}/${P}-fix-build-system.patch"
)

DOCS=( README.md )

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	local myeconfargs=(
		--with-boost-include-dir="${EPREFIX}/usr/include/boost"
		--with-boost-lib-dir="${EPREFIX}/usr/$(get_libdir)"
		--with-boost-python-libname="boost_python-${EPYTHON:6}"
		$(use_with numpy)
	)

	econf "${myeconfargs[@]}"
}

src_install() {
	# Fails to install with multiple jobs
	emake DESTDIR="${D}" -j1 install

	einstalldocs

	# package provides pkg-config files
	find "${D}" -name '*.la' -delete || die
}