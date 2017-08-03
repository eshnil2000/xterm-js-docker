FROM ubuntu:16.04

MAINTAINER Mark McCahill "mark.mccahill@duke.edu"

USER root

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get -yq dist-upgrade \
 && apt-get install -yq --no-install-recommends \
    curl \
    wget \
    bzip2 \
    ca-certificates \
    sudo \
    locales \
    git \
    vim \
    jed \
    emacs \
    gcc \
    g++ \
    make \
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

# Create student user with UID=1000 and in the 'users' group
RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER 
RUN useradd -m -s /bin/bash  -u $GR_UID $GR_USER 

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
COPY default-bashrc /home/$NB_USER/.bashrc
RUN git config --global user.email "invalid@nowhere.com "&& \
    git config --global push.default simple &&  \
    git config --global user.name "Coursera Student"
USER $GR_USER
ENV HOME /home/$GR_USER

RUN git config --global user.email "invalid@nowhere.com" && \
    git config --global push.default simple &&  \
    git config --global user.name "Learn 2 Program Grader"

USER root
RUN chown -R $NB_USER:users /home/$NB_USER && \
    chown -R $GR_USER:grader /home/$GR_USER && \
    chmod 755 /home/$GR_USER && \
    mkdir /home/grader/tmp && \
    chown grader.grader /home/grader/tmp && \
    chmod 700 /home/grader/tmp 

# expose the xterm.js port
EXPOSE 3000

# script to start the nterm.js node app
COPY start-xtermjs.sh   /usr/local/bin/start-xtermjs.sh

# create the directory where the grader will write grades
RUN mkdir /grader ; \
    chown $GR_USER grader ; \
    chmod go-rxw /grader

USER $GR_USER
ENV HOME /home/$GR_USER
RUN mkdir /home/grader/graders
RUN mkdir /home/grader/work
RUN mkdir /home/grader/student/
RUN mkdir /home/grader/learn2prog && \
    chmod 777 /home/grader/learn2prog
RUN cd /home/grader/learn2prog && \
    git init --bare --shared=all && \
    chmod -R ugo+rwX /home/grader/learn2prog && \
    cd /home/grader/student && \
    git clone /home/grader/learn2prog
COPY README /home/grader/student/learn2prog
RUN cd /home/grader/student/learn2prog && \
    git add README && \
    git commit -m 'Initial README' && \
    git push --set-upstream origin master 

USER $NB_USER
ENV HOME /home/$NB_USER
RUN cd /home/student && \
    git clone /home/grader/learn2prog
USER $GR_USER
ENV HOME /home/$GR_USER
COPY assn/00_hello /home/grader/student/learn2prog/00_hello
USER root
RUN cd /home/grader/student/learn2prog && \
    chown -R $GR_USER.$GR_USER *

USER $GR_USER
RUN cd /home/grader/student/learn2prog && \
    git add 00_hello/* && \
    git commit -m 'Released assignment 0' && \
    git push
USER root
RUN cd /home/grader/student/learn2prog && \
    chown -R $GR_USER.$GR_USER * 
COPY check_git_status.sh /usr/local/bin
COPY grade.sh /usr/local/bin
COPY grade /usr/local/bin
COPY rungrader.sh /usr/local/bin
COPY sudoers /etc/sudoers
COPY mpipe /usr/local/bin
COPY assn.txt /home/grader/data/assn.txt
COPY secret /home/grader/data/.xxx
RUN chown grader.grader /usr/local/bin/grade && \
    chown grader.grader /usr/local/bin/grade.sh && \
    chown grader.grader /usr/local/bin/check_git_status.sh && \
    chown grader.grader /usr/local/bin/rungrader.sh && \
    chown grader.grader /usr/local/bin/mpipe &&\
    chmod 555 /usr/local/bin/grade  \
              /usr/local/bin/rungrader.sh && \
    chmod 550 /usr/local/bin/check_git_status.sh && \
    chmod 500 /usr/local/bin/grade.sh /usr/local/bin/mpipe && \
    chown -R grader.grader /home/grader/data && \
    chmod 511 /home/grader && \
    chmod 500 /home/grader/data && \
    chmod 400 /home/grader/data/*
#This is so I can debug permission problems etc, by having the root password.
#We'll take it out in the final verison.
RUN echo 'root:M4nas23n4as87@#$@34asdR' | chpasswd

# Configure container startup
ENTRYPOINT ["tini", "--"]
CMD ["start-xtermjs.sh"]

# Switch back to student to avoid accidental container runs as root
USER $NB_USER
WORKDIR /home/$NB_USER
ENV HOME /home/$NB_USER
ENV EDITOR=emacs
ENV VISUAL=emacs
