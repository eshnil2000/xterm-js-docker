# 3: script
# 4: test list
# 5: test main
# 6: reference implementation

#loadRefImp is used to load our ./power_answer to bash variable 
loadRefImpl /dev/fd/6

#does the code compile?
echo "Attempting to compile maxSeq.c "
gcc -c -pedantic -Wall -Werror -std=gnu99  maxSeq.c  -o  maxSeq.o 2>&1
if [ "$?" != "0" ]
then
 echo "The code did not compile!"
 overallGradeLetter 0
 exit 0
fi
grade=20
testcase=1
cat /dev/fd/5 > temp2.c
echo "Linking your object file with our test main"
gcc -pedantic -Wall -Werror -std=gnu99 maxSeq.o temp2.c -o maxSeq2 2>&1 
if [ "$?" != "0" ]
then
  echo "Could not link with test main"
  overallGradeLetter $grade
  exit 0
fi
total=0
correct=0
#array size
for x in 0  1 100 5000
do
#array max and seed
		let testcase=${testcase}+1
		echo "#################################################"
		echo "testcase$testcase:"
    let y=${x}*10
    timeout -s 9 5 ./maxSeq2 $x $y $y 3</dev/null 4< /dev/null 5</dev/null 6</dev/null > temp.txt
    runRefImpl $x $y $y > correct.txt
    diffFile temp.txt correct.txt > /dev/null
    if [ "$?" = "$PASSED" ]
    then 
	    
	echo "array size:${x} was Correct"
	let correct=${correct}+1
    else 
	echo "array size:${x} was Incorrect"
    fi
    let total=${total}+1
done
    
if [ ${total} == ${correct} ]
then
    let grade=${grade}+80
else
    let grade="${correct}*80/${total}+${grade}"
fi
overallGradeLetter $grade
exit 0
 

