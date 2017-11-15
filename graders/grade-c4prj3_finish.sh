export PokerProjectStep=403
echo "Running 'make clean' to do a clean build of your project"
make clean
echo "Running 'make poker OTHERFLAGS=-O3' to build your project"
make poker OTHERFLAGS=-O3 2>&1
if [ "$?" != 0 ]
then
    echo "make failed"
    overallGradeLetter 0
    exit 0
fi
if [ ! -x "poker" ]
then
    echo "make reported success, but I can't find a program called 'poker'"
    overallGradeLetter 0
    exit 0
fi
loadRefImpl /dev/fd/4
total=0
correct=0
run_test (){
    inp="$1"
    numHands="$2"
    expTotal="$3"
    timeout="$4"
    echo "Running a simulation with $expTotal draws for $numHands hands..." >&2

    let total=${total}+1
    timeout -s 9 $timeout valgrind --log-file=vg.log ./poker ${inp} ${expTotal} > theirs.out 6</dev/null 7</dev/null 8</dev/null 9</dev/null 10</dev/null 11</dev/null 12</dev/null 13</dev/null
    x="$?"
    if [ "$x" == "124" ]
    then
	echo " - Your program seems to have taken too long (infinite loop?)"
    else
	valgrindErrorCheck
	if [ "$?" == "$FAILED" ]
	then
	    echo "Valgrind reported errors:"
	    cat vg.log
	else
	    unset PokerProjectStep
	    runRefImpl $inp ${expTotal} > ours.out
	    export PokerProjectStep=403
	    hnum=0
	    theirTotal=0
	    allok=1
	    while [ "$hnum" -lt "$numHands" ]
	    do
		#Hand 0 won 5533 / 10000 times (55.33%)
		#Hand 1 won 4467 / 10000 times (44.67%)
		#And there were 0 ties
		thdata=`grep "Hand $hnum" theirs.out`
		ohdata=`grep "Hand $hnum" ours.out`
		theirNum=`echo $thdata | sed 's/Hand.*won[^0-9]*\([0-9]\+\).*\/.*/\1/'`
		theirPct=`echo $thdata | sed 's/^[A-Za-z0-9 /]*(//' | sed 's/%).*//'`
		ourPct=`echo $ohdata | sed 's/^[A-Za-z0-9 /]*(//' | sed 's/%).*//'`
		let theirTotal=${theirTotal}+theirNum
		echo "delta=echo "scale=4; ${ourPct}-${theirPct}" | bc" >&2
		echo "ok=echo "scale=4; $delta<=0.5 && $delta>=-0.5" | bc" >&2
		delta=`echo "scale=4; ${ourPct}-${theirPct}" | bc`
		ok=`echo "scale=4; $delta<=0.5 && $delta>=-0.5" | bc`
		if [ "$ok" == "1" ]
		then
		    echo "Hand $hnum was close enough to our answer"
		else
		    echo "Hand $hnum differed from our answer by ${delta}%"
		    allok=0
		fi
		let hnum=${hnum}+1
		
	    done
	    theirTies=`grep "ties" theirs.out | sed 's/^[A-Za-z ]*\([0-9]\+\)[A-Za-z ]*/\1/'`
	    let theirTotal=${theirTotal}+theirTies
	    if [ "$theirTotal" == "$expTotal" ]
	    then
		if [ "$allok" == "1" ]
		then
		    echo "Test case passed!"
		    let correct=${correct}+1
		else
		    echo "Test case failed"
		fi
	    else
		echo "You dont seem to have the right total draws."
		echo "Yours sum to $theirTotal but I expected $expTotal"
	    fi
	fi
    fi
}
echo " - Starting with some Texas Hold'em hands"
cat /dev/fd/5 > inp.txt
run_test inp.txt 2 10000 5
cat /dev/fd/6 > inp.txt
run_test inp.txt 3 20000 10
cat /dev/fd/7 > inp2.txt
run_test inp2.txt 3 20000 10
cat /dev/fd/8 > inp2.txt
run_test inp2.txt 2 20000 10
cat /dev/fd/9 > inp3.txt
run_test inp3.txt 4 20000 12
cat /dev/fd/10 > inp.txt
run_test inp.txt 2 10000 5
cat /dev/fd/11 > inp.txt
echo " - Next, few Seven Card Stud hands"
run_test inp.txt 2 15000 7
cat /dev/fd/12 > inp2.txt
run_test inp.txt 3 20000 15
echo " - Then one from a completely made up poker variant"
cat /dev/fd/13 > whacky.txt
run_test whacky.txt 6 100000 30



let wrong=${total}-${correct}
let grade=100-15*${wrong}
if [ "$grade" -lt "0" ]
then
    grade=0
fi
overallGradeLetter $grade


    
