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
- /plotting - fast storage for plotting

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

### Examples

Plotter startup, prepares the environment without blockchain and keys. Plotting task has to be triggered manually.
```
docker run --name <container-name> -d gldecurtins/chia-docker:latest \
    --volume /path/to/plots:/plots --volume /path/to/fast/storage:/plotting \
    --env start="plotter"
```

Full node startup on mainnet, generating keys
```
docker run --name <container-name> -d gldecurtins/chia-docker:latest \
    --volume /path/to/.chia:/root/.chia --volume /path/to/plots:/plots 
```

Full node startup on testnet, generating keys
```
docker run --name <container-name> -d gldecurtins/chia-docker:latest \
    --volume /path/to/.chia:/root/.chia --volume /path/to/plots:/plots \
    --env testnet="true" 
```

Full node startup on mainnet, use existing keys. E.g. store your words into /path/to/.chia/mnemonic.txt. 
```
docker run --name <container-name> -d gldecurtins/chia-docker:latest \
    --volume /path/to/.chia:/root/.chia --volume /path/to/plots:/plots \
    --env keys="/root/.chia/mnemonic.txt" 
```

Run commands externally with venv (this works for most chia XYZ commands)
```
docker exec -it <container-name> venv/bin/chia plots add -d /plots
```

Status from outside the container
```
docker exec -it <container-name> venv/bin/chia show -s -c
```
