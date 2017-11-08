# 3: script 
# 4: test main
# 5: reference implementation
vg="valgrind --leak-check=full "
vg2="valgrind --leak-check=no"
vga="--log-file=vg.log "
cat /dev/fd/4 > 61_counts.test_main.c
loadRefImpl /dev/fd/5

#does the code compile?
echo "Attempting to compile:"
#gcc -pedantic -Wall -Werror -std=gnu99 -o  counts_test counts.c counts.h 61_counts.test_main.c  2>&1
gcc -std=gnu99 -o counts_test  counts.c 61_counts.test_main.c
if [ "$?" != "0" ]
then
 echo "The code did not compile!"
 overallGradeLetter 0
 exit 0
fi

grade=0
testcase=0
for x in "9 banana apple frog frog apple sword bear zebra knight" "3 null null null" "11 null banana apple null frog frog apple sword bear zebra knight"
do
		let testcase=${testcase}+1;
		echo "#################################################"
		echo "testcase$testcase:"
		timeout -s 9 5  $vg2 $vga  ./counts_test $x 3</dev/null 4< /dev/null 5</dev/null > theirs.txt
		valgrindErrorCheck
		if [ "$?" == $FAILED ]
		then
				echo "valgrind reported memory errors"
		else
				timeout -s 9 5  $vg $vga  ./counts_test $x 3</dev/null 4< /dev/null 5</dev/null > theirs.txt
				runRefImpl $x > ours.txt
				diffFile theirs.txt ours.txt  > /dev/null
				if [ "$?" = "$PASSED" ]
				then  
						echo "Your output is correct"
						if [ $testcase == 1 ]
						then
								let grade=${grade}+17
						else
								let grade=${grade}+37
						fi
						valgrindCheck
						if [ "$?" == $FAILED ]
						then
								echo "valgrind was not clean"
								cat vg.log | sed -re 's/Command: .\/counts_test.*//' | sed -re 's/\/[a-zA-Z0-9._/]+graderbase\/work\/[a-zA-Z0-9._]+\///'
		else 
								echo "valgrind was clean"
								let grade=${grade}+3
						fi
				else 
						echo "Your output is incorrect"
				fi
		fi	
done

overallGradeLetter $grade
exit 0

