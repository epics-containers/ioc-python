#!/bin/bash

# wrap the console *************************************************************

# stdio-socket takes a single command string, so carry any command line
# arguments across the wrap in IOC_ARGS (shell quoted) and restore them after
if [[ -n ${KUBERNETES_PORT} && -z ${STDIO_EXPOSED} ]]; then
    if [[ $# -gt 0 ]]; then
        export IOC_ARGS="$(printf '%q ' "$@")"
    fi
    STDIO_EXPOSED=YES exec stdio-socket --ptty ${IOC}/start.sh
    exit 0
fi

if [[ -n ${IOC_ARGS} ]]; then
    eval set -- "${IOC_ARGS}"
    unset IOC_ARGS
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
    exec bash ${CONFIG_DIR}/start.sh "$@"
fi

# default to using main.py as entry point for the IOC, but allow override with
# MAIN_PYTHON environment variable
MAIN_PYTHON=${MAIN_PYTHON:-main.py}
STARTUP_PYTHON=${CONFIG_DIR}/${MAIN_PYTHON}
export PYTHONPATH=${CONFIG_DIR}

# execute the first python file in *.py from the config directory, if it exists
if [ -f ${STARTUP_PYTHON} ]; then
    exec python ${STARTUP_PYTHON} "$@"
else
    echo "${STARTUP_PYTHON} not found"
    echo "Restarting in 20 seconds..."
    sleep 20
    exit 1
fi

