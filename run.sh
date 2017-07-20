sudo docker run --name xtermjs-001 \
     -d -p 9999:3000 \
     -e NICETOKEN="replacethistoken" \
     -v ~/aop-coursera-assns/dist:/home/grader/dist \
     -v ~/aop-coursera-assns/graders:/home/grader/graders \
     -e NB_UID=1000 \
     xtermjs

echo "http://`hostname`:9999/?token=replacethistoken&username=student"
