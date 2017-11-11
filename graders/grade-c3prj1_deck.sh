export PokerProjectStep=301
cat /dev/fd/4 > grade-deck.o
echo "Compiling deck.c"
gcc -O3 -c -Wall -Werror -std=gnu99 -pedantic deck.c 2>&1
if [ "$?" != 0 ]
then
    echo "Could not compile your deck.c!"
    passFailGradeFromStatus $FAILED
    exit 0
fi
echo "Compiling cards.c"
gcc -O3 -c -Wall -Werror -std=gnu99 -pedantic cards.c 2>&1
if [ "$?" != 0 ]
then
    echo "Could not compile your cards.c!"
    passFailGradeFromStatus $FAILED
    exit 0
fi
echo "Linking cards.o deck.o deck-c4.o and the grader's .o file"
gcc -O3 -o tester -Wall -Werror -std=gnu99 -pedantic cards.o deck.o deck-c4.o grade-deck.o 2>&1
if [ "$?" != 0 ]
then
    echo "Could not link your code!"
    passFailGradeFromStatus $FAILED
    exit 0
fi

#echo ""
echo "Running your code (this might take a minute: doing many shuffles...)" >&2
echo "....." >&2

timeout -s 9 45 valgrind --log-file=vg.log ./tester > out.1 4</dev/null 5</dev/null
if [ "$?" == "124" ]
then
    echo "Your code took long enough (>45 seconds) that we suspect"
    echo "an infinite loop"
    passFailGradeFromStatus $FAILED
    exit 0
else
    valgrindErrorCheck
    if [ "$?" == $FAILED ]
    then
	echo "valgrind reported memory errors"
	passFailGradeFromStatus $FAILED
	exit 0
    fi
fi


rinfo=`grep ShuffleRandom: out.1`
grep -v ShuffleRandom: out.1 > out.2
cat /dev/fd/5 > ours.out
echo "Checking the output of all the functions other than shuffle"
diffFile out.2 ours.out
if [ "$?" == "$PASSED" ]
then 
    echo " - Those functions seem to work!"
    grade=50
else
    echo " - Those functions seem to have problems"
    grade=0
fi
echo "Checking your shuffle results with a 6 card hand..."
#ShuffleRandom:%lf:%lf:A
minp=`echo $rinfo | cut -f2 -d":"`
maxp=`echo $rinfo | cut -f3 -d":"`
echo "  Least common hand: ${minp}%"
echo "  Most  common hand: ${maxp}%"
echo "  Perfectly even is: 0.138888%"
goodness=`echo $rinfo | cut -f4 -d":"`
case $goodness in
    A)
	echo " Excellent!"
	let grade=$grade+50
	;;
    B)
	echo " Pretty good!"
	let grade=$grade+35
	;;
    C)
	echo " That isn't too bad, but could you do better?"
	let grade=$grade+25
	;;
    *)
	echo " That doesn't seem terribly uniform."
	echo " Try to improve your shuffling algorithm and re-grade"
esac
overallGradeLetter $grade
