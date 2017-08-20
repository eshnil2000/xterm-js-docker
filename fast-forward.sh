#!/bin/bash
next="$1"
BASE=/graderhome
STUDENT=${BASE}/student/learn2prog

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
