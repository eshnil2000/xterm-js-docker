#!/bin/bash
ulimit -f 25000
CLANGBIN=/usr/local/clang/bin
FAILED="1"
PASSED="0"
expected="/home/ece551db/graderbase/graders/expected"
defaultDiffOpts="-Biw --suppress-common-lines --old-line-format=Line_%dn_did_not_match%c'\012' --new-line-format= --unchanged-line-format= "
REPORT_DETAILED_DIFF=0
RUNTIMEOUT=30
SHORTDIFFOPTS="-iwy"
TIMELIMIT=5
SHAOK=1
#check for segfault and infinite loop
checkExitStatus() {
		result="$1"
		if [ "$result" = 124 ] || [ "$result" = 137 ]
		then 
				echo " - This execution was terminated after ${TIMELIMIT} seconds."
				echo "   This likely means that your program has an infinite loop."
				echo "   If you do not think this is the case, please talk to one of the TAs."
				return $FAILED
		elif [ "$result" = 139 ]
		then
				echo " - Your program segfaulted."
				return $FAILED
		elif [ "$result" = 134 ]
		then
				echo "double free or corruption"
				return $FAILED
		fi
}

valgrindErrorCheck() {
		grep 0.errors.from.0.contexts vg.log > /dev/null
		if [ "$?" == "0" ]
		then
				return $PASSED
		else
				return $FAILED
		fi		
}

valgrindCheck() {
		grep 0.errors.from.0.contexts vg.log > /dev/null
		if [ "$?" == "0" ]
		then
				grep All.heap.blocks.were.freed.--.no.leaks.are.possible vg.log  > /dev/null
				if [ "$?" == "0" ]
				then 
						echo "  - Valgrind was clean (no errors, no memory leaks)"	
						return $PASSED
				else
						echo "  - Valgrind showed memory leaks"
						#cat vg.log
						return $FAILED
				fi
		else
				echo "  - Valgrind reported errors"
				#cat vg.log
				return $FAILED
		fi
}


checkFileNotEmpty() {
    _file="$1"
    [ $# -eq 0 ] && { echo "Usage: $0 filename"; exit 1; }
    [ ! -f "$_file" ] && { echo "Error: $0 file not found."; exit 2; }

    if [ -s "$_file" ]
    then
        return $PASSED
        #echo "$_file has content"                                                                                             
    else
        return $FAILED
        #echo "$_file is empty."                                                                                               
    fi
}
# check whether program return exit_failure and print into stderr when errors occur
errorHandlerCheck() {
    if [ $# -eq 1 ]
    then
        ./$1 > ./$1.stdout 2> ./$1.stderr
    else
        ./$1 ${@:2} > ./$1.stdout 2> ./$1.stderr
    fi
    if [ "$?" != "1" ]
    then
        return $FAILED
    fi
    checkFileNotEmpty $1.stderr
    if [ "$?" == "0" ]
    then
        return $PASSED
    else
        return $FAILED
    fi
}


checkFileExists() {
 if [ -f "$1" ] 
 then
     if [ -r "$1" ]
     then
				 return $PASSED
     else
				 echo "$1 exists, but is not readable"
				 ls -l $1
     fi
 else
     echo "I expected to find a file called '$1' but it did not exist"
     echo "(or was not a regular file)"
     echo "Here are the files that I can find:"
     ls
 fi
 return $FAILED
}
diffFile() {
 student="$1"
 ours="$2"
 if [ "$3" == "" ]
 then
     diffOpts="$defaultDiffOpts"
 else
     diffOpts="$3"
 fi
 if [ "$student" != "/dev/stdin" ]
 then
     checkFileExists $student
     if [ $? == $FAILED ]
     then 
	 return $FAILED
     fi
 fi
# /home/ece551db/graderbase/graders/common/prArgs $diffOpts
 diff $diffOpts $student $ours 2>&1
 temp="$?"
 case $temp in
     0) echo "Your file matched the expected output"
	 return $PASSED
	 ;;
     1) echo "Your file did not match the expected ouput"
	 ;;
     2) echo "Could not compare your output to the expected output "
	 echo "(explaination should be above)"
	 ;;
 esac
 return $FAILED
}
passFailGradeFromStatus() {
    if [ "$1" == "$PASSED" ]
	then
	overallGrade "PASSED"
	else
	overallGrade "FAILED"
    fi
}
overallGradeLetter () {
		grade=$1
		if [ $grade -eq 100 ] 
		then overallGrade "A"		
		elif [ $grade -ge 85 -a $grade -lt 100 ]
		then overallGrade "B"
		elif [ $grade -ge 70 -a $grade -lt 85 ]
		then overallGrade "C"
		elif [ $grade -ge 60 -a $grade -lt 70 ]
		then overallGrade "D"
		else
				overallGrade "F"
		fi
}

overallGrade () {
    echo ""
    echo "Overall Grade: $1"
}
checkProgVsRef() {
    theirs="$1"
    shift
    #    echo "Theirs is $theirs"
    ours="$1"
    #echo "ours is $ours"
    shift
    #echo "args are $@"
    #args is $@
    theirout=`mktemp theirs.XXXXX`
    #echo "    timeout --signal=9 $RUNTIMEOUT $theirs $@ > $theirout"
    timeout --signal=9 $RUNTIMEOUT $theirs $@ > $theirout
    x="$?"
    if [ "$x" == "137" ]
	then
	echo "Your program took longer than $RUNTIMEOUT seconds. "
	echo "This probably indicates an infinite loop."
	rm -f $theirout
	return $FAILED
    elif [ "$x" != "0" ]
	then
	echo "Running your code indicated failure"
	rm -f $theirout
	return $FAILED
    fi
    ourout=`mktemp ours.XXXXX`
    if [ "$ours" == "-" ]
    then
	runRefImpl $@ > $ourout
    else 
	$ours $@ > $ourout
    fi
#    echo "$ours $@ > $ourout"
    diffout=`mktemp diff.XXXX`
    diff $SHORTDIFFOPTS $ourout $theirout > $diffout
    x="$?"
    #cat $diffout
    case $x in
     0) echo "PASSED"
	answer=$PASSED
	;;
     1)  answer=$FAILED
	 echo "Your program produced the wrong output!"
	 if [ $REPORT_DETAILED_DIFF == "1" ]
	     then
	     echo "Here are the differences:"
	     cat $diffout
	     fi
	 ;;
     2) echo "Could not compare your output to the expected output "
	 echo "(explaination should be above)"
	 answer=$FAILED
	 ;;
     esac
 
    rm -f $theirout $ourout $diffout
    return $answer
}
clangStripFn() {
    cat $1 | sed s/$2/_old_removed_${2}_/g
    # filename="$1"
    # shift
    # funname="$1"
    # shift
    # returnType="$1"
    # shift
    # query="functionDecl(hasName(\"$funname\"), returns(asString(\"$returnType\")) "
    # pcount=0
    # argStr=""
    # for argDec in $@
    # do
    #    ty=`echo $argDec | cut -f1 -d":"`
    #    if [ "$ty" = "$argDec" ]
    #    then 
    # 	   # just type
    # 	   thisArg="hasParameter($pcount,hasType(asString(\"$ty\")))"
    #    else
    # 	   nm=`echo $argDec | cut -f2 -d":"`
    # 	   thisArg="hasParameter($pcount,parmVarDecl(hasName(\"$nm\"), hasType(asString(\"$ty\"))))"
    #    fi
    #    let pcount=${pcount}+1
    #    argStr="${argStr},${thisArg}"
    # done
    # query="${query}, parameterCountIs(${pcount}) $argStr )"
    # cmd="match decl(hasParent(translationUnitDecl()), unless(${query}))"
    # echo "$cmd"
    # ${CLANGBIN}/clang-query -c "set output print" -c "match $2" $1 -- | egrep -v "^Match #[0-9]+:\$" | grep -v "^Binding for \"root\":\$"  |egrep -v "^[0-9]+ matches.\$"

}

reportClangLoc() {
 if [ "$CLANGLOC" == "NONE" ]
 then 
     ALLclangLocsFound="NO"
     echo "not found"
 else
     line=`echo $CLANGLOC |cut -f1 -d":"`
     column=`echo $CLANGLOC | cut -f2 -d":"`
     echo "Found on line ${line}, column ${column} "
 fi
}

clangCheckNoIteration() {
  x=`${CLANGBIN}/clang-query -c "set output diag" -c "match whileStmt()" $1 --`
  if [ "$x" != "0 matches." ]
      then
      echo "$x"
      ln=`echo $x | grep "root. binds here"  | head -1 | cut -f2 -d":"`
      echo "You used a while loop on line $ln"
      ALLclangLocsFound="NO"
      return $FAILED
  fi
  x=`${CLANGBIN}/clang-query -c "set output diag" -c "match doStmt()" $1 --`
  if [ "$x" != "0 matches." ]
      then
      ln=`echo $x | grep "root. binds here"  | head -1 | cut -f2 -d":"`
      echo "You used a do-while loop on line $ln"
      ALLclangLocsFound="NO"
      return $FAILED
  fi
  x=`${CLANGBIN}/clang-query -c "set output diag" -c "match forStmt()" $1 --`
  if [ "$x" != "0 matches." ]
      then
      ln=`echo $x | grep "root. binds here"  | head -1 | cut -f2 -d":"`
      echo "You used a for loop on line $ln"
      ALLclangLocsFound="NO"
      return $FAILED
  fi
  return $PASSED
}

clangOneMatch() {
  x=`${CLANGBIN}/clang-query -c "set output diag" -c "match $2" $1 --`
  #echo "$x"
  y=`echo $x | grep "1 match."`
  if [ "$?" == "0" ] 
  then
      CLANGLOC=`echo $x | grep "root. binds here" | cut -f 3,4 -d":"`
  else
      CLANGLOC="NONE"
  fi 

}
clangMatchFindFunDec() {
    clangOneMatch "$1" "functionDecl(matchesName(\"$2\"))"
}
#eg functionDecl(hasName("retirement"),returns(asString("void")),hasParameter(0,parmVarDecl(hasName("startAge"),hasType(asString("int")))))
clangMatchFindFunDecWith() {
    filename="$1"
    shift
    funname="$1"
    shift
    returnType=`echo $1 | tr '-' ' '`
    shift
    query="functionDecl(hasName(\"$funname\"), isDefinition(), returns(asString(\"$returnType\")) "
    pcount=0
    argStr=""
    for argDec in $@
    do
       ty=`echo $argDec | cut -f1 -d":" | tr '-' ' '`
       if [ "$ty" = "$argDec" ]
       then 
	   # just type
	   thisArg="hasParameter($pcount,hasType(asString(\"$ty\")))"
       else
	   nm=`echo $argDec | cut -f2 -d":"`
	   thisArg="hasParameter($pcount,parmVarDecl(hasName(\"$nm\"), hasType(asString(\"$ty\"))))"
       fi
       let pcount=${pcount}+1
       argStr="${argStr},${thisArg}"
    done
    query="${query}, parameterCountIs(${pcount}) $argStr )"
    #echo "query is $query"
    clangOneMatch "$filename" "$query"
}
clangCheckTypeDef() {
    #echo ${CLANGBIN}/clang-query -c "set output diag" -c "match typedefDecl(hasName(\"$2\"))" $1 --
	x=`${CLANGBIN}/clang-query -c "set output diag" -c "match typedefDecl(hasName(\"$2\"))" $1 --`
#  echo "$x"
  y=`echo $x | grep "1 match."`
  if [ "$?" == "0" ] 
  then
      z=`echo "$x" |grep typedef`
      temp=`echo $z | sed s/^typedef[\ \t]*// | sed "s/[\ \t]*$2[\ \t]*;[\ \t]*\$//"`
      lhs=`echo $temp | tr -s ' '`
      if [ "$lhs" == "$3" ] 
      then
	  CLANGLOC=`echo $x | grep "root. binds here" | cut -f 3,4 -d":"`
      else
	  echo "You have a typedef for ${2}, but it is : "
	  echo "$z"
	  echo "where I instead expected you to define it to $3"
	  CLANGLOC="NONE"
      fi
  else
      CLANGLOC="NONE"
  fi 

}
clangFindRecusiveFunction() {
    clangOneMatch "$1" "callExpr(allOf(hasAncestor(functionDecl(hasName(\"$2\"))),callee(functionDecl(hasName(\"$2\")))))"
}
clangMatchFindStruct() {
 clangOneMatch "$1" "recordDecl(hasName(\"$2\"), isStruct())"
}

clangMatchStructWithField() {
    clangOneMatch "$1" "fieldDecl(hasParent(recordDecl(hasName(\"$2\"), isStruct())), hasName(\"$3\"), hasType(asString(\"$4\")))"
}

loadRefImpl() {
    REFIMPL=`base64 $1`
}

runRefImpl() {
   p=`pwd`
   f=`tempfile -d $p`
   chmod 700 "$f"
   echo "$REFIMPL" | base64 -d > $f
   "$f" $@
   rm "$f"
}

loadGenProg() {
    GENPROG=`base64 $1`
}

runGenProg() {
   p=`pwd`
   f=`tempfile -d $p`
   chmod 700 "$f"
   echo "$GENPROG" | base64 -d > $f
   "$f" $@
   rm "$f"
}

checkProvidedFileSha() {
   file="$1"
   sha="$2"
   if [ -f "$file" ]
   then
       x=`shasum $1 |cut -f1 -d" "`
       if [ "$x" != "$sha" ]
       then
	   echo "You seem to have modified ${1}, but should not have changed it! ($x vs $sha)"
	   SHAOK=0
       fi
   else
       echo "You do not seem to have the file ${1}"
       SHAOK=0
   fi
}
