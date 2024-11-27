# Clusterhelper

Clusterhelper is a small tool I've put together tapping the power of script-server to help me manage my truescale cluster.

I'm including scripts I'm using in my environment but will take feedback and work on requests to help make this useful for others if they're interested.

## Installation

I'm still working on the docker image but will publish it for download as soon as it's ready.

Run the below command to run the docker container. Your personal truecharts repo should land in `~/clusterhelper/repo/` so you should be able to run all you standard `clustertool` commands from there.

```docker run -p 5000:5000  --name clusterhelper \
-v ~/clusterhelper/keys/:/app/conf/keys/ \
-v ~/clusterhelper/repo/:/app/conf/repo/ \
-v ~/clusterhelper/runners/:/app/conf/runners/user-custom/ \
-v ~/clusterhelper/scripts/:/app/conf/scripts/user-custom/ \
-v ~/clusterhelper/logs/:/app/logs \
clusterhelper:latest```