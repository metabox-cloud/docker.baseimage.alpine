#metaBox Base Image - Alpine
#https://www.github.com/metabox-cloud
FROM alpine:3.12
LABEL maintainer="metaBox <contact@metabox.cloud>"
LABEL build="1.0:Alpine"

# user settable variables
ENV PS1="$(whoami)@$(hostname):$(pwd)$ " \
    TERM="xterm" \
    CUID=1001 \
    CGID=1001

# copy local files to container
COPY root/ /

# cleanup and secure alpine before anything else
RUN chmod +x /rm-unneeded; sync && /rm-unneeded && \
    chmod +x /secure-container; sync && /secure-container && \

    # install packages
    apk add --update --no-cache --purge --virtual=build-dependencies \
            curl \
			htop \
			iftop \
			nano \
            tar && \
    apk add --update --no-cache --purge \
            bash \
            shadow && \

    # add s6-overlay
    curl -Lk -o /tmp/s6-overlay.tar.gz https://github.com/just-containers/s6-overlay/releases/download/v1.21.2.0/s6-overlay-amd64.tar.gz && \
    tar xvfz /tmp/s6-overlay.tar.gz -C / && \
    rm -rf /tmp/s6-overlay.tar.gz && \

    # create app group
    addgroup -S \
             -g ${CGID} \
             app && \

    # create app user
    adduser -S -D -H \
            -g "" \
            -u ${CUID} \
            -h /config \
            -s /bin/bash \
            -G app \
            app && \

    # cleanup
    apk del --purge \
	          build-dependencies

ENTRYPOINT ["/init"]
