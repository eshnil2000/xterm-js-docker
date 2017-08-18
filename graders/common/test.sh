#!/bin/bash
# loadRefImpl() {
#     REFIMPL=`base64 $1`
# }

# runRefImpl() {
#    p=`pwd`
#    f=`tempfile -d $p`
#    chmod 700 "$f"
#    echo "$REFIMPL" | base64 -d > $f
#    "$f" $@
#    rm "$f"
# }


# loadRefImpl /dev/fd/3
# runRefImpl  hello world
# env
oldIFS=$IFS
IFS=$'\n' 
x=y
for  i in `cat file`
do
    let y=${y}+1
    IFS=$oldIFS
    for x in $i
    do
	echo "${y}:${x}"
    done
done
