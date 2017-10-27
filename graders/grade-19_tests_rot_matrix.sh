#!/bin/bash

checkFileExists tests.txt

if [ "$?" != "$PASSED" ]
then
    echo "Can't proceed without tests.txt"
    passFailGradeFromStatus $FAILED
    exit 0
fi

run_test() {
    prog="$1"
    testfile="$2"
    IFS=$'\n'
    for line in `cat $testfile`
    do
	IFS=" " correct=`/usr/local/ece551/rot_matrix/rotateMatrix $line 2>&1`
	IFS=" " broken=`$prog $line 2>&1`
	if [ "$broken" != "$correct" ]
	then
	    return 0
	fi
    done
    return 1
}

for i in /usr/local/ece551/rot_matrix/rotateMatrix*
do
   if [ "$i" != "/usr/local/ece551/rot_matrix/rotateMatrix" ]
       then
	   echo "Checking `basename $i`"
	   run_test $i tests.txt
	   x="$?"
	   if [ "$x" != "0" ]
	   then
	       echo "***Your tests failed to show that `basename $i` was broken!"
	       passFailGradeFromStatus $FAILED
	       exit 0
	   else
	       echo "Your tests identified the problem with `basename $i`"
	   fi
   fi
done

echo "Your tests identified problems with all broken programs"
passFailGradeFromStatus $PASSED
exit 0
