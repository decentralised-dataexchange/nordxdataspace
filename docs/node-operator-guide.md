# User manual for node operators or stewards

*This is a user manual towards administrators of NordXDataSpace node operators or stewards to manage and operate Indy ledger networks*.

# Table of contents

[TOC]

# 1.0 Prerequisites

## 1.1	Reference deployment 

The proposed initial reference deployment of the NordXDataSpace Indy network is as shown below ([Original moqup](https://app.moqups.com/U33NTlc3ixcLlis38rZvb82Jmvym70HF/view/page/aba8d84a2)):

![](nordxdataspace-ledger-deployment.png)

## 1.2	Node requirements

* Ubuntu 16.04
* 1 CPU
* 4GB Memory
* 30GB+ Storage
* Ports 9701 and 9702 exposed
* Static IP address

## 1.3 Creating the Indy user

Before setting up the validator node, we need to create an `indy` non-root sudo user without a password.

1. Login to the server as the root user
    * `ssh root@&lt;server-public-ip>`
2. `sudo adduser indy`
3. `sudo usermod -aG sudo indy.`
4. `sudo mkdir /home/indy/.ssh`
5. `sudo chown indy:indy /home/indy/.ssh`
6. `sudo vim /home/indy/.ssh/authorized_keys`
7. Paste the public keys that should have access to this user and save it (`:wq`)
8. `sudo chown indy:indy /home/indy/.ssh/authorized_keys`
9. Open the sudo config file `sudo visudo ` and add the following line to the end of the file
    * `indy ALL=(ALL) NOPASSWD:ALL`


# 2.0 Add node to the existing pool

## 2.1 Installing the node

1. Sign in as the root user on the server
    * `ssh root@&lt;server-public-ip>`
2. Run the following commands
    * `apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 68DB5E88`
    * `echo "deb https://repo.sovrin.org/deb xenial stable" >> /etc/apt/sources.list`
    * `apt-get update -y && sudo apt-get install -y indy-node libsodium18`
    * `apt-key adv --keyserver keyserver.ubuntu.com --recv-keys CE7709D068DB5E88`
    * `add-apt-repository "deb https://repo.sovrin.org/sdk/deb xenial stable"`
    * `apt update -y`
    * `apt install indy-cli`
    * `rm -r /etc/indy /var/lib/indy`
    * `exit`
3. Sign in as the indy user on the server
    * `ssh indy@&lt;server-public-ip>`
4. Run the following commands
    * `create_dirs.sh`
    * `vim /etc/indy/indy_config.py`
        * Update the `NETWORK_NAME` to `NETWORK_NAME = "sandbox"`
    * `init_indy_keys --name &lt;alias> --seed &lt;seed>`
        * Replace `&lt;seed>` with the Validator node seed generated in section 2.
        * Replace `&lt;alias>` with the Validator alias
        * Store the output of the command. The seed in the output should be protected from disclosure
    * `vim /var/lib/indy/sandbox/domain_transactions_genesis`
        * Paste the contents of [https://raw.githubusercontent.com/L3-iGrant/datawallet-metadata/main/domain_transactions_genesis](https://raw.githubusercontent.com/L3-iGrant/datawallet-metadata/main/domain_transactions_genesis)
    * `vim /var/lib/indy/sandbox/pool_transactions_genesis`
        * Paste the contents of [https://raw.githubusercontent.com/L3-iGrant/datawallet-metadata/main/pool_transactions_genesis](https://raw.githubusercontent.com/L3-iGrant/datawallet-metadata/main/pool_transactions_genesis)
5. Start the indy cli (by running `indy-cli`) and execute the following commands
    * `wallet create &lt;name> key=&lt;steward-wallet-key>`
        * Replace `&lt;name>` with any name, make sure to write down
        * Replace `&lt;steward-wallet-key>` with the Steward wallet key generated in section 2.
    * `wallet open &lt;name> key=&lt;steward-wallet-key>`
    * `pool create sandbox gen_txn_file=/var/lib/indy/sandbox/pool_transactions_genesis`
    * `pool connect sandbox`
    * `did new seed=&lt;steward-key-seed>`
        * Replace `&lt;steward-key-seed>` with the Steward key seed generated in section 2.
        * Store the output of the command. The did and verkey are your steward did and verkey


## 2.2. Registering the steward DID

Steward DID created in the last step of the previous section must be registered to the ledger. Provide iGrant.io trustee with steward DID and verkey. You will be notified through email or other out-of-band communication methods that the DID is registered to the ledger.


## 2.3 Add node to the pool

Once the steward has been added to the ledger, we can add the validator node and start the node.

1. Sign in as the indy user on the server
    * `ssh indy@&lt;server-public-ip>`
2. Start the indy cli (by running `indy-cli`) and execute the following commands
    * `wallet create &lt;name> key=&lt;steward-wallet-key>`
    * `wallet open &lt;name> key=&lt;steward-wallet-key>`
        * Replace `&lt;name>` and `&lt;steward-wallet-key>` with the values used when the wallet was created
    * `pool connect sandbox`
    * `did use &lt;steward-did>`
        * Replace `&lt;steward-did>` with the steward did
    * `ledger node target=&lt;validator-verkey> node_ip=&lt;node-public-ip> node_port=9701 client_ip=&lt;node-public-ip> client_port=9702 alias=&lt;validator-alias> services=VALIDATOR blskey=&lt;bls-public-key> blskey_pop=&lt;bls-proof-of-possesion>`
        * Replace `&lt;validator-verkey>` with the value of `Verification key is &lt;validator-verkey>` from the `init_indy_keys` command
        * Replace `&lt;node-public-id>` with the public ip of the node
        * Replace `&lt;validator-alias>` with the value of `Node-stack name is &lt;validator-alias>` from the `init_indy_keys` command
        * Replace `&lt;bls-public-key>` with the value of `BLS Public key is &lt;bls-public-key>` from the `init_indy_keys` command
        * Replace `&lt;bls-proof-of-possesion>` with the value of `Proof of possession for BLS key is &lt;bls-proof-of-possesion>` from the `init_indy_keys` command
    * `exit` - to exit from the indy-cli
3. Run the following commands to start the node
    * `vim /etc/indy/indy.env`
        * Paste the contents of the Indy Environment File in section 3.5.1
    * `vim /etc/indy/node_control.conf`
        * Paste the contents of the Indy Node Control Configuration file in section 3.5.2
    * `vim /etc/systemd/system/indy-node.service`
        * Change the `User` and `Group` to the ssh username.
        * This is only needed if you don’t use the `indy` user as described in section 1.1 (default is `indy`)
    * `sudo systemctl enable indy-node-control.service`
    * `sudo systemctl start indy-node-control.service`
    * `sudo systemctl enable indy-node.service`
    * `sudo systemctl start indy-node.service`

## 2.4 Check if the node is up and running

1. Check if the log file exists
    * `cat /var/log/indy/sandbox/&lt;validator-alias>.log`
        * Replace `&lt;validator-alias>` with the value of `Node-stack name is &lt;validator-alias>` from the `init_indy_keys` command
        * Make sure to check for the `connections changed from` and `updated validators list to` lines (using e.g. grep)
2. Check the status of the validator node
    * `sudo validator-info`
    * You should see your node as part of the `Reachable Hosts`
3. Get the updated pool genesis transactions file
    * `read_ledger --type pool`

# 3.0 Pool upgrade guideline

The whole pool (that is each node in the pool) can be upgraded automatically without any manual actions via `POOL_UPGRADE` transaction.

As a result of upgrade, each Node will be at the specified version, that is, a new package, for example, deb package, will be installed.

Migration scripts can also be performed during the upgrade to deal with breaking changes between the versions.

## 3.1 Pool Upgrade Transaction

* Pool Upgrade is done via the `POOL_UPGRADE` transaction.
* The txn defines a schedule of upgrade (upgrade time) for each node in the pool.
* Only the `TRUSTEE` can send `POOL_UPGRADE`.
* This is a common transaction (written to config ledger), so the consensus is required.
* There are two main modes for `POOL_UPGRADE`: forced and non-forced (default).
    * Non-forced mode schedules upgrade only after `POOL_UPGRADE` transaction is written to the ledger; that is there was a consensus. Forced upgrade schedules upgrade for each node regardless of whether `POOL_UPGRADE` transaction is actually written to the ledger, that is it can be scheduled even if the pool lost consensus.
    * Non-forced mode requires that upgrade of each node is done sequentially and not at the same time (so that a pool is still working and can reach consensus during the upgrade). On the other hand, the forced upgrade allows the upgrade of the whole pool at the same time.
* One should usually use non-forced Upgrades assuming that all changes are backward-compatible.
* If there are non-backward-compatible (breaking) changes, then one needs to use forced Upgrade and make it happen at the same time on all nodes (see below).

## 3.2 Node Upgrade Transaction
* Each node sends `NODE_UPGRADE` transaction twice:
    * `in_progress` action: just before start of the Upgrade (that is re-starting the node and applying a new package) to log that Upgrade started on the node.
    * `success` or `fail` action: after upgrading the node to log the upgrade result.
* `NODE_UPGRADE` transaction is a common transaction (written to config ledger), so consensus is required.


## 3.3 Node Control Tool

* Upgrade is performed by a `node-control-tool`.
* See <code>[node_control_tool.py](https://github.com/hyperledger/indy-node/blob/main/docs/indy_node/utils/node_control_tool.py)</code>.
* On Ubuntu it's installed as a systemd service (<code>indy-node-control</code>) in addition to the node service (<code>indy-node</code>).
* <code>indy-node-control</code> is executed from the <code>root</code> user.
* When upgrade time for the node comes, it sends a message to node-control-tool.
* The node-control-tool then does the following:
    * stops <code>indy-node</code> service;
    * upgrades <code>indy-node</code> package (<code>apt-get install</code> on Ubuntu);
    * back-ups node data (ledger, etc.);
    * runs migration scripts (see <code>[migration_tool.py](https://github.com/hyperledger/indy-node/blob/main/docs/indy_node/utils/migration_tool.py)</code>);
    * starts <code>indy-node</code> service;
    * restarts <code>indy-node-control</code> service.
* If an upgrade fails for some reason, node-control-tool tries to restore the data (ledger) from back-up and revert to the version of the code before upgrade.

## 3.4 Migrations

* Although we must try keeping backward-compatibility between the versions, it may be possible that there are some (for example, changes in ledger and state data format, re-branding, etc.).
* We can write migration scripts to support this kind of breaking changes and perform necessary steps for data migration and/or running some scripts.
* The migration should go to the `data/migration` folder under the package name (so this is `data/migration/deb` on Ubuntu).

## 3.5 When to Run Forced Upgrades

* Any changes in Ledger transactions format leading to changes in transactions root hash.
* Any changes in State transactions format (for example new fields added to State values) require re-creation of the state from the ledger.
* Any changes in Requests/Replies/Messages without compatibility and versioning support.

# Commonly asked questions

1. How do we or the owner of the node manage new SW updates? 

   (Covered in Chapter 3)

2. What is expected of them from an operational point of view?  

   (Covered in Chapter 1 & Chapter 2)

