vg2="valgrind --leak-check=no"
vga="--log-file=vg.log "
# 3: script
# 4: read-matrix.o
# 5: refImpl
# 6+: inputs 


cat /dev/fd/4 > our-read-matrix.o
loadRefImpl /dev/fd/5
cat /dev/fd/6 > test1.txt
cat /dev/fd/7 > test2.txt
cat /dev/fd/8 > test3.txt
#does the code compile?
echo "Attempting to compile rotate.c"
gcc -pedantic -Wall -Werror -std=gnu99  -o rotateMatrix rotate.c our-read-matrix.o 2>&1
if [ "$?" != "0" ]
then
 echo "The code did not compile!"
 overallGradeLetter 0
 exit 0
fi
grade=10
testcase=1
#check with wrong argument
for infile in test1.txt test2.txt test3.txt
do
    echo "Running testcase $testcase"
    timeout -s 9 5 $vg2 $vga ./rotateMatrix $infile > temp.txt
    valgrindErrorCheck
    if [ "$?" == $FAILED ]
    then
	echo "valgrind reported memory errors"
    else
	runRefImpl $infile> correct.txt
	diffFile temp.txt correct.txt
	if [ "$?" == "$PASSED" ]
	then 
	    echo "testcase$testcase passed"
	    let grade=${grade}+30
	else
	    echo "testcase$testcase failed, your output did not match with the answer"
	fi
    fi
done

overallGradeLetter $grade
exit 0
 

