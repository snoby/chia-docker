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

## Scripts

### chia_update.sh
Bash shell script to fetch the latest version of chia-blockchain.
If there is a new version, then the official install.sh script will be executed.

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

## Lessons learned

1. I prefer executing the plotting outside of the Docker container, as the mapped Volumes offer degraded performance. Is there a better way to map the folders?
2. To prevent the Apple M1 Mac from sleep I use caffeinate.
3. Executing the scripts via cron requires [extra permissions on Mac OS](https://osxdaily.com/2020/04/27/fix-cron-permissions-macos-full-disk-access/).
4. I had to use *docker buildx* to create the arm64 version. Docker Hub does not easily create arm64 images.
5. I should try to keep the Docker ENV stable - but sometimes the variable names just do not add up.
6. Executing the scripts via cron on Mac OS X is very slow as it will run with Background priority. Use launchd instead and set ProcessType to Interactive.
7. Uploading via ftp seems the most reliable to me, curlftpfs didn't work and is more complicated to setup.