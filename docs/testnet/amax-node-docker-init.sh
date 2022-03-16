
# base on ubuntu:18.04
docker pull ubuntu:18.04

# ENV
root_dir=/opt/docker-instances/amax/amax-test

# make dir
sudo mkdir -p ${root_dir}
sudo chown devops:devops ${root_dir}
cd ${root_dir}

mkdir -p ${root_dir}/bin

# get amax bin
cd ${root_dir}
if [[ ! -f ${root_dir}/bin/amnod ]];
then
  mkdir -p tmp ; cd tmp
  wget https://github.com/armoniax/amax.releases/raw/main/amax.chain/v0.1.0/amax_0.1.0-1_amd64.tar.gz
  tar -vxf amax_0.1.0-1_amd64.tar.gz
  cp usr/bin/* ${root_dir}/bin/
  cd .. && rm -r tmp
fi

# make config dir
mkdir -p ${root_dir}/config

# input privkey
amax_pubkey="Input pubkey here"
amax_privkey="Input privkey here"
[[ "X${amax_privkey}" == "XInput privkey here" ]] && echo "Please set the amax_privkey" && exit 1

# make config.ini
cat <<EOF > ${root_dir}/config/config.ini
# clear chain state database, recover as many blocks as possible from the block log, and then replay those blocks
# hard-replay-blockchain = true

plugin = eosio::chain_api_plugin
plugin = eosio::history_plugin
plugin = eosio::history_api_plugin
plugin = eosio::http_plugin
plugin = eosio::net_plugin
plugin = eosio::net_api_plugin
plugin = eosio::producer_plugin
plugin = eosio::producer_api_plugin

abi-serializer-max-time-ms = 5000

enable-stale-production = true
producer-name = amax
signature-provider = ${amax_pubkey}=KEY:${amax_privkey}

read-mode = speculative
p2p-accept-transactions = true
api-accept-transactions = true

p2p-listen-endpoint = 0.0.0.0:9876
p2p-server-address = 0.0.0.0:9876   # modify it to external IP or domain
http-server-address = 0.0.0.0:8888

# p2p-peer-address =

chain-state-db-size-mb = 655360
reversible-blocks-db-size-mb = 65536
contracts-console = false

# http_plugin
http-max-response-time-ms = 1000
access-control-allow-origin = *
http-validate-host = false
verbose-http-errors = true

# history_plugin
filter-on = *
EOF

cat <<EOF > ${root_dir}/config/genesis.json
{
  "initial_timestamp": "2022-03-06T12:00:00.000",
  "initial_key": "${amax_pubkey}",
  "initial_configuration": {
    "max_block_net_usage": 1048576,
    "target_block_net_usage_pct": 1000,
    "max_transaction_net_usage": 524288,
    "base_per_transaction_net_usage": 12,
    "net_usage_leeway": 500,
    "context_free_discount_net_usage_num": 20,
    "context_free_discount_net_usage_den": 100,
    "max_block_cpu_usage": 200000,
    "target_block_cpu_usage_pct": 10000,
    "max_transaction_cpu_usage": 150000,
    "min_transaction_cpu_usage": 100,
    "max_transaction_lifetime": 3600,
    "deferred_trx_expiration_window": 600,
    "max_transaction_delay": 3888000,
    "max_inline_action_size": 4096,
    "max_inline_action_depth": 4,
    "max_authority_depth": 6
  }
}
EOF

# make amnod.init.sh
cat <<EOF > ${root_dir}/bin/amnod.init.sh
#!/bin/bash
if [[ ! -f /root/amax.init ]]; then
  touch /root/amax.init
  echo "Init amnod env"
  echo "export PATH=\$PATH:/opt/amax/bin" >> /root/.bashrc
  source /root/.bashrc
  apt update
  apt install -y openssl
fi
EOF

chmod a+x ${root_dir}/bin/amnod.init.sh

# make run-amax-test.sh
cat <<EOF > ${root_dir}/run-amax-test.sh
#!/bin/bash
docker run  \
--name amax-test \
-p 9806:9806 -p 8888:8888 \
-v ${root_dir}/bin:/opt/amax/bin \
-v ${root_dir}/data:/opt/data \
-v ${root_dir}/config:/opt/config \
-v ${root_dir}/wallet:/root/amax-wallet \
-dit ubuntu:18.04 bash -c '
[[ ! -f /opt/data/blocks/blocks.index ]] && export MORE_OPTIONS="--genesis-json=/opt/config/genesis.json" ;
source /opt/amax/bin/amnod.init.sh ;
/opt/amax/bin/amnod --data-dir /opt/data --config-dir /opt/config \${MORE_OPTIONS}
'
EOF
chmod a+x ${root_dir}/run-amax-test.sh

# run run-amax-test.sh
cd ${root_dir}
${root_dir}/run-amax-test.sh

