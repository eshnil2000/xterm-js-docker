# 3: (script)
# 4: expected output for their main
# 5: our main (c file)
# 6: reference implementation (executable, with our main)

loadRefImpl /dev/fd/6

# does the code compile?
echo "Checking code2.c for legal syntax"
cat > temp.c <<EOF
#include <stdio.h>
#include <stdlib.h>
EOF
cat code2.c >> temp.c
gcc -pedantic -Wall -Werror -std=gnu99 temp.c -o code2 2>&1
if [ "$?" != "0" ]
then
 echo "The code did not have legal syntax!"
 overallGradeLetter 0
 exit 0
fi
# start with some clang-query to check for things
ALLclangLocsFound="YES"
echo "Checking for int printTriangle (int size)"
clangMatchFindFunDecWith "temp.c" "printTriangle" "int" "int:size" 
reportClangLoc
echo "Checking for int main(void)"
clangMatchFindFunDecWith "temp.c" "main" "int" 
reportClangLoc
if [ "$ALLclangLocsFound" != "YES" ]
then
    echo "You seem to have removed the functions we gave you!"
    overallGradeLetter 0
    exit 0
fi
echo "Trying to run the code.."
timeout -s 9 5 ./code2 3</dev/null 4< /dev/null 5</dev/null 6</dev/null > temp.txt
diffFile  temp.txt /dev/fd/4
if [ "$?" != "$PASSED" ]
then
    echo "Here is what you printed"
    cat temp.txt
    overallGradeLetter 10
    exit 0
fi
echo "Removing your main() and replacing it with our own to run more tests..."
#match decl(hasParent(translationUnitDecl()), unless(functionDecl(hasName("main"))))
clangStripFn "temp.c" "main" "int" > temp2.c
cat temp2.c /dev/fd/5 >> temp3.c
#cat temp3.c
gcc -pedantic -Wall -Werror -std=gnu99 temp3.c -o code2x 2>&1
if [ "$?" != "0" ]
then
  echo "Could not replace your main function to test further"
  overallGradeLetter 50
  exit 0
fi

all=0
correct=0
let r1=${RANDOM}%10+${RANDOM}%100+45
let r2=${RANDOM}%100+${RANDOM}%100+55
let r3=${RANDOM}%200+${RANDOM}%2000+65
let r4=${RANDOM}%250+2300
for num1 in 0 1 2 3 4 7 9 12 $r1 $r2 $r3 $r4
do
    echo -n "Testing printTriangle(${num1}) ... "
    timeout -s 9 5 ./code2x  $num1 3</dev/null 4< /dev/null 5</dev/null 6</dev/null > temp.txt				
    runRefImpl $num1 > correct.txt
    diffFile temp.txt correct.txt > /dev/null 
    if [ "$?" = "$PASSED" ]
    then
	echo "Correct"
	let correct=${correct}+1
    else
	echo "Incorrect"
    fi
    let all=${all}+1
done
if [ "$correct" = "$all" ]
    then
    overallGradeLetter 100
    exit 0
else 
 let x=75+${correct}*15/${all}
 if [ "$x" -gt 90 ]
 then
     x="90"
 fi
 overallGradeLetter $x
 exit 0
fi
