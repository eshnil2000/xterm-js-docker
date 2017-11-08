diffFile answer.txt /dev/fd/4
if [ "$?" != "$PASSED" ]
then
    echo "Your output did not match what we expected."
    overallGradeLetter 0
else 
    echo "Your output matched what we expected"
    overallGradeLetter 100
fi
exit 0
