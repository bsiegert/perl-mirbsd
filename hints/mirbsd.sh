# $MirOS: src/gnu/usr.bin/perl/hints/mirbsd.sh,v 1.4 2008/12/13 23:47:43 tg Exp $
#
# hints file for MirOS by Thorsten Glaser <tg@mirbsd.de>
# based upon hints for OpenBSD

[ -z "$cc" ] && cc="${CC:-mgcc}"

# MirOS has a better malloc than perl...
usemymalloc='n'

# Currently, vfork(2) is not a real win over fork(2).
usevfork="$undef"

test -z "$usedl" && usedl=$define
# We use -fPIC here because -fpic is *NOT* enough for some of the
# extensions like Tk on some platforms (ie: sparc)
cccdlflags="-DPIC -fPIC $cccdlflags"
ld=$cc
lddlflags="-shared -fPIC $lddlflags"
libswanted=$(echo $libswanted | sed 's/ dl / /')

# We need to force ld to export symbols on ELF platforms.
# Without this, dlopen() is crippled. All platforms are ELF.
ldflags="-Wl,-E $ldflags"

# malloc wrap works
case "$usemallocwrap" in
'') usemallocwrap='define' ;;
esac

# MirOS doesn't need libcrypt
libswanted=$(echo $libswanted | sed 's/ crypt / /')

# Configure can't figure this out non-interactively
d_suidsafe=$define

# cc is gcc so we can do better than -O
# Allow a command-line override, such as -Doptimize=-g
test "$optimize" || optimize='-O2'

# This script UU/usethreads.cbu will get 'called-back' by Configure
# after it has prompted the user for whether to use threads.
cat > UU/usethreads.cbu <<'EOCBU'
case "$usethreads" in
$define|true|[yY]*)
	ccflags="-pthread $ccflags"
	ldflags="-pthread $ldflags"
esac
EOCBU

# This script UU/use64bitint.cbu will get 'called-back' by Configure
# after it has prompted the user for whether to use 64-bitness.
cat > UU/use64bitint.cbu <<'EOCBU'
case "$use64bitint" in
$define|true|[yY]*)
	echo " "
	echo "Checking if your C library has broken 64-bit functions..." >&4
	$cat >check.c <<EOCP
#include <stdio.h>
typedef $uquadtype myULL;
int main (void)
{
    struct {
	double d;
	myULL  u;
    } *p, test[] = {
	{4294967303.15, 4294967303ULL},
	{4294967294.2,  4294967294ULL},
	{4294967295.7,  4294967295ULL},
	{0.0, 0ULL}
    };
    for (p = test; p->u; p++) {
	myULL x = (myULL)p->d;
	if (x != p->u) {
	    printf("buggy\n");
	    return 0;
	}
    }
    printf("ok\n");
    return 0;
}
EOCP
	set check
	if eval $compile_ok; then
	    libcquad=$(./check)
	    echo "Your C library's 64-bit functions are $libcquad."
	else
	    echo "(I can't seem to compile the test program.)"
	    echo "Assuming that your C library's 64-bit functions are ok."
	    libcquad="ok"
	fi
	$rm -f check.c check

	case "$libcquad" in
	    buggy*)
		cat >&4 <<EOM

*** You have a C library with broken 64-bit functions.
*** 64-bit support does not work reliably in this configuration.
*** Please rerun Configure without -Duse64bitint and/or -Dusemorebits.
*** Cannot continue, aborting.

EOM
		exit 1
		;;
	esac
esac
EOCBU

# When building in the MirOS tree we use different paths
# This is only part of the story, the rest comes from config.over
case "$mirbsd_distribution" in
''|$undef|false) ;;
*)
	# We put things in /usr, not /usr/local
	prefix='/usr'
	prefixexp='/usr'
	sysman='/usr/share/man/man1'
	libpth='/usr/lib'
	glibpth='/usr/lib'
	# Local things, however, do go in /usr/local
	siteprefix='/usr/local'
	siteprefixexp='/usr/local'
	# Ports installs non-std libs in /usr/local/lib so look there too
	locincpth='/usr/local/include'
	loclibpth='/usr/local/lib'
	# Link perl with shared libperl
	if [[ $usedl = @(y|$define) && -r shlib_version ]]; then
		useshrplib=true
		libperl=$(. ./shlib_version; echo libperl.so.${major}.${minor})
	fi
	;;
esac

# end
