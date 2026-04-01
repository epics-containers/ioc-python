#!/bin/bash

# probes for simple python IOCs needs review
return 0

TOP=/epics/ioc
cd ${TOP}
CONFIG_DIR=${TOP}/config

set -ex

TMP_DIR=/tmp
THIS_SCRIPT=$(realpath ${0})
override=${CONFIG_DIR}/startup.sh

# 'startup.sh' may be overridden in the ioc/config directory
if [[ -f ${override} && ${override} != ${THIS_SCRIPT} ]]; then
    exec bash ${override}
fi

# probes for simple python IOCs needs review
exit 0
