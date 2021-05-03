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
ENV farmer_address="localhost"
ENV farmer_port=8444
ENV full_node_port=8444
ENV testnet="false"
ENV wallet_fingerprint=2491107845
ENV farmer_public_key="a80bc76ade0b484e4b53f7bae1466c40bdeb7cd27bf78afeb0e47ad0b74f32fc5fad53e814cd47b12a17660198d71ae5"
ENV pool_public_key="a444b168570a817238e54833a16d83a8744fbec5225fa4decc31d5184310781693fd1014907a513ce6d3cf68e11f34ea"
ENV plot_size=32
ENV maximum_plotters=1

RUN DEBIAN_FRONTEND=noninteractive 
RUN apt-get update
RUN apt-get install -y \
curl jq ansible tar bash ca-certificates git openssl unzip wget sudo acl build-essential apt nfs-common vim \
python3.8 python3.8-dev python3.8-venv python3.8-distutils python-is-python3

RUN git clone https://github.com/Chia-Network/chia-blockchain.git -b latest --recurse-submodules /chia-blockchain
RUN cd /chia-blockchain && bash ./install.sh

WORKDIR /chia-blockchain
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY create_plot.sh /usr/local/bin/create_plot.sh

ENTRYPOINT ["bash", "/usr/local/bin/entrypoint.sh"]
