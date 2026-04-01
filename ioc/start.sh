#!/bin/bash

# wrap the console *************************************************************

if [[ -n ${KUBERNETES_PORT} && -z ${STDIO_EXPOSED} ]]; then
    STDIO_EXPOSED=YES exec stdio-socket --ptty ${IOC}/start.sh
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

CONFIG_DIR=${IOC}/config

# check for an override start.sh script ****************************************

if [ -f ${CONFIG_DIR}/start.sh ]; then
    exec bash ${CONFIG_DIR}/start.sh
fi

# default to using main.py as entry point for the IOC, but allow override with
# MAIN_PYTHON environment variable
MAIN_PYTHON=${MAIN_PYTHON:-main.py}
STARTUP_PYTHON=${CONFIG_DIR}/${MAIN_PYTHON}
export PYTHONPATH=${CONFIG_DIR}

# execute the first python file in *.py from the config directory, if it exists
if [ -f ${STARTUP_PYTHON} ]; then
    exec python ${STARTUP_PYTHON}
else
    echo "${STARTUP_PYTHON} not found"
    echo "Restarting in 20 seconds..."
    sleep 20
    exit 1
fi

