FROM ubuntu:latest

# mainnet
EXPOSE 8444/tcp
# testnet
EXPOSE 58444/tcp
# RPC interface
EXPOSE 8555/tcp

VOLUME /root/.chia
VOLUME /plots
VOLUME /plotting

ENV start="farmer"
ENV keys="generate"
ENV farmer_address="localhost"
ENV farmer_port=8444
ENV full_node_port=8444
ENV testnet="false"
ENV plots_size=32
ENV plots_num_threads=2
ENV plots_farmer_public_key=""
ENV plots_pool_public_key=""
ENV plots_tmp_dir="/plotting"
ENV plots_final_dir="/plots"
ENV plots_options=""
ENV plots_curl_upload="false"
ENV plots_curl_target=""

RUN apt-get update
RUN apt-get install -y \
    curl jq ansible tar bash ca-certificates git openssl unzip wget sudo acl build-essential apt nfs-common vim \
    python3.8 python3.8-dev python3.8-venv python3.8-distutils python-is-python3

RUN git clone https://github.com/Chia-Network/chia-blockchain.git -b latest --recurse-submodules /chia-blockchain
RUN cd /chia-blockchain && bash ./install.sh

WORKDIR /chia-blockchain

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY create_plot.sh /usr/local/bin/create_plot.sh
RUN chmod +x /usr/local/bin/create_plot.sh

ENTRYPOINT ["bash", "/usr/local/bin/entrypoint.sh"]
