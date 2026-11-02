#!/bin/bash

# parse arguments *************************************************************

# --test: check the startup python script compiles, but do not launch it. Used
# by CI to validate configs. All arguments, including --test, are also forwarded
# unchanged to a config override start.sh (see below) if one exists, for it to
# interpret itself.
TEST_MODE=false
[[ "$1" == "--test" ]] && TEST_MODE=true

# wrap the console *************************************************************
# test mode is not wrapped: stdio-socket always exits 0, so a wrapped --test
# could never fail.

# stdio-socket takes a single command string, so carry any command line
# arguments across the wrap in _STDIO_IOC_ARGS (shell quoted, internal only)
# and restore them after
if [[ -n ${KUBERNETES_PORT} && -z ${STDIO_EXPOSED} && "${TEST_MODE}" != "true" ]]; then
    if [[ $# -gt 0 ]]; then
        export _STDIO_IOC_ARGS="$(printf '%q ' "$@")"
    fi
    STDIO_EXPOSED=YES exec stdio-socket --ptty ${IOC}/start.sh
    exit 0
fi

if [[ -n ${_STDIO_IOC_ARGS} ]]; then
    eval set -- "${_STDIO_IOC_ARGS}"
    unset _STDIO_IOC_ARGS
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

# report what this image was built from (python versions)
if [[ -f /epics/versions.json ]]; then
    cat /epics/versions.json
fi

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
    if [[ "${TEST_MODE}" == "true" ]]; then
        python -c 'import sys; compile(open(sys.argv[1]).read(), sys.argv[1], "exec")' ${STARTUP_PYTHON}
        echo "Test mode: ${STARTUP_PYTHON} compiles, skipping launch"
        exit 0
    fi
    exec python ${STARTUP_PYTHON} "$@"
else
    echo "${STARTUP_PYTHON} not found"
    echo "Restarting in 20 seconds..."
    sleep 20
    exit 1
fi

