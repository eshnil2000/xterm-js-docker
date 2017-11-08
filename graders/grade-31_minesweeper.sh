# 4: reference implementation
vg="valgrind --leak-check=full "
vg2="valgrind --leak-check=no"
vga="--log-file=vg.log "
loadRefImpl /dev/fd/4


#does the code compile?
echo "Attempting to compile minesweeper.c"
gcc -pedantic -Wall -Werror -std=gnu99  -o minesweeper minesweeper.c 2>&1
if [ "$?" != "0" ]
then
 echo "The code did not compile!"
 overallGradeLetter 0
 exit 0
fi
grade=0
testcase=0
#testcase1
let testcase=${testcase}+1
echo "#################################################"
echo "testcase$testcase:"
printf "%d\n%d\n%d\n%d\n%s\n" 0 0 1 1 "no"  |  timeout -s 9 5 $vg2 $vga  ./minesweeper 3 3 1  > theirs.txt 2>&1
valgrindErrorCheck
if [ "$?" == $FAILED ]
then
		echo "valgrind reported memory errors"
else
		printf "%d\n%d\n%d\n%d\n%s\n" 0 0 1 1 "no"  | timeout -s 9 5 $vg $vga  ./minesweeper 3 3 1  > theirs.txt 2>&1
		printf "%d\n%d\n%d\n%d\n%s\n" 0 0 1 1 "no"  | runRefImpl 3 3 1 > ours.txt
		diffFile theirs.txt ours.txt > /dev/null
		if [ "$?" = "$PASSED" ]
		then  
				echo "Your output is correct"
				let grade=${grade}+22
				valgrindCheck
				if [ "$?" == $FAILED ]
				then
						echo "valgrind was not clean"
						#cat vg.log | sed -re 's/Command: .\/minesweeper 3 3 1//' | sed -re 's/\/[a-zA-Z0-9._/]+graderbase\/work\/[a-zA-Z0-9._]+\///'
						cat vg.log | sed -re 's/Command: .\/minesweeper.*//' | sed -re 's/\/[a-zA-Z0-9._/]+graderbase\/work\/[a-zA-Z0-9._]+\///'
				else 
						echo "valgrind was clean"
						let grade=${grade}+3
				fi
		else
				echo "Your output is incorrect"			
		fi
fi

#testcase2
let testcase=${testcase}+1
echo "#################################################"
echo "testcase$testcase:"
printf "%d\n%d\n%s\n%d\n%d\n%d\n%d\n%s" 0 0 "yes" 2 2  0 0 "no" | timeout -s 9 5 $vg2 $vga  ./minesweeper 1 1 1  > theirs.txt 2>&1
valgrindErrorCheck
if [ "$?" == $FAILED ]
then
		echo "valgrind reported memory errors"
else
		printf "%d\n%d\n%s\n%d\n%d\n%d\n%d\n%s" 0 0 "yes" 2 2  0 0 "no" | timeout -s 9 5 $vg $vga  ./minesweeper 1 1 1  > theirs.txt 2>&1
		printf "%d\n%d\n%s\n%d\n%d\n%d\n%d\n%s" 0 0 "yes" 2 2  0 0 "no"  |  runRefImpl 1 1 1 > ours.txt
		diffFile theirs.txt ours.txt > /dev/null
		if [ "$?" = "$PASSED" ]
		then  
				echo "Your output is correct"
				let grade=${grade}+22
				valgrindCheck
				if [ "$?" == $FAILED ]
				then
						echo "valgrind was not clean"
						cat vg.log | sed -re 's/Command: .\/minesweeper.*//' | sed -re 's/\/[a-zA-Z0-9._/]+graderbase\/work\/[a-zA-Z0-9._]+\///'
				else 
						echo "valgrind was clean"
						let grade=${grade}+3
				fi
		else 
				echo "Your output is incorrect"
		fi
fi

#testcase3
let testcase=${testcase}+1
echo "#################################################"
echo "testcase$testcase:"
printf "%d\n%d\n%s\n%d\n%d\n%s" 7 7 "yes"   9 0 "no"  |  timeout -s 9 5 $vg2 $vga  ./minesweeper 10 10 100  > theirs.txt 2>&1
valgrindErrorCheck
if [ "$?" == $FAILED ]
then
		echo "valgrind reported memory errors"
else
		printf "%d\n%d\n%s\n%d\n%d\n%s" 7 7 "yes"   9 0 "no"  |  timeout -s 9 5 $vg $vga  ./minesweeper 10 10 100  > theirs.txt 2>&1
		printf "%d\n%d\n%s\n%d\n%d\n%s" 7 7 "yes"   9 0 "no"  |  runRefImpl 10 10 100 > ours.txt

		diffFile theirs.txt ours.txt > /dev/null
		if [ "$?" = "$PASSED" ]
		then  
				echo "Your output is correct"
				let grade=${grade}+22
				valgrindCheck
				if [ "$?" == $FAILED ]
				then
						echo "valgrind was not clean"
						cat vg.log | sed -re 's/Command: .\/minesweeper.*//' | sed -re 's/\/[a-zA-Z0-9._/]+graderbase\/work\/[a-zA-Z0-9._]+\///'
				else 
						echo "valgrind was clean"
						let grade=${grade}+3
				fi
		else 
				echo "Your output is incorrect"
		fi
fi


#testcase4
let testcase=${testcase}+1
echo "#################################################"
echo "testcase$testcase:"
printf "%d\n%d\n%d\n%d\n%d\n%d\n%d\n%d\n%s" 0 0 9 0 9 0 0 9 "no" | timeout -s 9 5 $vg2 $vga  ./minesweeper 10 10 10  > theirs.txt 2>&1
valgrindErrorCheck
if [ "$?" == $FAILED ]
then
		echo "valgrind reported memory errors"
else
		printf "%d\n%d\n%d\n%d\n%d\n%d\n%d\n%d\n%s" 0 0 9 0 9 0 0 9 "no" | timeout -s 9 5 $vg $vga  ./minesweeper 10 10 10  > theirs.txt 2>&1
		printf "%d\n%d\n%d\n%d\n%d\n%d\n%d\n%d\n%s" 0 0 9 0 9 0 0 9 "no"   |  runRefImpl 10 10 10 > ours.txt
		diffFile theirs.txt ours.txt > /dev/null
		if [ "$?" = "$PASSED" ]
		then  
				echo "Your output is correct"
				let grade=${grade}+22
				valgrindCheck
				if [ "$?" == $FAILED ]
				then
						echo "valgrind was not clean"
						cat vg.log | sed -re 's/Command: .\/minesweeper.*//' | sed -re 's/\/[a-zA-Z0-9._/]+graderbase\/work\/[a-zA-Z0-9._]+\///'
				else 
						echo "valgrind was clean"
						let grade=${grade}+3
				fi
		else 
				echo "Your output is incorrect"
		fi
fi

overallGradeLetter $grade
exit 0
