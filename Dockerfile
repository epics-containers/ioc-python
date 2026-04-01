ARG IMAGE_EXT

ARG REGISTRY=ghcr.io/epics-containers
ARG RUNTIME=${REGISTRY}/epics-base${IMAGE_EXT}-runtime:7.0.9ec5
ARG DEVELOPER=${REGISTRY}/epics-base${IMAGE_EXT}-developer:7.0.9ec5

##### build stage ##############################################################
FROM  ${DEVELOPER} AS developer

# Get the current version of dependencies
COPY pyproject.toml pyproject.toml
RUN uv sync --python=3.13

COPY /ioc /epics/ioc

env PATH=/.venv/bin:$PATH

##### runtime stage ############################################################
FROM ${RUNTIME} AS runtime

# get runtime assets from the preparation stage
COPY --from=developer /.venv /.venv
COPY --from=developer /epics/ioc /epics/ioc
COPY --from=developer /python /python

env PATH=/.venv/bin:$PATH

# launch the startup script with stdio-expose to allow console connections
CMD ["bash", "-c", "${IOC}/start.sh"]
