# Chia Docker container

## Basic Startup
```
docker run --name <container-name> -d gldecurtins/chia-docker:latest
(optional -v /path/to/plots:plots)
```

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

To use your own keys pass as arguments on startup
```
-v /path/to/mnemonic.txt:/root/.chia/mnemonic.txt -e keys="/root/.chia/mnemonic.txt"
```

To start a farmer only node pass
```
-e start="farmer"
```

To start a harvester only node pass
```
-e start="harvester" -e farmer_address="addres.of.farmer" -e farmer_port="portnumber"
```

Run commands externally with venv (this works for most chia XYZ commands)
```
docker exec -it <container-name> venv/bin/chia plots add -d /plots
```

Status from outside the container
```
docker exec -it <container-name> venv/bin/chia show -s -c
```

Connect to testnet
```
docker run -d -e testnet=true --name <container-name> gldecurtins/chia-docker:latest
```

Need a wallet?
```
docker exec -it <container-name> venv/bin/chia wallet show (follow the prompts)
```
