FROM ubuntu:18.04

RUN apt-get update -y && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    software-properties-common \
    libsodium-dev \
    libsecp256k1-dev \
    libssl-dev \
    liblzma-dev \
    libsnappy-dev \
    liblz4-dev \
    libbz2-dev \
    zlib1g-dev \
    librocksdb-dev \
    python3.5 \
    python3-pip \
    docker.io
RUN pip3 install -U \
    'pip<10.0.0' \
    'setuptools<58.0'
RUN pip3 install python3-indy indy-node==1.12.6

RUN mkdir /opt/controller

COPY scripts/restart_indy_node.sh /opt/controller/restart_indy_node
COPY scripts/upgrade_indy.sh /opt/controller/upgrade_indy
COPY python/start_node_control_tool /opt/controller/start_node_control_tool
COPY python/container_node_control_tool.py /opt/controller/container_node_control_tool.py
COPY scripts/init_and_run.sh ./

CMD ["./init_and_run.sh"]
