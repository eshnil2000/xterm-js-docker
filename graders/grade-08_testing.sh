#4:22_testing_broken1 
#5:22_testing_broken2 
#6:22_testing_broken3 
#7:22_testing_broken4 

grade=0
fd_link=("/dev/fd/4" "/dev/fd/5" "/dev/fd/6" "/dev/fd/7")
student_input=("input.1" "input.2" "input.3" "input.4")
input=("1" "101" "s" "-1")

for ((i=0;i<4;++i))
do
		echo "#################################################"
		echo "test ${student_input[$i]}:"
		checkFileExists ${student_input[$i]}
		if [ "$?" ==  $FAILED ]
		then
				continue
		else
				loadRefImpl ${fd_link[$i]}
				runRefImpl `cat ${student_input[$i]}`  > student.txt
				runRefImpl ${input[$i]}  > correct.txt
				diffFile student.txt correct.txt
				if [ "$?" = "$PASSED" ]
				then 
						echo "${student_input[$i]} passed"
						let grade=${grade}+25
				else
						echo "${student_input[$i]} failed, your output did not match with the answer"
				fi	
		fi
done		

case $grade in
		25)
				overallGrade "D"
				;;
		50)
				overallGrade "C"
				;;
		75) 
				overallGrade "B"
				;;
		100)
				overallGrade "A"
				;;
		*)
				overallGrade "F"
				;;
esac

exit 0
