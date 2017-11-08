# 3: (script)
# 4: expected output for their main
# 5: our main (c file)
# 6: reference implementation (executable, with our main)

loadRefImpl /dev/fd/6

# does the code compile?
echo "Attempting to compile retirement.c"
gcc -pedantic -Wall -Werror -std=gnu99 retirement.c -o retirement 2>&1
if [ "$?" != "0" ]
then
 echo "The code did not compile!"
 overallGradeLetter 0
 exit 0
fi
# start with some clang-query to check for things
ALLclangLocsFound="YES"
echo "Checking for struct _retire_info"
clangMatchFindStruct "retirement.c" "_retire_info"
reportClangLoc
echo "Checking for field int months"
clangMatchStructWithField "retirement.c" "_retire_info" "months" "int"
reportClangLoc
echo "Checking for field double contribution"
clangMatchStructWithField "retirement.c" "_retire_info" "contribution" "double"
reportClangLoc
echo "Checking for field double rate_of_return"
clangMatchStructWithField "retirement.c" "_retire_info" "rate_of_return" "double"
reportClangLoc
echo "Checking for typedef of struct _retire_info to retire_info"
clangCheckTypeDef "retirement.c" "retire_info" "struct _retire_info"
reportClangLoc
echo "Checking for void retirement (int startAge, double initial,  retire_info working,  retire_info retired)"
clangMatchFindFunDecWith "retirement.c" "retirement" "void" "int:startAge" "double:initial" "retire_info:working" "retire_info:retired"
reportClangLoc
echo "Checking for int main(void)"
clangMatchFindFunDecWith "retirement.c" "main" "int" 
reportClangLoc
if [ "$ALLclangLocsFound" != "YES" ]
then
    echo "Your code does not have the right struct, fields, and/or functions."
    overallGradeLetter 10
    exit 0
fi
echo "Trying to run retirement calculator.."
timeout -s 9 5 ./retirement 3</dev/null 4< /dev/null 5</dev/null 6</dev/null > temp.txt
diffFile  temp.txt /dev/fd/4
if [ "$?" != "$PASSED" ]
then
    echo "Your output did not match what we expected. Here is what you printed"
    cat temp.txt
    overallGradeLetter 20
    exit 0
fi
echo "Removing your main() and replacing it with our own to run more tests..."
#match decl(hasParent(translationUnitDecl()), unless(functionDecl(hasName("main"))))
clangStripFn "retirement.c" "main" "int" > temp.c
cat temp.c /dev/fd/5 > temp2.c
gcc -pedantic -Wall -Werror -std=gnu99 temp2.c -o retirement2 2>&1
if [ "$?" != "0" ]
then
  echo "Could not replace your main function to test further"
  overallGradeLetter 75
  exit 0
fi

all=0
correct=0
echo "                |         Working              |        Retired         "
echo " Age | Initial  | Saving  |   Rate    | Months | Spending |   Rate    | Months | Result" 
for startAge in 240 345 
 do
    let iniD=${RANDOM}%10000+5600
    let randomCents=${RANDOM}%100
    iniC=`printf "%02d" $randomCents`
    for initial in 0.0  ${iniD}.${iniC}
    do
        let ws=${RANDOM}%1500+2345
	for workSave in 1234 ${ws}
	do
	    for workRor in 0.00267 0.00567
	    do
		let wm=${RANDOM}%30+585
		for workMonths in 597  ${wm}
		do
		    for retireSpend in -3567 -6534
		    do
			let ror1=${RANDOM}%100
			ror1x=`printf "%02d" $ror1`
			let ror2=${RANDOM}%100
			ror2x=`printf "%02d" $ror2`
			for retireRor in 0.000${ror1x} 0.004${ror2x}
			do
			    let rm1=${RANDOM}%30+204
			    let rm2=${RANDOM}%40+370
			    for retireMonths in ${rm1} ${rm2}
			    do
				printf " %3d | %8.2f | %7.2f | %8.7f |   %3d  | %7.2f | %8.7f |   %3d  | " "$startAge" "$initial" "$workSave" "$workRor" "$workMonths" "$retireSpend" "$retireRor" "$retireMonths"
				# echo "Testing with"
				# echo "  startAge               $startAge"
				# echo "  initial                $initial"
				# echo "  working.contribution   $workSave"
				# echo "  working.rate_of_return $workRor"
				# echo "  working.months         $workMonths"
				# echo "  retired.contribution   $retireSpend"
				# echo "  retired.rate_of_return $retireRor"
				# echo "  retired.months         $retireMonths"
				timeout -s 9 5 ./retirement2  $startAge $initial $workSave $workRor $workMonths $retireSpend $retireRor $retireMonths 3</dev/null 4< /dev/null 5</dev/null 6</dev/null > temp.txt				
				runRefImpl  $startAge $initial $workSave $workRor $workMonths $retireSpend $retireRor $retireMonths  > correct.txt
				#diffFile temp.txt correct.txt > /dev/null
				#use awk to compare two files. the range is set to be [correct-0.5,correct+0.5]
				cat temp.txt | sed 's/^.*\$//' > file1
				cat correct.txt | sed 's/^.*\$//' > file2
				paste file1 file2 | awk '$1<$2-0.05 && $1>$2+0.05{exit 1}'
				if [ "$?" = "$PASSED" ]
				then
				    echo "Correct"
				    let correct=${correct}+1
				else
				    echo "Incorrect"
				fi
				let all=${all}+1
			    done
			done
		    done
		done
	    done
	done
    done
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
