
FROM ubuntu:16.04

MAINTAINER Mark McCahill "mark.mccahill@duke.edu"

USER root

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get -yq dist-upgrade \
 && apt-get install -yq --no-install-recommends \
    curl \
    wget \
    bzip2 \
    bc \
    ca-certificates \
    sudo \
    locales \
    git \
    vim \
    jed \
    emacs \
    less \
    gcc \
    g++ \
    make \
    man-db \
    manpages-dev \
    valgrind \
    gdb \
    clang \
    build-essential \
    python-dev \
    libssl-dev \
    unzip \
 && apt-get clean 

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

# Install Tini
RUN wget --quiet https://github.com/krallin/tini/releases/download/v0.10.0/tini && \
    echo "1361527f39190a7338a0b434bd8c88ff7233ce7b9a4876f3315c22fce7eca1b0 *tini" | sha256sum -c - && \
    mv tini /usr/local/bin/tini && \
    chmod +x /usr/local/bin/tini

# install a recent version of nodejs 
RUN curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash - ; \
    apt-get install -y nodejs
    
# Configure environment
ENV SHELL /bin/bash
ENV NB_USER student
ENV NB_UID 1000
ENV HOME /home/$NB_USER
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

ENV GR_UID 1001
ENV GR_USER grader
ENV GR_HOME /graderhome
ENV GIT_REMOTE /git-remote/learn2prog
ENV GRADE_PASSED /grader

# Create student user with UID=1000 and in the 'users' group
RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER 
RUN useradd -m --home-dir  /graderhome -s /bin/bash  -u $GR_UID $GR_USER 
RUN adduser $GR_USER tty
# grab xterm.js and install it
RUN cd /usr/local/src ; \
    git clone https://gitlab.oit.duke.edu/mccahill/xterm.js ; chown -R $NB_USER xterm.js

USER $NB_USER

# build the xterm.js node.js application
RUN cd /usr/local/src/xterm.js ; \
    npm install 

# remove the npm build artifacts 
RUN rm -rf /home/student/.npm
RUN rm -rf /home/student/.node-gyp

USER $NB_USER

# put a better .bashrc in place
##COPY default-bashrc /home/$NB_USER/.bashrc
##RUN git config --global user.email "invalid@nowhere.com "&& \
##    git config --global push.default simple &&  \
##    git config --global user.name "Coursera Student"
USER $GR_USER
ENV HOME $GR_HOME

RUN git config --global user.email "invalid@nowhere.com" && \
    git config --global push.default simple &&  \
    git config --global user.name "Learn 2 Program Grader"

USER root
COPY l2p /usr/local/l2p/
RUN chown -R root:root /usr/local/l2p
RUN chmod -R og-w /usr/local/l2p && \
    chmod -R og+rX /usr/local/l2p
RUN chown -R $NB_USER:users /home/$NB_USER && \
    chown -R $GR_USER:grader $GR_HOME && \
    chmod 755 $GR_HOME && \
    mkdir $GR_HOME/tmp && \
    chown grader.grader $GR_HOME/tmp && \
    chmod 700 $GR_HOME/tmp 
RUN mkdir  -p $GIT_REMOTE && \
    chmod 777 $GIT_REMOTE && \
    chown $GR_USER.$GR_USER $GIT_REMOTE 
#    mkdir $GRADE_PASSED && \
#    chown $GR_USER.$GR_USER $GRADE_PASSED && \
#    chmod 700 $GRADE_PASSED
    
# expose the xterm.js port
EXPOSE 3000

# script to start the nterm.js node app
COPY start-xtermjs.sh   /usr/local/bin/start-xtermjs.sh

# This has now been done above (but different ownership/permissions)
# create the directory where the git-remote for the student will reside
#RUN mkdir /git-remote ; \
#    chown $NB_USER /git-remote 

# create the directory where the grader will write grades
RUN mkdir /grader ; \
    chown $GR_USER /grader ; \
    chmod 700 /grader

USER $GR_USER
ENV HOME $GR_HOME
RUN mkdir $GR_HOME/graders
RUN mkdir $GR_HOME/work
RUN mkdir $GR_HOME/student/

# RUN cd $GIT_REMOTE && \
#     git init --bare --shared=all && \
#     chmod -R ugo+rwX $GIT_REMOTE && \
#     cd $GR_HOME/student && \
#     pwd &&\
#     git clone $GIT_REMOTE && \
#     ls
# COPY README $GR_HOME/student/learn2prog
# RUN cd $GR_HOME/student/learn2prog && \
#     git add README && \
#     git commit -m 'Initial README' && \
#     git push --set-upstream origin master 

COPY graders ${GR_HOME}/graders/


USER $NB_USER
ENV HOME /home/$NB_USER
#RUN cd /home/student && \
#    git clone $GIT_REMOTE
USER $GR_USER
ENV HOME $GR_HOME
#COPY assn/00_hello $GR_HOME/student/learn2prog/00_hello
USER root
#RUN cd $GR_HOME/student/learn2prog && \
#    chown -R $GR_USER.$GR_USER *
RUN chown -R ${GR_USER}.${GR_USER} ${GR_HOME}/graders
RUN chmod og-rwx -R  ${GR_HOME}/graders


USER $GR_USER
#RUN cd $GR_HOME/student/learn2prog && \
#    git add 00_hello/* && \
#    git commit -m 'Released assignment 0' && \
#    git push
#COPY passed.c2 $GRADE_PASSED/
#COPY passed.c3 $GRADE_PASSED/
#COPY passed.c4 $GRADE_PASSED/    
USER root
#RUN cd $GR_HOME/student/learn2prog && \
#    chown -R $GR_USER.$GR_USER * 
COPY check_git_status.sh /usr/local/bin
COPY grade.sh /usr/local/bin
COPY grade /usr/local/bin
COPY fast-forward.sh /usr/local/bin
COPY fast-forward /usr/local/bin
COPY rungrader.sh /usr/local/bin
COPY sudoers /etc/sudoers
COPY mpipe /usr/local/bin
COPY assn.txt $GR_HOME/data/assn.txt
RUN chown grader.grader /usr/local/bin/grade && \
    chown grader.grader /usr/local/bin/grade.sh && \
    chown grader.grader /usr/local/bin/fast-forward && \
    chown grader.grader /usr/local/bin/fast-forward.sh && \
    chown grader.grader /usr/local/bin/check_git_status.sh && \
    chown grader.grader /usr/local/bin/rungrader.sh && \
    chown grader.grader /usr/local/bin/mpipe &&\
    chmod 555 /usr/local/bin/grade /usr/local/bin/fast-forward \
              /usr/local/bin/rungrader.sh && \
    chmod 550 /usr/local/bin/check_git_status.sh && \
    chmod 500 /usr/local/bin/grade.sh /usr/local/bin/fast-forward.sh /usr/local/bin/mpipe && \
    chown -R grader.grader $GR_HOME/data && \
    chmod 511 $GR_HOME && \
    chmod 500 $GR_HOME/data && \
    chmod 400 $GR_HOME/data/*

RUN mkdir -p $GR_HOME/dist
COPY assn/ ${GR_HOME}/dist/
RUN chown -R grader.grader ${GR_HOME}/dist
RUN chmod -R og-rwx ${GR_HOME}/dist
RUN mkdir -p /usr/local/clang/bin/
RUN ln -s `which clang-query` /usr/local/clang/bin/clang-query

# Configure container startup
ENTRYPOINT ["tini", "--"]
CMD ["start-xtermjs.sh"]

# Switch back to student to avoid accidental container runs as root
USER $NB_USER
WORKDIR /home/$NB_USER
ENV HOME /home/$NB_USER
ENV EDITOR=emacs
ENV VISUAL=emacs
