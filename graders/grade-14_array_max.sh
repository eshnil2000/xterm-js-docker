# 3: script
# 4: expected output for their function
# 5: test main
# 6: reference implementation

#loadRefImp is used to load our ./power_answer to bash variable 
loadRefImpl /dev/fd/6

#does the code compile?
echo "Attempting to compile arrayMax.c "
gcc -pedantic -Wall -Werror -std=gnu99  arrayMax.c  -o  arrayMax 2>&1
if [ "$?" != "0" ]
then
 echo "The code did not compile!"
 overallGradeLetter 0
 exit 0
fi
grade=0
testcase=1
#check with provided testcase
echo "#################################################"
echo "testcase$testcase:"
timeout -s 9 5 ./arrayMax 3</dev/null 4< /dev/null 5</dev/null 6</dev/null > temp.txt
diffFile temp.txt /dev/fd/4
if [ "$?" != "$PASSED" ]
then
    echo "Your output did not match what we expected."
else 
    echo "Your output matched what we expected"
    let grade=${grade}+20
fi

#replace with test main(new testcase)
echo "Removing your main() and replacing it with our own to run more tests..."
clangStripFn "arrayMax.c" "main" "int" > temp.c
cat temp.c /dev/fd/5 > temp2.c
gcc -pedantic -Wall -Werror -std=gnu99 temp2.c -o arrayMax2 2>&1 
if [ "$?" != "0" ]
then
  echo "Could not replace your main function to test further"
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
    timeout -s 9 5 ./arrayMax2 $x $y $y 3</dev/null 4< /dev/null 5</dev/null 6</dev/null > temp.txt
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
 

