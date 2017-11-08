#!/bin/bash
checkFileExists test-subseq.c

if [ "$?" != "$PASSED" ]
then
    echo "Can't proceed without test-subseq.c"
    passFailGradeFromStatus $FAILED
    exit 0
fi

for i in /usr/local/l2p/subseq/subseq*.o
do
    test=`basename $i | sed 's/subseq//' | sed 's/.o//'`
    if [ "$test"  == "" ]
    then
	echo "**Testing correct implementation **"
    else
	echo "**Testing broken implementation ${test} **"
    fi
    echo "-------------------------------------"
    echo ""

    gcc -o test-subseq test-subseq.c $i
    if [ "$?" != "0" ]
    then
	echo "Could not compile test-subseq.c with $i" 
	passFailGradeFromStatus $FAILED
	exit 0

    fi
    timeout -s 9 10 ./test-subseq
    res="$?"
    if [  "$res" == 124 ]
    then
	echo "Trying to run your tests took too long (infinite loop in your code?)"
	passFailGradeFromStatus $FAILED
	exit 0
    fi
    if [ "$res" != 0 ]
    then
	if [ "$test" == "" ]
	then
	    echo "Your test program falsely failed the correct implementation!"
	    passFailGradeFromStatus $FAILED
	    exit 0
	    
	fi
    else
	if [ "$test" != "" ]
	then
	    echo "Your test program did not identify $i as broken!"
	    passFailGradeFromStatus $FAILED
	    exit 0

	fi
    fi
    echo ""
done
echo "All test programs were handled correctly"
passFailGradeFromStatus $PASSED
exit 0
