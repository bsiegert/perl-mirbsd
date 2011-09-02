# $MirOS: src/gnu/usr.bin/perl/ext/DynaLoader/hints/mirbsd.pl,v 1.1.7.1 2005/03/06 17:01:26 tg Exp $

# XXX does this still apply to MirOS BSD?

# XXX Configure test needed?
# Some OpenBSDs seem to have a dlopen() that won't accept relative paths
$self->{CCFLAGS} = $Config{ccflags} . ' -DDLOPEN_WONT_DO_RELATIVE_PATHS';
