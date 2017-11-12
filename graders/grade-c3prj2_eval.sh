export PokerProjectStep=302
echo "Compiling your code"
make clean
make test-eval
if [ "$?" != 0 ]
then
    echo "'make test-eval' failed."
    overallGradeLetter 0
    exit 0
fi
if [ ! -x ./test-eval ]
then
    echo "'make test-eval' failed to produce test-eval"
    overallGradeLetter 0
    exit 0
fi
    
loadRefImpl /dev/fd/14

grade=0
ppt=10
testcase=0
runTest() {
    let testcase=${testcase}+1
    echo "Testcase ${testcase}: $1"
    cat /dev/fd/${2} > inp.${testcase}.txt
    timeout -s 9 8 valgrind --log-file=vg.log ./test-eval inp.${testcase}.txt > theirs.${testcase}.txt
    if [ "$?" == "124" ]
    then
	echo "Your program took too long.  We suspect an infinite loop"
	return $FAILED
    fi
    valgrindErrorCheck 
    if [ "$?" != "$PASSED" ]
    then
	echo "Valgrind returned an error status"
	cat vg.log
	return $FAILED
    fi
    export PokerProjectStep=0
    runRefImpl inp.${testcase}.txt > ours.${testcase}.txt
    export PokerProjectStep=302
    echo " Checking the output "
    diffFile theirs.${testcase}.txt > ours.${testcase}.txt
    if [ "$?" == "$PASSED" ]
    then
	echo " - Testcase passed"
	let grade=${grade}+${ppt}
	return $PASSED
    else
	echo " - Output did not match, testcase failed"
	echo "Here is what I got"
	cat ours.${testcase}.txt
	echo "Here is what the student got"
	cat theirs.${testcase}.txt
	return $FAILED
    fi
    
}


runTest "Trying hands with nothing" 4
runTest "Trying hands with pairs" 5
runTest "Trying hands with 2 pairs" 6
runTest "Trying hands with 3 of a kind" 7
runTest "Trying hands with straights" 8 
runTest "Trying hands with flushes" 9
runTest "Trying hands with full houses" 10 
runTest "Trying hands with 4 of a kind" 11
runTest "Trying hands with straight flushes" 12
runTest "Trying each type of hand ranking" 13

overallGradeLetter $grade
