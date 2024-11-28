FROM bugy/script-server:latest

# Copy configuration and scripts
COPY conf/ /app/conf/
COPY ./conf/scripts/user-custom/ /app/conf/scripts/user-custom/
COPY ./conf/runners/user-custom/ /app/conf/runners/user-custom/
COPY ./conf/keys/ /app/conf/keys/
COPY ./conf/repo/ /app/conf/repo/
COPY ./conf/stash/ /app/conf/stash/

# Set file permissions
RUN chmod +x /app/conf/scripts/*.sh
RUN chmod +x /app/conf/stash/*.sh

# Install pre-reqs
RUN /bin/sh -c set -eux; apt-get update; apt-get install -y --no-install-recommends ssh git curl ca-certificates netbase tzdata ; rm -rf /var/lib/apt/lists/* # buildkit

ENV CLUSTER_HELPER_REPO=""
ENV USER_MOUNT="/app/conf"