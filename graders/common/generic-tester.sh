#!/bin/bash
# 3: (script)
# 4: command to generate invocations:  pts-novg:pts-vg:vgty:timelimit:arvg1 argv2 argv3 ...
#     - vgty should be skip, none, or full
#     - this is a program which prints them one per line
# 5:  reference implementation (executable, with our main)
loadGenProg /dev/fd/4
loadRefImpl /dev/fd/5
exec 4<&-
exec 5<&-
# get rid fo any executables
for exe in `find $SDIR -executable  -type f -maxdepth 1` 
do
    echo "**Deleting executable file ${exe}"
    rm -f ${exe}
done

# does the code compile?
echo "Attempting to compile with make"
make
if [ "$?" != "0" ]
then
 echo "The code did not compile!"
 overallGrade 0
 exit 0
fi
# find the executable
executable=""
for exe in `find $SDIR -executable  -type f -maxdepth 1` 
do
    if [ "$executable" == "" ]
	then
	executable="$exe"
    else
	echo "make produced multiple executables ($exe and $executable)"
	overallGrade 0
	exit 0
    fi
done

oldIFS=$IFS
IFS=$'\n' 
total=0
for  i in `runRefImpl`
do
    IFS=$oldIFS
    ptsnvg=`echo $i | cut -f1 -d ':'`
    ptsvg=`echo $i | cut -f2 -d ':'`
    thistestearned="0"
    let thistestmax=${ptsnvg}+${ptsvg}
    vgty=`echo $i | cut -f3 -d ':'`
    case $vgty in
	"full") 
	    vg="valgrind --leak-check=full "
	    vga="--log-file=vg.log "
	    ;;
	"none")
	    vg="valgrind "
	    vga="--leak-check=none --log-file=vg.log "
	    ;;
	*)
	    vg=""
	    vga=""
	    vgty="skip"  # ensure no bogus inputs
	    ;;
    esac
    timelimit=`echo $i | cut -f4 -d ':'`
    cmd=`echo $i | cut -f5- -d ':'`
    echo "Running ${vg}${vga}$executable $cmd"
    timeout -s 9 ${timelimit}  $vg $vga "$executable" $cmd 3</dev/null > theirs.out 2>theirs.err
    result="$?"
    if [ "$result" = 124 ] || [ "$result" = 137 ]
    then 
	echo " - This execution was terminated after ${timelimt} seconds."
	echo "   This likely means that your program has an infinite loop."
	echo "   If you do not think this is the case, please talk to one of the TAs."
        elif [ "$result" = 139 ]
    then
	echo " - Your program segfaulted."
    else
	runRefImpl $cmd > ours.out 2>ours.err
	ourres="$?"
	# we need to check 4 things:
	#  - exit status
	checkExit $result $ourres
	if [ "$?" == "$PASSED" ]
	    then
	    #  - output
	    diffFile theirs.out ours.out 
	    if [ "$?" != "$PASSED" ]
	    then
		echo " - The output matches"
		let thistestearned=${thistestearned}+${ptsnvg}
	    fi
	fi
	if [ "$vgty" != "skip" ]
	then
	    #  - valgrind errors [iff $vgty != "skip"] 
	    grep 0.errors.from.0.contexts vg.log > /dev/null
	    if [ "$?" == "0" ]
	    then
		if [ "$vgty" == "full" ]
		then
		    #  - valgrind leaks [iff $vgty == "full"]
		    grep All.heap.blocks.were.freed.--.no.leaks.are.possible vg.log  > /dev/null
		    if [ "$?" == "0" ]
		    then 
			echo "  - Valgrind was clean (no errors, no memory leaks)"
			let thistestearned=${thistestearned}+${ptsvg}
		    else
			echo "  - Valgrind showed memory leaks"
			cat vg.log
		    fi
		else
		    echo "  - Valgrind was clean (no errors)"
		    let thistestearned=${thistestearned}+${ptsvg}
		fi
	    else
		echo " - Valgrind reported errors"
		cat vg.log
	    fi
	fi
    fi
    echo " - Points earned this test: ${thistestearned} / ${thistestmax}"
    let total=${total}+${thistestearned}
done
overallGrade $total


