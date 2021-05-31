# Chia Docker container

## Basics
You can modify the behavior of your Chia container by setting specific environment variables.
Every time the container starts it will try to fetch the latest stable version of the Chia Network code and update its dependencies.
By default this container tries to join the Chia Network as a full node.

## Configuration

Expose TCP ports:
- 8444 - mainnet
- 58444 - testnet
- 8555 - RPC interface

Map volumes:
- /root/.chia - blockchain, config and potentially keys (mnemonic.txt)
- /mnt/chia-plots/final - plots on storage
- /mnt/chia-plots/tmp - *fast* storage for plotting, add one per device
- /mt/passed-ca - passed in CA, copied from your main node.

Possible start values are
- all
- node
- harvester
- farmer
- farmer-no-wallet
- farmer-only
- timelord
- timelord-only
- timelord-launcher-only
- wallet
- wallet-only
- introducer
- simulator
- plotman

Other environment variables
- chia_dir - (string) Default: "/opt/chia-blockchain"
- plots_size - (integer) Default: 32
- plots_num - (integer) Default: 1, Number of plots to create
- plots_num_threads - (integer) Default: 2
- plots_farmer_public_key - (string) Required for plotting, retrieve via *chia keys show*
- plots_pool_public_key - (string) Required for plotting, retrieve via *chia keys show*
- plots_tmp_dir - (string) Default: "/mnt/chia-plots/tmp", path to temporary plotting directory
- plots_final_dir - (string) Default: "/mnt/chia-plots/final", path to final plots directory
- prevent_sleep - (string) Default: "", Set to *caffeinate -i* on Mac OS to prevent sleep
- plots_options - (string) Can be used to specify plots options like "--nobitfield"
- plots_curl_target - (string) Target for curl, e.g. ftp://anonymous@farmer/plots
- CA_PROVIDED -(string) true or false, if true we will check the /mnt/passed-ca directory for your ca keys to be imported.

## Running as farmer


```
docker run -d\
	--name="$NAME"                              \
	-v `pwd`/config/:/root/.chia                \
	-v "$FARM_STORAGE":/mnt/chia-plots/final    \
	-v "$CA_DIR":/mnt/passed-ca:ro              \
	-v `pwd`/mnemonic.txt:/tmp/mnemonic.txt:ro  \
	-e keys="/tmp/mnemonic.txt"                \
	-e CA_PROVIDED=true                         \
	-e chia_update_on_init=false                \
	-e start="farmer"                           \
	-P                                          \
	"${CONT_NAME}"

```
Where `CA_DIR` contains the copied CA certificates from the main system.

## Running Plotman (Experimental)
```
#!/bin/bash
set +x
source source_keys.sh

FAST_STORAGE=/mnt/disk/
ICE_STORAGE=/mnt/farm2/
CONT_NAME=iotapi322/chia:0.2-1.1.6
NAME=plotman

# COPY OF YOUR INITIAL INSTALL ca directory

CA_DIR=/home/snoby/chia_ca

docker stop $NAME
docker rm $NAME

docker run -d\
	--name="$NAME"   \
	-v "$FAST_STORAGE":/mnt/chia-plots/tmp   \
	-v "$ICE_STORAGE":/mnt/chia-plots/final   \
	-v "$CA_DIR":/mnt/passed-ca:ro              \
	-v `pwd`/mnemonic.txt:/tmp/mnemonic.txt:ro              \
	-v `pwd`/plotman.yaml:/root/.config/plotman/plotman.yaml \
	-e keys="/tmp/mnemonic.txt"                   \
	-e CA_PROVIDED=true                      \
	-e chia_update_on_init=false             \
	-e farmer_address=10.0.0.116           \
	-e farmer_port=8444                    \
	-e plots_farmer_public_key="$FARM_KEY" \
    -e plots_pool_public_key="$POOL_KEY" \
	-e start="plotman"                       \
	"${CONT_NAME}"
```
You need to have the  mnemonic file, the CA_DIR, and a copy of plotman.yaml volume mounted
(NOTE): The paths for plotman have to be for INSIDE the container not on the host.

## Scripts

### container_entrypoint.sh
This script is executed uppon container start.

### plots_create.sh <plots_tmp_dir>
Script to trigger a plot creation process. Most parameters will be taken from the environment, plots_tmp_dir can be overwritten as first argument.
The script checks if there is already a plotting process running on given plots_tmp_dir.

### plots_upload.sh <plots_final_dir>
Helper script to upload finished plots using curl. In my case I upload it to a ftp server.
The script will exit if there is already a curl upload running on given plots_final_dir.

## Examples

Plotter startup, prepares the environment without blockchain and keys.
```
docker run --name <container-name> \
    --volume /path/to/plots:/mnt/chia-plots/final --volume /path/to/fast/storage:/mnt/chia-plots/tmp \
    --env start="plotter" \
    --env plots_farmer_public_key="" \
    --env plots_pool_public_key="" \
    -d gldecurtins/chia-docker:latest
```

Plotting task has to be triggered manually, output to be found in the plotting directory.
```
docker exec -d <container-name> /usr/local/bin/plots_create.sh
```

Plotting with multiple tasks, using different storage devices. Volumes to be mapped accordingly.
```
docker exec -d <container-name> /usr/local/bin/plots_create.sh /mnt/storage1
docker exec -d <container-name> /usr/local/bin/plots_create.sh /mnt/storage2
```

If required, upload finished plots to farmer. Specify plots_curl_target and execute the script.
```
docker exec -d <container-name> /usr/local/bin/plots_upload.sh
```

Full node startup on mainnet, generating keys
```
docker run --name <container-name> \
    --volume /path/to/.chia:/root/.chia --volume /path/to/plots:/mnt/chia-plots/final \
    -d gldecurtins/chia-docker:latest
```

Full node startup on testnet, generating keys
```
docker run --name <container-name>  \
    --volume /path/to/.chia:/root/.chia --volume /path/to/plots:/mnt/chia-plots/final \
    --env testnet="true" \
    -d gldecurtins/chia-docker:latest
```

Full node startup on mainnet, use existing keys. E.g. store your words into /path/to/.chia/mnemonic.txt.
```
docker run --name <container-name> \
    --volume /path/to/.chia:/root/.chia --volume /path/to/plots:/mnt/chia-plots/final \
    --env keys="/root/.chia/mnemonic.txt" \
    -d gldecurtins/chia-docker:latest
```

Status from outside the container
```
docker exec -it <container-name> venv/bin/chia show -s -c
```

