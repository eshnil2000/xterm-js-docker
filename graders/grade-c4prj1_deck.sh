export PokerProjectStep=401
echo "Compiling deck.c -> deck.o"
gcc -Wall -Werror -std=gnu99 -pedantic -c deck.c 2>&1
if [ "$?" != 0 ]
then
    echo "Compilation of deck.c failed"
    overallGradeLetter 0
    exit 0
fi
echo "Compiling eval.c -> eval.o"
gcc -Wall -Werror -std=gnu99 -pedantic -c eval.c 2>&1
if [ "$?" != 0 ]
then
    echo "Compilation of eval.c failed"
    overallGradeLetter 0
    exit 0
fi
echo "Compiling card.c -> card.o"
gcc -Wall -Werror -std=gnu99 -pedantic -c card.c 2>&1
if [ "$?" != 0 ]
then
    echo "Compilation of card.c failed"
    overallGradeLetter 0
    exit 0
fi

echo "Linking eval.o, deck.o, card.o, and our tester"
cat /dev/fd/4 > tester.o
gcc -o tester eval.o deck.o card.o tester.o 2>&1
if [ "$?" != 0 ]
then
    echo "Linking failed"
    overallGradeLetter 0
    exit 0
fi
total=0
correct=0
run_test (){
    arg="$1"
    let total=${total}+1
    timeout -s 9 5 valgrind --log-file=vg.log ./tester $arg 2>&1
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
	elif [ "$x" == "0" ]
	then
	    echo "- Test passed"
	    let correct=${correct}+1
	else
	    echo "- Test failed"
	fi
    fi
}

echo "Testing free_deck(deck_t *)"
run_test fd
echo "Testing add_card_to(deck_t *, card_t)"
run_test act
echo "Testing add_empty_card(deck_t *)"
run_test aec
echo "Testing make_deck_exclude(deck_t *)"
run_test mde
echo "Testing build_remaining_deck(deck_t **, size_t)"
run_test brd
echo "Testing get_match_count(deck_t *)"
run_test gmc


    
