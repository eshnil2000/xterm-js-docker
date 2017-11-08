vg2="valgrind --leak-check=no"
vga="--log-file=vg.log "
# 3: script
# 4: testFile1 
# 5: testFile2
# 6: testFile3
# 7:reference implementation

cat /dev/fd/4 > testFile1.txt
cat /dev/fd/5 > testFile2.txt
cat /dev/fd/6 > testFile3.txt
cat /dev/fd/7 > testFile4.txt
cat /dev/fd/8 > ref.txt

#loadRefImpl /dev/fd/7

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
for x in "NonExistentFile" testFile2.txt testFile3.txt testFile4.txt 
do
		let testcase=${testcase}+1
		echo "#################################################"
		echo "testcase$testcase:"
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
    
if [ ${total} == ${correct} ]
then
    let grade=${grade}+60
else
		let grade="${correct}*60/${total}+${grade}"
fi
#sample input

let testcase=${testcase}+1
echo "#################################################"
echo "testcase$testcase:"
timeout -s 9 5 $vg2 $vga ./rotateMatrix testFile1.txt > temp.txt
valgrindErrorCheck
if [ "$?" == $FAILED ]
then
		echo "valgrind reported memory errors"
else
		timeout -s 9 5 $vg2 $vga ./rotateMatrix testFile1.txt > temp.txt
		#runRefImpl /dev/fd/4 > correct.txt
		diffFile temp.txt ref.txt
		if [ "$?" == "$PASSED" ]
		then 
				echo "testcase$testcase passed"
				let grade=${grade}+20
		else
				echo "testcase$testcase failed, your output did not match with the answer"
		fi
fi

overallGradeLetter $grade
exit 0
 

