# Containerized xterm.js terminal for Linux


This project wraps a slightly modified version of the xterm.js library  
packaged in a Docker container, suitable for deploying for student access to coursework.  
You might do this if you wanted a browser-based zero-install environment for a course.  

Xterm.js is a terminal front-end component written in JavaScript that works in the browser.  
For details see   
  [https://github.com/mccahill/xterm.js]   
which was forked from   
  [https://github.com/sourcelair/xterm.js]   


### Architecture

The xterm.js container is built from an Ubuntu 16.04 base image and includes some  
common Linux development tools - if you can add more tools and rebuild the  
container as needed by editing the Dockerfile andf then running the build script.  

The base xterm.js library does not authenticate the user before giving them a bash  
shell, so this fork includes some simple authentication using the Passport library  
for node.js express frameworks. Passport is found here: [https://www.passportjs.org/].  

In the forked version of xterm.js at https://github.com/mccahill/xterm.js there is a  
subdirectory named "terminalauth". The terminalauth app uses the "local" passport  
authentication strategy to accept a username and token, and versify that the token is  
correct.

Because we will be running many instances of the Docker container (one for each user)  
we need to give each a different tokens for authentication. The token to be  
used is passed to the container at runtime as the environmental variable "NICETOKEN"  
so an individual instance of a container is loaunched something like this:  

```
          sudo docker run --name xtermjs-001 \
            -d -p 9999:3000 \
            -e NICETOKEN="replacethistoken" \
            -v /srv/persistent-data/homedirs/user001:/home/student/work \
            -e NB_UID=1000 \
            xtermjs 
```

We mount an external volume to the doocker container for the /home/student/work 
directory so that student's work will persist across container restart.  

The NB_UID is used to set the file ownership so that the student owns their files.  

For more details, see the start-xterm.sh shell script that tini runs whem the container  
is launched.


### Encrypt your sessions


Note that xterm.js runns as http rather than https. You almost certainly want to put an  
https proxy in front of the xterm instance so that the session to the user is encrypted.  

Here is how we typically handle this:

Suppose you want to keep each user sequestered as much as possible. To do this you would  
want to run an a container for each user, and map the user's home directory to an external  
volume. 

You would also need to map each user to a different port, and keep track of  
the mapping of user to port and external home directory volume -- and you need  
to have unique passwords or tokens for each user.

With all this information in hand, you could construct URLs specific to each user and  
after they have authenticated at some other web site, redirect them to the appropriate  
container and automatically log them in. Ideally, you would also run the entire xterm.js   
session over https so that everything is encrypted.

To accomplish all of this, we use two additional containerized services:  
- nginx [https://github.com/nginxinc/docker-nginx]  
- docker-gen [https://github.com/jwilder/docker-gen]  

Nginx provides https support by accepting https connections and proxying them to the  
appropriate container port on the local server. Nginx needs a configuration file to to  
know what to do, and the prospect of maintaining a config file for over a hundred  
containers was not appealing, so we take advantage of docker-gen to dynamically update  
the nginx config  as containers are started/stopped.  

Docker-gen tracks activity (container starts/stops) from the docker daemon, and based  
on the VIRTUAL_HOST environmental variable for the containers can select an appropriate  
template to use for updating the nginx config file. This is cool because it means that  
we are not faced with manually updating the nginx config - instead docker-gen updates it  
for us.  

With a little bit of shell scripting to read a mapping file that lists users and passwords  
for container users, based on this file your can launch containers and pass them individualized  
settings -- something you will want to be able to do when your server starts. 

For details on the configurations of these services used at Duke and an example how to  
script startup of a cluster of RStudio instances front-ended by nginx and docker-gen see  
[https://github.com/mccahill/docker-gen/tree/duke]





