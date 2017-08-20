vg="valgrind --leak-check=full "
vg2="valgrind --leak-check=no"
vga="--log-file=vg.log "
# 4: sample input
# 5: expected output
# 6: reference implementation
loadRefImpl /dev/fd/6
cat /dev/fd/4 >> 55_fix_vg_encr_input.txt
#does the code compile ?
echo "Attempting to compile encrypt.c"
gcc -pedantic -Wall -Werror -std=gnu99  -o encrypt encrypt.c 2>&1
if [ "$?" != "0" ]
then
		echo "The code did not compile!"
		overallGradeLetter 0
		exit 0
fi

grade=0
testcase=1
#checking output
echo "testcase$testcase:"
cat /dev/fd/5 > temp.txt
timeout -s 9 5 $vg2 $vga ./encrypt 5 55_fix_vg_encr_input.txt 
valgrindErrorCheck
if [ "$?" == $FAILED ]
then
		echo "valgrind reported memory errors"
else
		timeout -s 9 5 $vg $vga ./encrypt 5 55_fix_vg_encr_input.txt 
		diffFile  temp.txt 55_fix_vg_encr_input.txt.enc > /dev/null
		if [ "$?" = "$PASSED" ]
		then 
				echo "your output was correct"
				let grade=${grade}+45
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
				echo "your output was incorrect"
		fi
fi
#valgrind check
for x in 0 1 5 26 30
do
		let testcase=${testcase}+1
		echo "#################################################"
		echo "testcase$testcase:"
		timeout -s 9 5 $vg2 $vga ./encrypt $x 55_fix_vg_encr_input.txt 3</dev/null 4< /dev/null 5</dev/null 6</dev/null 
		valgrindErrorCheck
		if [ "$?" == $FAILED ]
		then
				echo "valgrind reported memory errors"
		else
				timeout -s 9 5 $vg $vga ./encrypt $x 55_fix_vg_encr_input.txt 3</dev/null 4< /dev/null 5</dev/null 6</dev/null 
				valgrindCheck
				if [ "$?" == $FAILED ]
				then
						echo "valgrind was not clean"
						cat vg.log | sed -re 's/Command:.*//' | sed -re 's/\/[a-zA-Z0-9._/]+graderbase\/work\/[a-zA-Z0-9._]+\///'
				else 
						echo "valgrind was clean"
						let grade=${grade}+10
				fi
		fi
done

overallGradeLetter $grade
exit 0
