ARG IMAGE_EXT

ARG REGISTRY=ghcr.io/epics-containers
ARG RUNTIME=${REGISTRY}/epics-base${IMAGE_EXT}-runtime:7.0.9ec5
ARG DEVELOPER=${REGISTRY}/epics-base${IMAGE_EXT}-developer:7.0.9ec5

##### build stage ##############################################################
FROM  ${DEVELOPER} AS developer

# Get the current version of dependencies
COPY pyproject.toml pyproject.toml
RUN uv sync --python=3.13

ENV PATH=/.venv/bin:$PATH

##### runtime preparation stage ################################################
FROM developer AS runtime_prep

# get the products from the build stage and reduce to runtime assets only
# /python is created by uv and is needed in the runtime target
RUN ibek ioc extract-runtime-assets /assets /python

##### runtime stage ############################################################
FROM ${RUNTIME} AS runtime

# get runtime assets from the preparation stage
COPY --from=runtime_prep /assets /

ENV PATH=/.venv/bin:$PATH

# launch the startup script with stdio-expose to allow console connections
CMD ["bash", "-c", "${IOC}/start.sh"]
