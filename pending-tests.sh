#!/bin/bash


SRCLIST=`mktemp /tmp/pending.src.XXXXX`;
TRGLIST=`mktemp /tmp/pending.trg.XXXXX`;
TSTLIST=`mktemp /tmp/pending.tst.XXXXX`;

basedir=`pwd`;
mode=isl-eng

wget -O - -q http://wiki.apertium.org/wiki/Icelandic_and_English/Pending_tests | grep '<li>' | sed 's/<.*li>//g' | sed 's/ /_/g' | cut -f2 -d')' | sed 's/<i>//g' | sed 's/<\/i>//g' | cut -f2 -d'*' | sed 's/→/!/g' | cut -f1 -d'!' | sed 's/(note:/!/g' | sed 's/&nbsp;/ /g' | sed 's/_/ /g' | sed 's/$/./g' > $SRCLIST;
wget -O - -q http://wiki.apertium.org/wiki/Icelandic_and_English/Pending_tests | grep '<li>' | sed 's/<.*li>//g' | sed 's/ /_/g' | sed 's/(\w\w)//g' | sed 's/<i>//g' | cut -f2 -d'*' | sed 's/<\/i>_→/!/g' | cut -f2 -d'!' | sed 's/_/ /g' | sed 's/^ *//g' | sed 's/&nbsp;/ /g' | sed 's/ *$//g' | sed 's/$/./g' > $TRGLIST;

apertium -d . $mode < $SRCLIST > $TSTLIST;

cat $SRCLIST | sed 's/\.$//g' > $SRCLIST.n; mv $SRCLIST.n $SRCLIST;
cat $TRGLIST | sed 's/\.$//g' > $TRGLIST.n; mv $TRGLIST.n $TRGLIST;
cat $TSTLIST | sed 's/\.$//g' > $TSTLIST.n; mv $TSTLIST.n $TSTLIST;

TOTAL=0
CORRECT=0
for LINE in `paste -d'!' $SRCLIST $TRGLIST $TSTLIST | sed 's/ /%_%/g'`; do
#	echo $LINE;

	SRC=`echo $LINE | sed 's/%_%/ /g' | cut -f1 -d'!' | sed 's/^ *//g' | sed 's/ *$//g'`;
	TRG=`echo $LINE | sed 's/%_%/ /g' | cut -f2 -d'!' | sed 's/^ *//g' | sed 's/ *$//g'`;
	TST=`echo $LINE | sed 's/%_%/ /g' | cut -f3 -d'!' | sed 's/^ *//g' | sed 's/ *$//g'`;

	
	if [[ $TRG != $TST ]]; then
		echo -e $mode"\t  "$SRC"\n\t- $TRG\n\t+ "$TST"\n";
	else
		echo -e $mode"\t  "$SRC"\nWORKS\t  $TST\n";
		CORRECT=`expr $CORRECT + 1`;
	fi
	TOTAL=`expr $TOTAL + 1`;
done

echo $CORRECT" / "$TOTAL ;
if [ -x /usr/bin/calc ]; then
	WORKING=`calc $CORRECT" / "$TOTAL" * 100" | head -c 7`;

	echo $WORKING"%";
fi

rm $SRCLIST $TRGLIST $TSTLIST;
