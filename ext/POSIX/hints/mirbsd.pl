# $MirOS: src/gnu/usr.bin/perl/ext/POSIX/hints/mirbsd.pl,v 1.1.7.1 2005/03/06 17:01:26 tg Exp $
#
# BSD platforms have extra fields in struct tm that need to be initialized.
#  XXX A Configure test is needed.
$self->{CCFLAGS} = $Config{ccflags} . ' -DSTRUCT_TM_HASZONE' ;
