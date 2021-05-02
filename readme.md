# Fork of the official Chia Docker container

## Basic Startup
```
docker run --name <container-name> -d ghcr.io/gldecurtins/chia-docker:latest -e start="farmer"
(optional -v /path/to/plots:plots)
```

## Configuration

You can modify the behavior of your Chia container by setting specific environment variables. By default it initializes the chia network only but doesn't start anything.

To use your own keys pass as arguments on startup
```
-v /path/to/mnemonic.txt:/root/.chia/mnemonic.txt -e keys="/root/.chia/mnemonic.txt"
```

Possible start environment values are [all|node|harvester|farmer|farmer-no-wallet|farmer-only|timelord|timelord-only|timelord-launcher-only|wallet|wallet-only|introducer|simulator]

To start a farmer only node pass
```
-e start="farmer"
```

To start a harvester only node pass
```
-e start="harvester" -e farmer_address="addres.of.farmer" -e farmer_port="portnumber"
```

#### or run commands externally with venv (this works for most chia XYZ commands)
```
docker exec -it chia venv/bin/chia plots add -d /plots
```

#### status from outside the container
```
docker exec -it chia venv/bin/chia show -s -c
```

#### Connect to testnet?
```
docker run -d --expose=58444 --expose=8555 -e testnet=true --name <container-name> ghcr.io/chia-network/chia:latest
```

#### Need a wallet?
```
docker exec -it chia-farmer1 venv/bin/chia wallet show (follow the prompts)
```
