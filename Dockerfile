FROM ubuntu:latest

# mainnet
EXPOSE 8444/tcp
# testnet
EXPOSE 58444/tcp
# RPC interface
EXPOSE 8555/tcp

VOLUME /plots
VOLUME /plotting
VOLUME /root/.chia

ENV start="farmer"
ENV keys="generate"
ENV farmer_address="null"
ENV farmer_port="null"
ENV full_node_port="null"
ENV testnet="false"
ENV branch="main"

RUN DEBIAN_FRONTEND=noninteractive 
RUN apt-get update
RUN apt-get install -y \
curl jq ansible tar bash ca-certificates git openssl unzip wget sudo acl build-essential apt nfs-common vim \
python3 python3-pip python3-dev python3.8-venv python3.8-distutils python-is-python3

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["bash", "entrypoint.sh"]
