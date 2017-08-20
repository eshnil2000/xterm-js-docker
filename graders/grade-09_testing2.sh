checkFileExists tests.txt

if [ "$?" != "$PASSED" ]
then
    echo "Can't proceed without tests.txt"
    passFailGradeFromStatus $FAILED
    exit 0
fi

run_test(){
    prog="$1"
    testfile="$2"
    IFS=$'\n'
    for line in `cat $testfile`
    do
	IFS=" " correct=`/usr/local/ece551/match5/correct-match5 $line 2>&1`
	IFS=" " broken=`$prog $line 2>&1`
	if [ "$broken" != "$correct" ]
	then
	    return 0
	fi
    done
    return 1
}

for i in /usr/local/ece551/match5/match5-*
do
    run_test $i tests.txt
    x="$?"
    if [ "$x" != "0" ]
    then
	echo "Your test cases did not identify the problem with `basename $i`"
	passFailGradeFromStatus $FAILED
	exit 0
    else
	echo "Your test cases identified the problem with `basename $i`"
    fi
done

passFailGradeFromStatus $PASSED
exit 0
