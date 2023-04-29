# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{9..11} )
inherit python-single-r1 cmake

DESCRIPTION="Library for rectifying and simulating photographic lens distortions"
HOMEPAGE="https://lensfun.github.io"
SRC_URI="https://github.com/${PN}/${PN}/archive/refs/tags/v${PV/_rc/-RC}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${P/_rc/-RC}"

LICENSE="LGPL-3 CC-BY-SA-3.0" # See README for reasoning.
SLOT="0"
KEYWORDS="~alpha amd64 ~arm ~arm64 ~hppa ~ia64 ~loong ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc x86 ~amd64-linux ~x86-linux"
IUSE="doc cpu_flags_x86_sse cpu_flags_x86_sse2 test"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RESTRICT="!test? ( test )"

RDEPEND="${PYTHON_DEPS}
	>=dev-libs/glib-2.40
	media-libs/libpng:0=
	sys-libs/zlib
"
DEPEND="${RDEPEND}"
BDEPEND="
	doc? (
		app-doc/doxygen
		dev-python/docutils
	)
"

DOCS=( README.md docs/mounts.txt ChangeLog )

src_configure() {
	local mycmakeargs=(
		-DCMAKE_INSTALL_DOCDIR="${EPREFIX}"/usr/share/doc/${PF}/html
		-DSETUP_PY_INSTALL_PREFIX=/usr
		-DBUILD_LENSTOOL=ON
		-DBUILD_STATIC=OFF
		-DBUILD_DOC=$(usex doc)
		-DBUILD_FOR_SSE=$(usex cpu_flags_x86_sse)
		-DBUILD_FOR_SSE2=$(usex cpu_flags_x86_sse2)
		-DBUILD_TESTS=$(usex test)
	)
	cmake_src_configure
}

src_test() {
	mkdir -p "${T}/db/lensfun" || die
	cp data/db/* "${T}/db/lensfun/" || die

	XDG_DATA_HOME="${T}/db" cmake_src_test
}

src_install() {
	cmake_src_install
	python_optimize
}
