#!/bin/bash
cd ~/learn2prog/
x=`git status`
if [ "$?" != 0 ]
then
    echo "git status failed: can't check if you have everything committed" > /dev/stderr
    exit 1
fi

cat > /tmp/git-clean <<EOF
On branch master Your branch is up-to-date with 'origin/master'. nothing to commit, working directory clean
EOF
y=`echo $x | diff /dev/stdin /tmp/git-clean`
if [ "$y" != "" ]
then
    git status
    echo ""
    echo ""
    echo "git status is not clean.  Please fix the above before grading"
    echo "(Only files committed and pushed to master will be graded)"
    exit 1
fi
echo " - git status is clean: proceeding"
exit 0
    

