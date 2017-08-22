# 3: (script)
# 4: expected output for their main
# 5: our main (c file)
# 6: reference implementation (executable, with our main)

loadRefImpl /dev/fd/6

# does the code compile?
echo "Attempting to compile rectangle.c"
gcc -pedantic -Wall -Werror -std=gnu99 rectangle.c -o rectangle 2>&1
if [ "$?" != "0" ]
then
 echo "The code did not compile!"
 overallGradeLetter 0
 exit 0
fi

echo "Tring to run rectangle"
timeout -s 9 5 ./rectangle 3</dev/null 4</dev/null 5</dev/null 6</dev/null > temp.txt
diffFile temp.txt /dev/fd/4
if [ "$?" != "$PASSED" ]
then
		echo "Your output did not match what we expected. Here is what you printed"
		cat temp.txt
		overallGradeLetter 20
		exit 0
fi
echo "removing your main() and replacing it with out own to run more tests..."
clangStripFn "rectangle.c" "main" "int" > temp.c
cat temp.c /dev/fd/5 > temp2.c
gcc -pedantic -Wall -Werror -std=gnu99 temp2.c -o rectangle2 2>&1
if [ "$?" != "0" ]
then
		echo "Could not replace your main function to test further"
		overallGradeLetter 50
		exit 0
fi
grade=50
#testcase1
echo "#################################################"
echo "testcase1:"
timeout -s 9 5 ./rectangle2 0 0 1 0 0 0 1 1 3</dev/null 4< /dev/null 5</dev/null 6</dev/null > temp.txt
runRefImpl  0 0 1 0 0 0 1 1 > correct.txt
diffFile temp.txt correct.txt > /dev/null 
if [ "$?" = "$PASSED" ]
then
		echo "testcase1 passed"
		let grade=${grade}+25
else
		echo "testcase1 failed"
fi

#testcase2
echo "#################################################"
echo "testcase2:"
timeout -s 9 5 ./rectangle2 0 0 1 1 1 1 -1 -1  3</dev/null 4< /dev/null 5</dev/null 6</dev/null > temp.txt
runRefImpl  0 0 1 1 1 1 -1 -1 > correct.txt
diffFile temp.txt correct.txt > /dev/null 
if [ "$?" = "$PASSED" ]
then
		echo "testcase2 passed"
		let grade=${grade}+25
else
		echo "testcase2 failed"
fi
overallGradeLetter $grade
exit 0


