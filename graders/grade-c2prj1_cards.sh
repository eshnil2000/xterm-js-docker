cat /dev/fd/6 > tester.o
do1test() {
    echo "$1"
    ./tester $2
    if [ "$?" == "0"  ]
    then
	echo "Passed"
    else
	echo "Failed"
	passFailGradeFromStatus $FAILED
	exit 0
    fi
}
echo "Compiling cards.c"
gcc -o tester -Wall -Werror -std=gnu99 -pedantic cards.c tester.o 2>&1
if [ "$?" != 0 ]
then
    echo "Could not compile your card.c!"
    passFailGradeFromStatus $FAILED
    exit 0
fi
# card_t card_from_letters(char value_let, char suit_let);
do1test "Testing card_from_letters" cfl 

# char value_letter(card_t c) ;
# char suit_letter(card_t c);
do1test "Testing value_letter and suit_letter" vlsl

echo "Testing print_card"
# void print_card(card_t c) ;
./tester pc > tmp.txt
if [ "$?" == "0"  ]
then
    diff -w /dev/fd/4 tmp.txt > /dev/null
    if [ "$?" == "0" ]
    then
	echo "Passed"
    else
	echo "Your print_card does not work the way I expect:"
	cat tmp.txt
	passFailGradeFromStatus $FAILED
	exit 0
    fi
else
    echo "Failed"
    passFailGradeFromStatus $FAILED
    exit 0
fi

# card_t card_from_num(unsigned c);
echo "Testing card_from_num"
./tester cfn > tmp.txt
if [ "$?" == "0"  ]
then
    sort tmp.txt > tmp2.txt
    sort /dev/fd/5 > tmp3.txt
    diff -w tmp3.txt tmp2.txt > /dev/null
    if [ "$?" == "0" ]
    then
	echo "Passed"
    else
	echo "When I use card_from_num on numbers 0<= i < 52"
	echo "I expect to see each card exactly once, but I see:"
	cat tmp.txt
	passFailGradeFromStatus $FAILED
	exit 0
    fi
else
    echo "Failed"
    passFailGradeFromStatus $FAILED
    exit 0
fi
    

# const char * ranking_to_string(hand_ranking_t r) ;
do1test "Testing ranking_to_string" rts

# void assert_card_valid(card_t c);
do1test "Testing assert_card_valid" acv


passFailGradeFromStatus $PASSED
