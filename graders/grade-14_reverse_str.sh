# 3: script
# 4: expected output for their function
# 5: test main
# 6: reference implementation

#loadRefImp is used to load our ./power_answer to bash variable 
loadRefImpl /dev/fd/6

#does the code compile?
echo "Attempting to compile  reverse.c"
gcc -pedantic -Wall -Werror -std=gnu99  reverse.c -o  reverse 2>&1
if [ "$?" != "0" ]
then
 echo "The code did not compile!"
 overallGradeLetter 0
 exit 0
fi
grade=0
testcase=1
#check with provided testcase
timeout -s 9 5 ./reverse 3</dev/null 4< /dev/null 5</dev/null 6</dev/null > temp.txt
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
clangStripFn "reverse.c" "main" "int" > temp.c
cat temp.c /dev/fd/5 > temp2.c
gcc -pedantic -Wall -Werror -std=gnu99 temp2.c -o reverse2 2>&1 
if [ "$?" != "0" ]
then
  echo "Could not replace your main function to test further"
  overallGradeLetter $grade
  exit 0
fi
#check null
let testcase=${testcase}+1
echo "#################################################"
echo "testcase$testcase:"
timeout -s 9 5 ./reverse2  3</dev/null 4< /dev/null 5</dev/null 6</dev/null
checkExitStatus ${PIPESTATUS[0]}
if [ "$?" != "$PASSED" ]
then	
		echo "your code failed the testcase"
else
		let grade=${grade}+20
fi

total=0
correct=0
for x in "hello" "a"  "this is a test case!"
do
		let testcase=${testcase}+1
		echo "#################################################"
		echo "testcase$testcase:"
    timeout -s 9 5 ./reverse2 $x 3</dev/null 4< /dev/null 5</dev/null 6</dev/null > temp2.txt
    runRefImpl $x > correct.txt
    diffFile temp2.txt correct.txt 
    if [ "$?" != "$PASSED" ]
    then	
	echo "your code failed the testcase"
    else
	let correct=${correct}+1
    fi
    let total=${total}+1
done

if [ ${total} == ${correct} ]
then
		let grade=${grade}+60
else
    let grade="${correct}*60/${total}+${grade}"
fi
overallGradeLetter $grade
exit 0


