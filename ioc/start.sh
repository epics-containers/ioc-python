#!/bin/bash

# wrap the console *************************************************************

if [[ -n ${KUBERNETES_PORT} && -z ${STDIO_EXPOSED} ]]; then
    STDIO_EXPOSED=YES exec stdio-socket ${IOC}/start.sh
    exit 0
fi

# error reporting **************************************************************

function ibek_error {
    echo "Error on line $BASH_LINENO: $BASH_COMMAND (exit code: $?)"

    # Wait for a bit so the container does not exit and restart continually
    sleep 10
    exit 1
}

trap ibek_error ERR

# log commands and stop on errors
set -xe

# environment setup ************************************************************

cd ${IOC}

# check for an override start.sh script ****************************************

if [ -f ${CONFIG_DIR}/start.sh ]; then
    exec bash ${CONFIG_DIR}/start.sh
fi

# execute the first python file in *.py from the config directory, if it exists
if [ -f ${CONFIG_DIR}/*.py ]; then
    exec python ${CONFIG_DIR}/*.py
else:
    echo "No startup script found in ${CONFIG_DIR}"
    echo "Restarting in 20 seconds..."
    sleep 20
    exit 1
fi

