cat /dev/fd/6 > input3.txt
vg2="valgrind --leak-check=no"
vga="--log-file=vg.log "
# 3: script
# 4: testFile1 
# 5: testFile2
# 6: testFile3
# 7:reference implementation
#loadRefImp is used to load our ./power_answer to bash variable 
loadRefImpl /dev/fd/7
cat /dev/fd/4 > input1.txt
cat /dev/fd/5 > input2.txt

#does the code compile?
echo "Attempting to compile breaker.c "
make
if [ "$?" != "0" ]
then
 echo "The code did not compile!"
 overallGradeLetter 0
 exit 0
fi
grade=0
testcase=1
#check with wrong argument
timeout -s 9 5 $vg2 $vga ./breaker 
valgrindErrorCheck
if [ "$?" == $FAILED ]
then
		echo "valgrind reported memory errors"
else
		errorHandlerCheck breaker
		if [ "$?" == "$PASSED" ]
		then
				echo "testcase$testcase passed"
				let grade=${grade}+25
		else
				echo "testcase$testcase failed, your program didn't indicate this is a failure case"
		fi
fi

#check with provided testcase
#array size
for x in input1.txt input2.txt input3.txt
do
		let testcase=${testcase}+1
		echo "#################################################"
		echo "testcase$testcase:"
		timeout -s 9 10 $vg2 $vga ./breaker $x > temp.txt
		valgrindErrorCheck
		if [ "$?" == $FAILED ]
		then
				echo "valgrind reported memory errors or your program ran too long"
		else
				runRefImpl $x > correct.txt
				diffFile temp.txt correct.txt > /dev/null
				if [ "$?" = "$PASSED" ]
				then 
						echo "testcase$testcase passed"
						let grade=${grade}+25
				else 
						echo "testcase$testcase failed"
				fi
		fi
done
    

overallGradeLetter $grade
exit 0
 

