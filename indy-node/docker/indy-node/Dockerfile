FROM ubuntu:16.04

RUN apt-get update -y && apt-get install -y \
    apt-transport-https \
    ca-certificates

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys CE7709D068DB5E88
RUN bash -c 'echo "deb https://repo.sovrin.org/deb xenial stable" >> /etc/apt/sources.list'
RUN apt-get update -y && apt-get install -y \
    indy-node=1.12.6 \
    indy-plenum=1.12.6 \
    && rm -rf /var/lib/apt/lists/*

COPY scripts/init_and_run.sh ./

CMD ["./init_and_run.sh"]

VOLUME ["/var/log/indy"]
