# 3: script
# 4: testcase1.txt
# 5: testcase2.txt
# 6: testcase3.txt
# 7: test main
# 8: reference implementation
vg="valgrind --leak-check=full "
vg2="valgrind --leak-check=no"
vga="--log-file=vg.log "

cat /dev/fd/4 > testcase1.txt
cat /dev/fd/5 > testcase2.txt
cat /dev/fd/6 > testcase3.txt
cat /dev/fd/7 > 59_kvs.test_main.c
#loadRefImp is used to load our ./kvs_test to bash variable 
loadRefImpl /dev/fd/8

#does the code compile?
echo "Attempting to compile:"
gcc -pedantic -Wall -Werror -std=gnu99 -o kv_test kv.c 59_kvs.test_main.c 2>&1
if [ "$?" != "0" ]
then
 echo "The code did not compile!"
 overallGradeLetter 0
 exit 0
fi

grade=0
testcase=0
for x in testcase1.txt testcase2.txt testcase3.txt
do
		let testcase=${testcase}+1;
		echo "#################################################"
		echo "testcase$testcase:"
		timeout -s 9 5  $vg2 $vga  ./kv_test $x 3</dev/null 4< /dev/null 5</dev/null 6</dev/null 7</dev/null 8</dev/null  > theirs.txt
		valgrindErrorCheck
		if [ "$?" == $FAILED ]
		then
				echo "valgrind reported memory errors"
		else
				timeout -s 9 5  $vg $vga  ./kv_test $x 3</dev/null 4< /dev/null 5</dev/null 6</dev/null 7</dev/null 8</dev/null  > theirs.txt
				runRefImpl $x > ours.txt
				diffFile theirs.txt ours.txt   > /dev/null
				if [ "$?" = "$PASSED" ]
				then  
						echo "Your output is correct"
						if [ $testcase == 3 ]
						then
								let grade=${grade}+18
						else
								let grade=${grade}+38
						fi
						valgrindCheck
						if [ "$?" == $FAILED ]
						then
								echo "valgrind was not clean"
								cat vg.log | sed -re 's/Command: .\/kv_test.*//' | sed -re 's/\/[a-zA-Z0-9._/]+graderbase\/work\/[a-zA-Z0-9._]+\///'
						else 
								echo "valgrind was clean"
								let grade=${grade}+2
						fi
				else 
						echo "Your output is incorrect"
				fi
		fi
done

overallGradeLetter $grade
exit 0

