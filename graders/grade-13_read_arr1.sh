#fd 4 our output
#fd 5 our test code

grade=0
rm test > /dev/null
cat /dev/fd/5 > test.c
echo "Attempting to compile test.c"
make
if [ "$?" != "$PASSED" ]
then 
		echo "The code did not compile"
else
		echo "compiled"
		let grade=${grade}+50
fi

diffFile answer.txt /dev/fd/4
if [ "$?" != "$PASSED" ]
then
    echo "Your output did not match what we expected."
else 
    echo "Your output matched what we expected"
    let grade=${grade}+50
fi

if [ $grade -eq 100 ]
then 
		overallGradeLetter $grade
else
		overallGradeLetter $grade
fi
exit 0
