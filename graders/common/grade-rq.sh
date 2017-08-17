# 3 (script)
# 4 (expected)

if [ -f "answers.txt" ]
then
  echo "Reading your quiz answers from answers.txt"
else
  echo "You do not seem to have a file called answers.txt. Here is what I see:"
  ls
  overallGrade "FAILED"
  exit
fi

cat answers.txt | sed 's/^[^A-Za-z]*\([A-Za-z]\).*/\1/' | tr [:lower:] [:upper:] | sed '/^$/d' > temp.txt

cat /dev/fd/4 > ans.txt
anslines=`wc -l ans.txt | cut -f1 -d" "`
theirlines=`wc -l temp.txt | cut -f1 -d" "`

if [ "$anslines" != "$theirlines" ]
then
    echo "Your answer file has $theirlines answers, but I expected $anslines"
    overallGrade "FAILED"
else
    wrong=`countLinesDiff temp.txt ans.txt`
    if [ "$wrong" == "0" ] 
    then
        echo "Your quiz answers are correct"
        overallGrade "PASSED"
    else
        if [ "$wrong" == "1" ]
        then
            echo "You have 1 wrong answer"
        else
            echo "You have ${wrong} wrong answers"
        fi
        overallGrade "FAILED"
    fi
fi
