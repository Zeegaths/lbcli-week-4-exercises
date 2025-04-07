# What is the locking script in this transaction
# transaction="0200000001d54e767769b3c3b8707115f748c88f7323def5b78147628aa071fdcf2fdf7379000000006a47304402207883e621fb279d18902986836e89ebe77c13b39e7c9141d0c8b81274a98245d502204d3ffc75ae16b8d3e5918f078075cb2afb180828d910f0feaf090cd74d805ca4012103fdee3ce1c3ca71b5e9eb846147ff5d26f499ef2f12f84b34de46b3dcf228df55fdffffff0180e0d211010000001976a914d5391484579a9760f87c9772035248325aabe01f88ac00000000"
#!/bin/bash

# Original transaction that contains our UTXOs
transaction="01000000000101c8b0928edebbec5e698d5f86d0474595d9f6a5b2e4e3772cd9d1005f23bdef772500000000ffffffff0276b4fa0000000000160014f848fe5267491a8a5d32423de4b0a24d1065c6030e9c6e000000000016001434d14a23d2ba08d3e3edee9172f0c97f046266fb0247304402205fee57960883f6d69acf283192785f1147a3e11b97cf01a210cf7e9916500c040220483de1c51af5027440565caead6c1064bac92cb477b536e060f004c733c45128012102d12b6b907c5a1ef025d0924a29e354f6d7b1b11b5a7ddff94710d6f0042f3da800000000"

# Get txid by decoding the transaction
txid=$(bitcoin-cli -regtest decoderawtransaction $transaction | jq -r .txid)

# Define recipient address and message
recipient="2MvLcssW49n9atmksjwg2ZCMsEMsoj3pzUP"
message="btrust builder 2025"

# Define sequence number for locktime signaling (0xffffffff-2 or 4294967293)
sequence=4294967293

# Create raw transaction with:
# 1. OP_RETURN output (created automatically when using "data")
# 2. Payment output
bitcoin-cli -regtest -named createrawtransaction \
  inputs='''[
    {
      "txid": "'$txid'",
      "vout": 0,
      "sequence": '$sequence'
    },
    {
      "txid": "'$txid'",
      "vout": 1,
      "sequence": '$sequence'
    }
  ]''' \
  outputs='''[
    {
      "data": "'$(echo -n $message | xxd -p -u)'"
    },
    {
      "'$recipient'": 0.2
    }
  ]'''