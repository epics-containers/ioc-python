#!/bin/bash

TOP=/epics/ioc
cd ${TOP}
CONFIG_DIR=${TOP}/config

set -ex

CONFIG_DIR=/epics/ioc/config
THIS_SCRIPT=$(realpath ${0})
override=${CONFIG_DIR}/liveness.sh

if [[ -f ${override} && ${override} != ${THIS_SCRIPT} ]]; then
    exec bash ${override}
fi

# probes for simple python IOCs needs review
exit 0
