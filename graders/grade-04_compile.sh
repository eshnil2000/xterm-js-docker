checkFileExists hello.c
if [ "$?" != "$PASSED" ]
then
    echo "Cannot proceed without hello.c"
    passFailGradeFromStatus $FAILED
    exit 0
fi

echo "Compiling your code"
gcc -o hello -Wall -Werror -pedantic -std=gnu99 hello.c 2>&1
if [ "$?" != 0 ]
then
    echo "Your code did not compile"
    passFailGradeFromStatus $FAILED
    exit 0
fi
echo "Checking if your program prints \"Hello World\""
echo "Hello World" > hello.txt
./hello | diffFile /dev/stdin hello.txt 
passFailGradeFromStatus $?




