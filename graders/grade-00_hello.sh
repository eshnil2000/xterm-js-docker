sfile="hello.txt"
echo "hello" | diffFile $sfile /dev/stdin 
passFailGradeFromStatus $?

