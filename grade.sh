#!/bin/bash
BASE=/home/grader
DATA=${BASE}/data/assn.txt
BIN=/usr/local/bin
SUSER="student"
GUSER="grader"
GGROUP="grader"
GLIB="${BASE}/graders/common/graderlib.sh"
STUDENT=${BASE}/student/learn2prog
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
    echo "$assn does not seem to have a grader."
    exit 1
fi
#echo "sudo -u ${SUSER} -g grader -H ${BIN}/check_git_status.sh || exit 1"
sudo -u ${SUSER} -g grader -H ${BIN}/check_git_status.sh || exit 1

echo " - copying/setting up code to grade"
#FIXME: is this exit 1 in the right place?
(cd ${STUDENT} && git pull) 2>/tmp/git-error >/dev/null || (echo "Could not run git pull to obtain your submission. "; cat /tmp/git-error ; exit 1)

rm -rf ${BASE}/work/*
cp -r ${STUDENT}/${assn} ${BASE}/work/${assn}
sudo /bin/chown -R nobody.${GGROUP} ${BASE}/work

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
    echo "- grader finished"
    #grade report in ${BASE}/tmp/out
    mv ${BASE}/tmp/out ${STUDENT}/${assn}/grade.txt
    rm -rf ${BASE}/tmp/*
    chown ${GUSER}.${GGROUP} ${STUDENT}/${assn}/grade.txt
    gr=`grep "Overall Grade: " ${STUDENT}/${assn}/grade.txt | cut -f2 -d":" |tr -d ' '`
    if [ "$gr" == "" ]
    then
        echo "Strangely, I can't seem to find your grade in the grade report"
        (cd ${STUDENT} && git commit -a -m 'attempted grading: internal failure parsing report' && git push) 2>/dev/null  >/dev/null
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
    (cd ${STUDENT} &&  git add ${assn}/grade.txt && git commit -m graded) >/dev/null 2>/dev/null
    if [ "$ngr" -ge "$passing" ]
    then
        echo ""
        echo " +==================================+"
        echo " | You have passed this assignment! |"
        echo " +==================================+"
        echo ""
        # ccode=`echo $assninfo | cut -f4 -d":"`
        # if [ "$ccode" != "" ]
        # then
        #     cpart=`echo $assninfo | cut -f5 -d":"`
        #     echo "If you would like to send this grade to Coursera, then enter your"
        #     echo "authentication token now.  Otherwise, just press ENTER"
        #     echo "NOTE: your token is NOT your password."
        #     echo  ""
        #     echo ""
        #     echo -n "Token:  "
        #     read token
        #     #FIXME: who?
        #     me='adhilton@ee.duke.edu'
        #     while [ "$token" != "" ]
        #     do
        #         /usr/local/bin/send-to-coursera.sh "$me" "$ccode" "$cpart" "$fgr" "$token"
        #         if [ "$?" != 0 ]
        #         then
        #             echo "Failed to send to coursera."
        #             echo "Re-enter (possibly new) token to try again"
        #             echo "Leave blank to quit"
        #             echo ""
        #            echo -n "Token:  "
        #            read token
        #         else
        #             token=""
        #         fi
        #     done
        #fi
               
        next=`echo $assninfo | cut -f3 -d":"`
        if [ -d ${STUDENT}/${next} ]
        then
            echo "You already have ${next}, so nothing new to release"
        else
            #release $next
            echo "- Releasing ${next}"
            cp -r ${BASE}/dist/${next} ${STUDENT}/${next}
            (cd ${STUDENT} &&  git add ${STUDENT}/${next} && git commit -m 'Released assignment') 2>/dev/null  >/dev/null
        fi
    fi
    (cd ${STUDENT} &&  git push) 2>/dev/null  >/dev/null
    exit 0
else
    echo "Grader failed with status $x"
    rm -rf ${BASE}/tmp/*
    exit 1
fi





