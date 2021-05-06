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
- /plots - plots on storage
- /plotting - fast storage for plotting, add one per device

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
- plots_size - (integer) Default: 32
- plots_num_threads - (integer) Default: 2
- plots_farmer_public_key - (string) Required for plotting, retrieve via *chia keys show*
- plots_pool_public_key - (string) Required for plotting, retrieve via *chia keys show*
- plots_tmp_dir - (string) Default: "/plotting", path to temporary plotting directory
- plots_final_dir - (string) Default: "/plots", path to final plots directory
- plots_options - (string) Can be used to specify plots options like "--nobitfield"
- plots_curl_upload - (string) Default: "false", set to true if curl shall upload file to plots_curl_target
- plots_curl_target - (string) Target for curl, e.g. ftp://anonymous@farmer/plots

### Examples

Plotter startup, prepares the environment without blockchain and keys.
```
docker run --name <container-name> \
    --volume /path/to/plots:/plots --volume /path/to/fast/storage:/plotting \
    --env start="plotter" \
    --env plots_farmer_public_key="" \
    --env plots_pool_public_key="" \
    -d gldecurtins/chia-docker:latest
```

Plotting task has to be triggered manually, output to be found in the plotting directory.
```
docker exec -d <container-name> /usr/local/bin/create_plot.sh
```

Plotting with multiple tasks, using different storage devices. Volumes to be mapped accordingly.
```
docker exec -d <container-name> /usr/local/bin/create_plot.sh /storage1 /plots/storage1
docker exec -d <container-name> /usr/local/bin/create_plot.sh /storage2 /plots/storage2
```

Full node startup on mainnet, generating keys
```
docker run --name <container-name> \
    --volume /path/to/.chia:/root/.chia --volume /path/to/plots:/plots \
    -d gldecurtins/chia-docker:latest
```

Full node startup on testnet, generating keys
```
docker run --name <container-name>  \
    --volume /path/to/.chia:/root/.chia --volume /path/to/plots:/plots \
    --env testnet="true" \
    -d gldecurtins/chia-docker:latest
```

Full node startup on mainnet, use existing keys. E.g. store your words into /path/to/.chia/mnemonic.txt. 
```
docker run --name <container-name> \
    --volume /path/to/.chia:/root/.chia --volume /path/to/plots:/plots \
    --env keys="/root/.chia/mnemonic.txt" \
    -d gldecurtins/chia-docker:latest
```

Run commands externally with venv (this works for most chia XYZ commands)
```
docker exec -it <container-name> venv/bin/chia plots add -d /plots
```

Status from outside the container
```
docker exec -it <container-name> venv/bin/chia show -s -c
```
