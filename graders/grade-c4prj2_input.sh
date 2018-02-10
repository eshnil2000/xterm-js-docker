export PokerProjectStep=402
compile() {
    fname="$1"
    echo "Compiling ${fname}.c -> ${fname}.o"
    gcc -Wall -Werror -std=gnu99 -pedantic -c ${fname}.c 2>&1
    if [ "$?" != 0 ]
    then
	echo "Compilation of ${fname}.c failed"
	overallGradeLetter 0
	exit 0
    fi
}
compile "cards"
compile "deck"
compile "input"
compile "future"
echo "Linking input.o, future.o deck.o, cards.o, and our tester"
cat /dev/fd/4 > test-input.o
loadRefImpl /dev/fd/5
gcc -o tester input.o future.o deck.o cards.o test-input.o 2>&1
if [ "$?" != 0 ]
then
    echo "Linking failed"
    overallGradeLetter 0
    exit 0
fi
total=0
correct=0
run_test (){
    hand="$1"
    draw="$2"
    let total=${total}+1
    timeout -s 9 5 valgrind --log-file=vg.log ./tester $hand $draw > theirs.out 6</dev/null 7</dev/null 8</dev/null 9</dev/null 10</dev/null 11</dev/null 12</dev/null
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
	    runRefImpl $hand $draw > ours.out
	    diffFile theirs.out ours.out
	    if [ "$?" == "$PASSED" ]
	    then
		echo "Test case passed"
		let correct=${correct}+1
	    else
		echo "Test case failed"
	    fi
	    export PokerProjectStep=402
	fi
    fi
}

cat /dev/fd/6 > hands.txt
cat /dev/fd/7 > draw.txt
echo "Testing with input file with "
echo " o 1 hand"
echo " o No unknown/future cards"
run_test hands.txt draw.txt
echo "Testing with input file with "
echo " o Many hands"
echo " o No unknown/future cards"
cat /dev/fd/8 > hands.txt
run_test  hands.txt draw.txt

echo "Testing with input file with "
echo " o Many hands"
echo " o 1 unknown/future cards per hand"
cat /dev/fd/9 > h.txt
cat /dev/fd/10 > d.txt
run_test  h.txt d.txt

echo "Testing with input file with "
echo " o Many hands"
echo " o Many unknown/future cards per hand"
cat /dev/fd/11 > i1
cat /dev/fd/12 > i2
run_test  i1 i2


let wrong=${total}-${correct}
let grade=100-15*${wrong}
if [ "$grade" -lt "0" ]
then
    grade=0
fi
overallGradeLetter $grade


    
