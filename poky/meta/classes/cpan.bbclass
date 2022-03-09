#
# This is for perl modules that use the old Makefile.PL build system
#
inherit cpan-base perlnative

EXTRA_CPANFLAGS ?= ""
EXTRA_PERLFLAGS ?= ""

# Env var which tells perl if it should use host (no) or target (yes) settings
export PERLCONFIGTARGET = "${@is_target(d)}"

# Env var which tells perl where the perl include files are
export PERL_INC = "${STAGING_LIBDIR}${PERL_OWN_DIR}/perl5/${@get_perl_version(d)}/${@get_perl_arch(d)}/CORE"
export PERL_LIB = "${STAGING_LIBDIR}${PERL_OWN_DIR}/perl5/${@get_perl_version(d)}"
export PERL_ARCHLIB = "${STAGING_LIBDIR}${PERL_OWN_DIR}/perl5/${@get_perl_version(d)}/${@get_perl_arch(d)}"
export PERLHOSTLIB = "${STAGING_LIBDIR_NATIVE}/perl5/${@get_perl_version(d)}/"
export PERLHOSTARCHLIB = "${STAGING_LIBDIR_NATIVE}/perl5/${@get_perl_version(d)}/${@get_perl_hostarch(d)}/"

cpan_do_configure () {
	yes '' | perl ${EXTRA_PERLFLAGS} Makefile.PL INSTALLDIRS=vendor NO_PERLLOCAL=1 NO_PACKLIST=1 PERL=$(which perl) ${EXTRA_CPANFLAGS}

	# Makefile.PLs can exit with success without generating a
	# Makefile, e.g. in cases of missing configure time
	# dependencies. This is considered a best practice by
	# cpantesters.org. See:
	#  * http://wiki.cpantesters.org/wiki/CPANAuthorNotes
	#  * http://www.nntp.perl.org/group/perl.qa/2008/08/msg11236.html
	[ -e Makefile ] || bbfatal "No Makefile was generated by Makefile.PL"

	if [ "${BUILD_SYS}" != "${HOST_SYS}" ]; then
		. ${STAGING_LIBDIR}${PERL_OWN_DIR}/perl5/config.sh
		# Use find since there can be a Makefile generated for each Makefile.PL
		for f in `find -name Makefile.PL`; do
			f2=`echo $f | sed -e 's/.PL//'`
			test -f $f2 || continue
			sed -i -e "s:\(PERL_ARCHLIB = \).*:\1${PERL_ARCHLIB}:" \
				-e 's/perl.real/perl/' \
				-e "s|^\(CCFLAGS =.*\)|\1 ${CFLAGS}|" \
				$f2
		done
	fi
}

do_configure_append_class-target() {
       find . -name Makefile | xargs sed -E -i \
           -e 's:LD_RUN_PATH ?= ?"?[^"]*"?::g'
}

do_configure_append_class-nativesdk() {
       find . -name Makefile | xargs sed -E -i \
           -e 's:LD_RUN_PATH ?= ?"?[^"]*"?::g'
}

cpan_do_compile () {
	oe_runmake PASTHRU_INC="${CFLAGS}" LD="${CCLD}"
}

cpan_do_install () {
	oe_runmake DESTDIR="${D}" install_vendor
	for PERLSCRIPT in `grep -rIEl '#! *${bindir}/perl-native.*/perl' ${D}`; do
		sed -i -e 's|${bindir}/perl-native.*/perl|/usr/bin/env nativeperl|' $PERLSCRIPT
	done
}

EXPORT_FUNCTIONS do_configure do_compile do_install
