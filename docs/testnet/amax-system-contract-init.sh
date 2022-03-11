
# ref:
# https://developers.eos.io/welcome/v2.0/tutorials/bios-boot-sequence

# should install amax to local

## prepare system contracts
sys_contracts_dir="${PWD}/contracts"
if [[ ! -f "${sys_contracts_dir}/amax.system/amax.system.wasm" ]];
then
  wget https://github.com/armoniax/amax.releases/raw/main/amax.contracts/v0.1.0/amax_contracts_0.1.0-1.tar.gz
  tar -vxf amax_contracts_0.1.0-1.tar.gz
  rm amax_contracts_0.1.0-1.tar.gz
fi



## unlock local wallet
amcli wallet unlock --password $(cat "${HOME}/amax-wallet/default.password.txt")

## import amax account private key
# ...

# connect to remote node
ssh -L 8888:127.0.0.1:8888 -C -N testnet.amaxscan.io &
## test node
amcli get info

## Create important system accounts
sys_accounts=(
amax.bpay
amax.msig
amax.names
amax.ram
amax.ramfee
amax.saving
amax.stake
amax.token
amax.vpay
amax.rex
)

for acct in "${sys_accounts[@]}"; do
  amcli create account amax $acct AM5SuwLEfX8GBFhBYryH98a7dbgpTV8BBPojH2m8wr7yT3hks5iH -p amax@active
done


###########################
# deploy the amax.token contract
amcli set contract amax.token ${sys_contracts_dir}/amax.token/ -p amax.token@active
## Create and allocate the SYS currency = AMAX
amcli push action amax.token create '[ "amax", "1000000000.0000 AMAX" ]' -p amax.token@active
## issue
amcli push action amax.token issue '[ "amax", "1000000000.0000 AMAX", "" ]' -p amax@active

###########################
## Enable Features

# GET_SENDER
amcli system activate "f0af56d2c5a48d60a4a5b5c903edfb7db3a736a94ed589d0b797df33ff9d3e1d" -p amax

# FORWARD_SETCODE
amcli system activate "2652f5f96006294109b3dd0bbde63693f55324af452b799ee137a81a905eed25" -p amax

# ONLY_BILL_FIRST_AUTHORIZER
amcli system activate "8ba52fe7a3956c5cd3a656a3174b931d3bb2abb45578befc59f283ecd816a405" -p amax

# RESTRICT_ACTION_TO_SELF
amcli system activate "ad9e3d8f650687709fd68f4b90b41f7d825a365b02c23a636cef88ac2ac00c43" -p amax

# DISALLOW_EMPTY_PRODUCER_SCHEDULE
amcli system activate "68dcaa34c0517d19666e6b33add67351d8c5f69e999ca1e37931bc410a297428" -p amax

 # FIX_LINKAUTH_RESTRICTION
amcli system activate "e0fb64b1085cc5538970158d05a009c24e276fb94e1a0bf6a528b48fbc4ff526" -p amax

 # REPLACE_DEFERRED
amcli system activate "ef43112c6543b88db2283a2e077278c315ae2c84719a8b25f25cc88565fbea99" -p amax

# NO_DUPLICATE_DEFERRED_ID
amcli system activate "4a90c00d55454dc5b059055ca213579c6ea856967712a56017487886a4d4cc0f" -p amax

# ONLY_LINK_TO_EXISTING_PERMISSION
amcli system activate "1a99a59d87e06e09ec5b028a9cbb7749b4a5ad8819004365d02dc4379a8b7241" -p amax

# RAM_RESTRICTIONS
amcli system activate "4e7bf348da00a945489b2a681749eb56f5de00b900014e137ddae39f48f69d67" -p amax

# WEBAUTHN_KEY
amcli system activate "4fca8bd82bbd181e714e283f83e1b45d95ca5af40fb89ad3977b653c448f78c2" -p amax

# WTMSIG_BLOCK_SIGNATURES
amcli system activate "299dcb6af692324b899b39f16d5a530a33062804e41f09dc97e9f156b4476707" -p amax


## Set the amax.bios contract
amcli set contract amax ${sys_contracts_dir}/amax.system -p amax@active


## amax.msig
amcli set contract amax.msig ${sys_contracts_dir}/amax.msig -p amax.msig@active
## Designate amax.msig as privileged account
amcli push action amax setpriv '["amax.msig", 1]' -p amax@active

#############################
# Initialize system account
# To initialize the system account with code zero (needed at initialization time) and SYS token with precision 4; precision can range from [0 .. 18]:
amcli push action amax init '["0", "4,AMAX"]' -p amax@active


