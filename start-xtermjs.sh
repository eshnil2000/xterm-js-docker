#!/bin/bash

set -e
NODE_ENV=production

#
# start xtermjs
# 

# Handle special flags if we're root
if [ $UID == 0 ] ; then
    # Change UID of NB_USER to NB_UID if it does not match
    if [ "$NB_UID" != $(id -u $NB_USER) ] ; then
        usermod -u $NB_UID $NB_USER
    fi

    # Enable sudo if requested
    if [ ! -z "$GRANT_SUDO" ]; then
        echo "$NB_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/xtermjs
    fi

    # Exec the command as NB_USER
    exec su $NB_USER -c "env PATH=$PATH npm  /usr/local/src/xterm.js start "
else
    # Exec the command
    exec npm --prefix /usr/local/src/xterm.js start  
fi

