#!/bin/bash
next="$1"
BASE=/graderhome
STUDENT=${BASE}/student/learn2prog
REMOTE=/git-remote/learn2prog
if [ ! -d $STUDENT ]
then
    (cd ${BASE}/student && git clone $REMOTE) 2>/tmp/git-error > /dev/null || ("Echo could not read your git repository: "; cat /tmp/git-error; exit 1)
fi
(cd ${STUDENT} && git pull) 2>/tmp/git-error >/dev/null || (echo "Could not run git pull to ensure I'm up to date with your code. "; cat /tmp/git-error ; exit 1)

if [ -d ${STUDENT}/${next} ]
then
    echo "You already have ${next}, so nothing new to release"
else
    if [ -d "${BASE}/dist/${next}" ]
       then
	   #release $next
	   echo "We strongly recommend doing the assignments in order, passing"
	   echo "each one before proceeding to the next.  Howerver, we will"
	   echo "release ${next} as you requested."
	   cp -r ${BASE}/dist/${next} ${STUDENT}/${next}
	   (cd ${STUDENT} &&  \
		   git add ${STUDENT}/${next} && \
		   git commit -m 'Released assignment' && \
	           git push) 2>/dev/null  >/dev/null
    else
	echo "$next does not appear to be a valid assignment"
    fi
fi
