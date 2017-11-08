# 3: script
# 4: expected output for their function
# 5: test main
# 6: reference implementation

#loadRefImp is used to load our ./power_answer to bash variable 
loadRefImpl /dev/fd/6

cat /dev/fd/5 > pmain.c

#does the code compile?
echo "Attempting to compile power.c"
gcc -c -pedantic -Wall -Werror -std=gnu99 power.c -o power.o 2>&1
if [ "$?" != "0" ]
then
 echo "The code did not compile!"
 overallGradeLetter 0
 exit 0
fi
echo "Attempting to compile power.o with our main"
gcc -o power2 power.o pmain.c
if [ "$?" != "0" ]
then
 echo "The code did not compile! (did you leave your own main in there??)"
 overallGradeLetter 0
 exit 0
fi

#clang-query check
ALLclangLocsFound="YES"
echo "Checking for unsigned power (unsigned x, unsigned y)"
clangMatchFindFunDecWith "power.c" "power" "unsigned-int" "unsigned-int:x" "unsigned-int:y"
reportClangLoc
echo "Checking for no iteration (do, while, for)"
clangCheckNoIteration "power.c"
echo "Checking that power is recursive"
clangFindRecusiveFunction "power.c" "power"
if [ "$ALLclangLocsFound" != "YES" ]
then
    echo "Your code does not have the right functions."
    overallGradeLetter 10
    exit 0
fi
#replace with our main
total=0
correct=0
for x in 0 1 4 5 9 12
do
    for y in 0 1 2 6 8 11
    do
	
	timeout -s 9 5 ./power2 $x $y 3</dev/null 4< /dev/null 5</dev/null 6</dev/null > temp.txt
	runRefImpl $x $y > correct.txt
	diffFile temp.txt correct.txt > /dev/null
	if [ "$?" = "$PASSED" ]
	then 
	    
	    echo "${x}^${y} was Correct"
	    let correct=${correct}+1
	else 
	    echo "${x}^${y} was Incorrect"
	fi
	let total=${total}+1
	done
done
if [ ${total} == ${correct} ]
then
    grade=100
else
    let grade="${correct}*75/${total}+10"
fi
overallGradeLetter $grade
exit 0

