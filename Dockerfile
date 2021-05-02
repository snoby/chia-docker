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

RUN DEBIAN_FRONTEND=noninteractive 
RUN apt-get update
RUN apt-get install -y \
curl jq ansible tar bash ca-certificates git openssl unzip wget sudo acl build-essential apt nfs-common vim \
python3.9 python3.9-dev python3.9-venv python3.9-distutils python-is-python3

RUN git clone https://github.com/Chia-Network/chia-blockchain.git -b latest --recurse-submodules /chia-blockchain
RUN cd /chia-blockchain && bash ./install.sh

WORKDIR /chia-blockchain
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["bash", "/usr/local/bin/entrypoint.sh"]
