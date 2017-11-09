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
    IFS=" " correct=`/usr/local/l2p/poker/correct-eval $testfile 2>&1`
    IFS=" " broken=`$prog $testfile 2>&1`
    if [ "$broken" != "$correct" ]
    then
	return 0
    fi
    return 1
}

for i in /usr/local/l2p/poker/eval-*
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
