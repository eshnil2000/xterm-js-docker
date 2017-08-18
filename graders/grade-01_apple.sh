sfile="fruit.txt"
echo "apple" | diffFile $sfile /dev/stdin 
passFailGradeFromStatus $?

