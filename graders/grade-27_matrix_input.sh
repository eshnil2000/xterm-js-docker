vg2="valgrind --leak-check=no"
vga="--log-file=vg.log "
cat /dev/fd/4 > blank.txt
cat /dev/fd/5 > normal1.txt
cat /dev/fd/6 > short-line.txt
cat /dev/fd/7 > short-file.txt
cat /dev/fd/8 > long-line.txt
cat /dev/fd/9 > long-file.txt
cat /dev/fd/10 > eof.txt
cat /dev/fd/11 > normal2.txt
cat /dev/fd/12 > normal3.txt
cat /dev/fd/13 > long-line-2.txt




#does the code compile?
echo "Attempting to compile rotateMatrix.c"
gcc -pedantic -Wall -Werror -std=gnu99  -o rotateMatrix rotateMatrix.c 2>&1
if [ "$?" != "0" ]
then
    echo "The code did not compile!"
    overallGradeLetter 0
    exit 0
fi
grade=0
testcase=1
#check with wrong argument
timeout -s 9 5 $vg2 $vga ./rotateMatrix > temp.txt
valgrindErrorCheck
if [ "$?" == $FAILED ]
then
    echo "valgrind reported memory errors"
else
    errorHandlerCheck rotateMatrix
    if [ "$?" == "$PASSED" ]
    then
	echo "testcase$testcase passed"
	let grade=${grade}+20
    else
	echo "testcase$testcase failed, your program didn't indicate this is a failure case"
    fi
fi
#check with non-existent file and wrong inputfile

total=0
correct=0
for x in "NonExistentFile" blank.txt short-line.txt short-file.txt long-line.txt long-file.txt long-line-2.txt "normal1.txt normal2.txt" 
do
    let testcase=${testcase}+1
    echo "#################################################"
    echo "testcase$testcase: $x"
    echo " (should indicate an error)"
    timeout -s 9 5 $vg2 $vga ./rotateMatrix $x > temp.txt
    valgrindErrorCheck
    if [ "$?" == $FAILED ]
    then
	echo "valgrind reported memory errors"
    else
	errorHandlerCheck rotateMatrix $x
	if [ "$?" == "$PASSED" ]
	then 
	    echo "testcase$testcase passed"
	    let correct=${correct}+1
	else 
	    echo "testcase$testcase failed, your program didn't indicate this is a failure case"
	fi
    fi
    let total=${total}+1
done

#sample input

let testcase=${testcase}+1
for fname in normal1.txt normal2.txt normal3.txt eof.txt
do
    echo "#################################################"
    echo "testcase$testcase: $fname"
    timeout -s 9 5 $vg2 $vga ./rotateMatrix $fname > temp.txt
    valgrindErrorCheck
    if [ "$?" == $FAILED ]
    then
	echo "valgrind reported memory errors"
    else
	/usr/local/l2p/rot_matrix/rotateMatrix $fname > correct.txt
	diffFile temp.txt correct.txt
	if [ "$?" == "$PASSED" ]
	then 
	    echo "testcase$testcase passed"
	    let correct=${correct}+1
	else
	    echo "testcase$testcase failed, your output did not match with the answer"
	    if [ "$fname" == "eof.txt" ]
	    then
		echo " (Maybe you mishandled reading character 0xFF?)"
	    fi
	fi
	let total=${total}+1
    fi
done
let wrong=${total}-${correct}
let grade=100-${wrong}*14

if [ ${grade} -lt 0 ]
then
    let grade=0
fi

overallGradeLetter $grade
exit 0


