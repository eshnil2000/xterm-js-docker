# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.

#FROM debian:jessie 
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

# Create student user with UID=1000 and in the 'users' group
RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER 

# grab xterm.js and install it
#RUN cd /usr/local/src ; \
#    git clone https://github.com/sourcelair/xterm.js.git ; \ 
#    chown -R $NB_USER xterm.js
RUN cd /usr/local/src ; \
    git clone https://github.com/mccahill/xterm.js.git ; \ 
    chown -R $NB_USER xterm.js

USER $NB_USER

# build the xterm.js node.js application
RUN cd /usr/local/src/xterm.js ; \
    npm install 

# put a better .bashrc in place
COPY default-bashrc /home/$NB_USER/.bashrc

USER root
RUN chown -R $NB_USER:users /home/$NB_USER

# expose the xterm.js port
EXPOSE 3000

# script to start the nterm.js node app
COPY start-xtermjs.sh /usr/local/bin/start-xtermjs.sh

# Configure container startup
ENTRYPOINT ["tini", "--"]
CMD ["start-xtermjs.sh"]

# Switch back to student to avoid accidental container runs as root
USER $NB_USER


