#!/bin/bash

# probes for simple python IOCs needs review
return 0

TOP=/epics/ioc
cd ${TOP}
CONFIG_DIR=${TOP}/config

set -e

TMP_DIR=/tmp
THIS_SCRIPT=$(realpath ${0})
override=${CONFIG_DIR}/startup.sh

# 'startup.sh' may be overridden in the ioc/config directory
# compare resolved paths: /epics/ioc is a symlink, so an unresolved override
# path never equals THIS_SCRIPT and a copied script would exec itself forever
if [[ -f ${override} && $(realpath "${override}") != "${THIS_SCRIPT}" ]]; then
    exec bash ${override}
fi

# probes for simple python IOCs needs review
exit 0
