#!/bin/bash
BASE=/graderhome
DATA=${BASE}/data/assn.txt
BIN=/usr/local/bin
SUSER="student"
GUSER="grader"
GGROUP="grader"
GLIB="${BASE}/graders/common/graderlib.sh"
STUDENT=${BASE}/student/learn2prog
REMOTE=/git-remote/learn2prog
assn=""
if [ "$1" != "" ]
then
       assn=`basename $1`
fi
if [ "$assn" == "" ]
then
    p=`pwd`
    assn=`basename $p`
fi
assn=`echo $assn | tr -d ':'`
assninfo=`grep ^${assn}: ${DATA}`
tag=`echo $assn | cut -f1 -d"_"`

if [ "$assninfo" == "" -o "${tag}" == "" ]
then
    echo "Invalid assignment: $assn" >/dev/stderr
    exit 1
fi

if [ -x "${BASE}/graders/grade-${assn}.sh" ]
then
    GSCRIPT="${BASE}/graders/grade-${assn}.sh"
else
    whoami
    echo "In ${BASE}"
    ls ${BASE}
    echo "IN ${BASE}/graders"
    ls -l ${BASE}/graders/
    echo "$assn does not seem to have a grader."
    exit 1
fi
#echo "sudo -u ${SUSER} -g grader -H ${BIN}/check_git_status.sh || exit 1"
sudo -u ${SUSER} -g grader -H ${BIN}/check_git_status.sh || exit 1

echo " - copying/setting up code to grade"
#FIXME: is this exit 1 in the right place?
if [ ! -d $STUDENT ]
then
    (cd ${BASE}/student && git clone $REMOTE) 2>/tmp/git-error > /dev/null || ("Echo could not read your git repository: "; cat /tmp/git-error; exit 1)
fi
(cd ${STUDENT} && git pull) 2>/tmp/git-error >/dev/null || (echo "Could not run git pull to obtain your submission. "; cat /tmp/git-error ; exit 1)

rm -rf ${BASE}/work/*
cp -r ${STUDENT}/${assn} ${BASE}/work/${assn}
chmod -R ug+rw ${BASE}/work/${assn}
sudo /bin/chown -R nobody.${GGROUP} ${BASE}/work/*

line=""
fd=4
cat ${GLIB} ${GSCRIPT} > ${BASE}/tmp/x
chmod 555 ${BASE}/tmp/x
while [ -r ${BASE}/graders/expected/provided/${tag}.${fd} ]
do
    line="$line ${BASE}/graders/expected/provided/${tag}.${fd}"
    let fd=${fd}+1
done
echo " - running grader"
${BIN}/mpipe ${BASE}/tmp/x $line  >${BASE}/tmp/out
x="$?"
if [ "$x" == 0 ]
then
    echo " - grader finished"
    #cat ${BASE}/tmp/out
    #grade report in ${BASE}/tmp/out
    mv ${BASE}/tmp/out ${STUDENT}/${assn}/grade.txt
    rm -rf ${BASE}/tmp/*
    chown ${GUSER}.${GGROUP} ${STUDENT}/${assn}/grade.txt
    gr=`grep "Overall Grade: " ${STUDENT}/${assn}/grade.txt | cut -f2 -d":" |tr -d ' '`
    if [ "$gr" == "" ]
    then
        echo "Strangely, I can't seem to find your grade in the grade report"
        (cd ${STUDENT} && git commit -a -m 'attempted grading: internal failure parsing report' && git push ) 2>/dev/null  >/dev/null 
        exit 1
    fi
    case $gr in
        A)
            ngr=100
            fgr=1.0
            ;;
        PASSED)
            ngr=100
            fgr=1.0
            ;;
        B)
            ngr=85
            fgr=0.85
            ;;
        C)
            ngr=75
            fgr=0.75
            ;;
        D)
            ngr=65
            fgr=0.65
            ;;
        F)
            ngr=0
            fgr=0.0
            ;;
        FAILED)
            ngr=0
            fgr=0.0
            ;;
        *)
            ngr="$grade"
            fgr=`echo "scale=4; $grade / 100" | bc`
            ;;
    esac
    passing=`echo $assninfo | cut -f2 -d":"`
    (cd ${STUDENT} &&  git add ${assn}/grade.txt && git commit -m graded) 2>/dev/null > /dev/null
    # (1) We'll write the grade to /grader/grades.txt
    echo "${assn}:${fgr}" >>/grader/grades.txt
    if [ "$ngr" -ge "$passing" ]
    then
        echo ""
        echo " +==================================+"
        echo " | You have passed this assignment! |"
        echo " +==================================+"
        echo ""
	# (2) We'll track some stuff in /grader in case we have to
	# give just one "overall" grade for the course.
	for course in /git-remote/passed.*
	do
	    cline=`grep ${assn}: ${course}`
	    if [ "$cline" != "" ]
	    then
		(grep -v "${assn}: ${course}" ; echo "${assn}:P") > ${course}
		asntotal=`wc -l ${course} | cut -f1 -d" " |tr -d ' '`
		asnpassed=`grep :P ${course} | wc -l | tr -d' '`
		v=`echo "scale=3; $asnpassed / $assntotal" | bc`
		cname=`basename $course | cut -f2 -d"."`
		echo "$v" > /grader/grade.${cname}
	    fi
	done
        
        next=`echo $assninfo | cut -f3 -d":"`
        if [ -d ${STUDENT}/${next} ]
        then
            echo "You already have ${next}, so nothing new to release"
        else
            #release $next
            echo "- Releasing ${next}"
	    mesg=`grep "$next" ${DATA} | cut -f4 -d":" `
	    if [ "$mesg" != "" ]
	    then
		echo "You should continue watching videos until you have watched:"
		echo "  $mesg  "
		echo "which covers the material you will need to do $next"
		cp -r ${BASE}/dist/${next} ${STUDENT}/${next}
		(cd ${STUDENT} &&  git add ${STUDENT}/${next} && git commit -m 'Released assignment') 2>/dev/null  >/dev/null
            fi
	fi
    fi
#    echo "(cd ${STUDENT} &&  git push)"

    (cd ${STUDENT} &&  git push)  2>/dev/null > /dev/null
    exit 0
else
    echo "Grader failed with status $x"
    rm -rf ${BASE}/tmp/*
    exit 1
fi





