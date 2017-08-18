loadRefImpl /dev/fd/4
checkFileExists squares.c
if [ "$?" != "$PASSED" ]
then
    echo "Cannot proceed without squares.c"
    passFailGradeFromStatus $FAILED
    exit 0
fi
checkFileExists squares_test.o
if [ "$?" != "$PASSED" ]
then
    echo "Cannot proceed without squares_test.o"
    passFailGradeFromStatus $FAILED
    exit 0
fi
echo "Trying to compile your code and link with squares_test.o"
gcc -o squares -Wall -Werror -pedantic -std=gnu99 squares.c squares_test.o 2>&1
if [ "$?" != "$PASSED" ]
then
    echo "Could not compile your code"
    passFailGradeFromStatus $FAILED
    exit 0
fi
allright=1
for size1 in 1 4 8 11
do
    for xoffs in 0 4 7
    do
	for yoffs in 0 1 3 8
	do
	    for size2 in 1 5 9 
	    do
		echo "Testing ./squares $size1 $xoffs $yoffs $size2"
		checkProgVsRef ./squares - $size1 $xoffs $yoffs $size2
		if [ "$?" != "$PASSED" ]
		then
		    echo " - Incorrect"
		    allright=0
		else
		    echo " - Correct"
		fi
	    done
	done
    done
done
if [ "$allright" != 1 ]
then
    echo "You need to fix the incorrect cases above and try again"
    passFailGradeFromStatus $FAILED
else
    echo "You got all cases right"
    passFailGradeFromStatus $PASSED
fi
