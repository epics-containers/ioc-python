ARG REGISTRY=ghcr.io/epics-containers
ARG RUNTIME=${REGISTRY}/epics-base-runtime:7.0.10ec6
ARG DEVELOPER=${REGISTRY}/epics-base-developer:7.0.10ec6

##### build stage ##############################################################
FROM  ${DEVELOPER} AS developer

# Get the current version of dependencies
COPY pyproject.toml pyproject.toml
RUN uv sync --python=3.13

COPY /ioc /epics/ioc

env PATH=/.venv/bin:$PATH

# generate a manifest of installed python packages
# IOC_VERSION is declared here, not earlier: every RUN after an ARG sees it,
# so a new value (each branch or tag) would rebuild all the steps above
ARG IOC_VERSION=unknown
COPY scripts/generate_manifest.py /tmp/generate_manifest.py
RUN python3 /tmp/generate_manifest.py "${IOC_VERSION}"

##### runtime stage ############################################################
FROM ${RUNTIME} AS runtime

# get runtime assets from the preparation stage
COPY --from=developer /.venv /.venv
COPY --from=developer /epics/ioc /epics/ioc
COPY --from=developer /python /python
COPY --from=developer /epics/versions.json /epics/versions.json

env PATH=/.venv/bin:$PATH

# launch the startup script with stdio-expose to allow console connections
CMD ["bash", "-c", "${IOC}/start.sh"]
