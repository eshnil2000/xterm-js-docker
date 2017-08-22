# 3: script
# 4  kvs1.txt
# 5  list1a.txt
# 6  list1b.txt
# 7  list1a.txt.ans
# 8  list1b.txt.ans
# 9  kvs2.txt
# 10 list2a.txt
# 11 list2b.txt
# 12 list2c.txt
# 13 list2a.txt.ans
# 14 list2b.txt.ans
# 15 list2c.txt.ans
# 16 kvs3.txt
# 17 list3a.txt
# 18 list3a.txt.ans
cat /dev/fd/5  > 62list1a.txt  
cat /dev/fd/6  > 62list1b.txt
cat /dev/fd/10 > 62list2a.txt
cat /dev/fd/11 > 62list2b.txt
cat /dev/fd/12 > 62list2c.txt
cat /dev/fd/17 > 62list3a.txt
vg="valgrind --leak-check=full "
vg2="valgrind --leak-check=no"
vga="--log-file=vg.log "
#does the code compile?

echo "Attempting to compile:"
make clean
make 2>&1

if [ "$?" != "0" ]
then
 echo "The code did not compile! Please try git add . to push all files in your working directory "
 overallGradeLetter 0
 exit 0
fi
grade=0
testcase=1
#check with wrong argument
echo "#################################################"
echo "testcase$testcase:"
timeout -s 9 5 $vg2 $vga ./count_values
valgrindErrorCheck
if [ "$?" == $FAILED ]
then
		echo "valgrind reported memory errors"
else
		errorHandlerCheck count_values 
		if [ "$?" = "$PASSED" ]
		then
				echo "testcase$testcase passed, your program successfully indicated a failure"
				let grade=${grade}+12
				timeout -s 9 5  $vg $vga ./count_values
				valgrindCheck
				if [ "$?" == $FAILED ]
				then
						echo "valgrind was not clean"
						cat vg.log | sed -re 's/Command:.*//' | sed -re 's/\/[a-zA-Z0-9._/]+graderbase\/work\/[a-zA-Z0-9._]+\///'
				else 
						echo "valgrind was clean"
						let grade=${grade}+3
				fi
		else
				echo "testcase$testcase failed, your program didn't indicate this is a failure case"
		fi
fi
#compare with list1a.ans list1b.ans
cat /dev/fd/4 > temp.txt
let testcase=${testcase}+1
cnt=0
echo "#################################################"
echo "testcase$testcase:"
timeout -s 9 5 $vg2 $vga ./count_values temp.txt 62list1a.txt 62list1b.txt
valgrindErrorCheck
if [ "$?" == $FAILED ]
then
		echo "valgrind reported memory errors"
else
		timeout -s 9 5  $vg $vga  ./count_values temp.txt 62list1a.txt 62list1b.txt
		diffFile 62list1a.txt.counts /dev/fd/7
		echo "Comparing file list1a.txt.counts with answer"
		if [ "$?" = "$PASSED" ]
		then  
				echo "Your output is correct"
				let grade=${grade}+11
				let cnt=${cnt}+1
		else 
				echo "Your output is incorrect"
		fi
		echo "Comparing file list1b.txt.counts with answer"
		diffFile 62list1b.txt.counts /dev/fd/8
		if [ "$?" = "$PASSED" ]
		then  
				echo "Your output is correct"
				let grade=${grade}+11
				let cnt=${cnt}+1
		else 
				echo "Your output is incorrect"
		fi

		if [ $cnt -eq 2 ]
		then
				valgrindCheck
				if [ "$?" == $FAILED ]
				then
						echo "valgrind was not clean"
						cat vg.log | sed -re 's/Command: .\/count_values.*//'| sed -re 's/\/[a-zA-Z0-9._/]+graderbase\/work\/[a-zA-Z0-9._]+\///'
				else 
						echo "valgrind was clean"
						let grade=${grade}+3
				fi
		fi
fi

#compare with list2a.ans list2b.ans list2c.ans
cnt=0
cat /dev/fd/9 > temp.txt
let testcase=${testcase}+1
echo "#################################################"
echo "testcase$testcase:"
timeout -s 9 5 $vg2 $vga ./count_values temp.txt 62list2a.txt 62list2b.txt 62list2c.txt 
valgrindErrorCheck
if [ "$?" == $FAILED ]
then
		echo "valgrind reported memory errors"
else
		timeout -s 9 5  $vg $vga ./count_values temp.txt 62list2a.txt 62list2b.txt 62list2c.txt 
		diffFile 62list2a.txt.counts /dev/fd/13
		echo "Comparing file list2a.txt.counts with answer"
		if [ "$?" = "$PASSED" ]
		then  
				echo "Your output is correct"
				let grade=${grade}+11
				let cnt=${cnt}+1
		else 
				echo "Your output is incorrect"
		fi
		
		echo "Comparing file list2b.txt.counts with answer"
		diffFile 62list2b.txt.counts /dev/fd/14
		if [ "$?" = "$PASSED" ]
		then  
				echo "Your output is correct"
				let grade=${grade}+11
				let cnt=${cnt}+1
		else 
				echo "Your output is incorrect"
		fi

		echo "Comparing file list2c.txt.counts with answer"
		diffFile 62list2c.txt.counts /dev/fd/15
		if [ "$?" = "$PASSED" ]
		then  
				echo "Your output is correct"
				let grade=${grade}+11
				let cnt=${cnt}+1
		else 
				echo "Your output is incorrect"
		fi

		if [ $cnt -eq 3 ]
		then
				valgrindCheck
				if [ "$?" == $FAILED ]
				then
						echo "valgrind was not clean"
						cat vg.log | sed -re 's/Command: .\/count_values.*//'| sed -re 's/\/[a-zA-Z0-9._/]+graderbase\/work\/[a-zA-Z0-9._]+\///'
				else 
						echo "valgrind was clean"
						let grade=${grade}+2
				fi
		fi
fi


#compare with list3a.ans 
let testcase=${testcase}+1
cat /dev/fd/16 > temp.txt
echo "#################################################"
echo "testcase$testcase:"
timeout -s 9 5  $vg2 $vga  ./count_values temp.txt 62list3a.txt 
valgrindErrorCheck
if [ "$?" == $FAILED ]
then
		echo "valgrind reported memory errors"
else
		timeout -s 9 5  $vg $vga  ./count_values temp.txt 62list3a.txt 
		cat /dev/fd/18 > ours.txt
		diffFile 62list3a.txt.counts ours.txt
		echo "Comparing file list3a.txt.counts with answer"
		if [ "$?" = "$PASSED" ]
		then  
				echo "Your output is correct"
				let grade=${grade}+23
				valgrindCheck
				if [ "$?" == $FAILED ]
				then
						echo "valgrind was not clean"
						cat vg.log | sed -re 's/Command: .\/count_values.*//'| sed -re 's/\/[a-zA-Z0-9._/]+graderbase\/work\/[a-zA-Z0-9._]+\///'
				else 
						echo "valgrind was clean"
						let grade=${grade}+2
				fi
		else 
				echo "Your output is incorrect"
		fi
fi

overallGradeLetter ${grade}
exit 0

