# 3: script
# 4: testcase1.txt
# 5: testcase2.txt
# 6: reference implementation
vg="valgrind --leak-check=full "
vg2="valgrind --leak-check=no"
vga="--log-file=vg.log "
loadRefImpl /dev/fd/6
cat /dev/fd/4 > testcase1.txt
cat /dev/fd/5 > testcase2.txt
#does the code compile?
echo "Attempting to compile sortLines.c"
gcc -pedantic -Wall -Werror -std=gnu99  -o sortLines sortLines.c 2>&1
if [ "$?" != "0" ]
then
 echo "The code did not compile!"
 overallGradeLetter 0
 exit 0
fi
grade=0
testcase=1
#check with non-existent file
echo "#################################################"
echo "testcase$testcase:"
timeout -s 9 5 $vg2 $vga ./sortLines testcase1.txt NonExistentFile >/dev/null
valgrindErrorCheck
if [ "$?" == $FAILED ]
then
		echo "valgrind reported memory errors"
else
		errorHandlerCheck sortLines testcase1.txt NonExistentFile 
		if [ "$?" = "$PASSED" ]
		then
				echo "testcase$testcase passed, your program successfully indicated a failure"
				let grade=${grade}+5
				timeout -s 9 5  $vg $vga ./sortLines testcase1.txt NonExistentFile >/dev/null
				valgrindCheck
				if [ "$?" == $FAILED ]
				then
						echo "valgrind was not clean"
						cat vg.log | sed -re 's/Command:.*//' | sed -re 's/\/[a-zA-Z0-9._/]+graderbase\/work\/[a-zA-Z0-9._]+\///'
				else 
						echo "valgrind was clean"
						let grade=${grade}+5
				fi
		else
				echo "testcase$testcase failed, your program didn't indicate this is a failure case"
		fi
fi
#check one argument behavior
let testcase=${testcase}+1
echo "#################################################"
echo "testcase$testcase:"
timeout -s 9 5  $vg2 $vga printf "%s\n%s\n%s\n" "This is a test case" "it checks your program's one argument behavior" "start!" | tee | ./sortLines > theirs.txt
valgrindErrorCheck
if [ "$?" == $FAILED ]
then
		echo "valgrind reported memory errors"
else
		timeout -s 9 5  $vg $vga printf "%s\n%s\n%s\n" "This is a test case" "it checks your program's one argument behavior" "start!" | tee | ./sortLines > theirs.txt
		printf "%s\n%s\n%s\n" "This is a test case" "it checks your program's one argument behavior" "start!" | tee | runRefImpl > ours.txt
		diffFile theirs.txt ours.txt > /dev/null
		if [ "$?" = "$PASSED" ]
		then  
				echo "Your output is correct"
				let grade=${grade}+25
				valgrindCheck
				if [ "$?" == $FAILED ]
				then
						echo "valgrind was not clean"
						cat vg.log | sed -re 's/Command: .\/sortLines.*//' | sed -re 's/\/[a-zA-Z0-9._/]+graderbase\/work\/[a-zA-Z0-9._]+\///'
				else 
						echo "valgrind was clean"
						let grade=${grade}+5
				fi
		else 
				echo "Your output is incorrect"
		fi
fi

#check one file case
let testcase=${testcase}+1
echo "#################################################"
echo "testcase$testcase:"
timeout -s 9 5  $vg2 $vga ./sortLines testcase1.txt 3</dev/null 4< /dev/null 5</dev/null 6</dev/null> theirs.txt
valgrindErrorCheck
if [ "$?" == $FAILED ]
then
		echo "valgrind reported memory errors"
else
		timeout -s 9 5  $vg $vga  ./sortLines testcase1.txt 3</dev/null 4< /dev/null 5</dev/null 6</dev/null> theirs.txt
		runRefImpl testcase1.txt > ours.txt
		diffFile theirs.txt ours.txt > /dev/null
		if [ "$?" = "$PASSED" ]
		then  
				echo "Your output is correct"
				let grade=${grade}+25
				valgrindCheck
				if [ "$?" == $FAILED ]
				then
						echo "valgrind was not clean"
						cat vg.log | sed -re 's/Command: .\/sortLines.*//' | sed -re 's/\/[a-zA-Z0-9._/]+graderbase\/work\/[a-zA-Z0-9._]+\///'
				else 
						echo "valgrind was clean"
						let grade=${grade}+5
				fi
		else 
				echo "Your output is incorrect"
		fi
fi


#check two files case
let testcase=${testcase}+1
echo "#################################################"
echo "testcase$testcase:"
timeout -s 9 5  $vg2 $vga ./sortLines testcase1.txt testcase2.txt 3</dev/null 4< /dev/null 5</dev/null 6</dev/null> theirs.txt
valgrindErrorCheck
if [ "$?" == $FAILED ]
then
		echo "valgrind reported memory errors"
else	
		timeout -s 9 5  $vg $vga  ./sortLines testcase1.txt testcase2.txt 3</dev/null 4< /dev/null 5</dev/null 6</dev/null> theirs.txt
		runRefImpl testcase1.txt testcase2.txt > ours.txt
		diffFile theirs.txt ours.txt > /dev/null
		if [ "$?" = "$PASSED" ]
		then  
				echo "Your output is correct"
				let grade=${grade}+25
				valgrindCheck
				if [ "$?" == $FAILED ]
				then
						echo "valgrind was not clean"
						cat vg.log | sed -re 's/Command: .\/sortLines.*//' | sed -re 's/\/[a-zA-Z0-9._/]+graderbase\/work\/[a-zA-Z0-9._]+\///'
				else 
						echo "valgrind was clean"
						let grade=${grade}+5
				fi
		else 
				echo "Your output is incorrect"
		fi		
fi
overallGradeLetter $grade
exit 0


