#!/bin/bash

NKN_DIR="/var/lib/nkn"
NKN_COMMERCIAL_DIR="$NKN_DIR/nkn-commercial"
NKN_LOG_DIR="$NKN_DIR/Log"

# 受益地址 填到 /root/nkn_beneficiary_addr 文件中 不要有空格 和换行
# 格式错误 或者 地址错误 使用 脚本作者的地址
# BENEFICIARY_ADDR=`cat /root/nkn_beneficiary_addr`

# 改为 参数形式 如 ./nkn.sh NKNV4hbx3QfFQgrGbxzBMt7LeeDfQ3toBeMJ http://34.99.99.99/ChainDB.tar.gz
BENEFICIARY_ADDR=$1
CHAINDB_PATH=$2


if [ ${#BENEFICIARY_ADDR} != 36 ];then
    BENEFICIARY_ADDR="NKNV4hbx3QfFQgrGbxzBMt7LeeDfQ3toBeMJ"
fi
echo $BENEFICIARY_ADDR

# if [ ! -d "$NKN_DIR/ChainDB" ]; then
#   mkdir -p /root/db_bakup
#   mv $NKN_DIR/ChainDB /root/db_bakup/ChainDB
# fi

rm -rf $NKN_DIR #将目录及以下之档案亦逐一删除。即使原档案属性设为唯读，亦直接删除，无需逐一确认。

mkdir -p $NKN_COMMERCIAL_DIR #创建目录

#step 1
apt-get update -qq #重新获取软件包列表。不输出信息，错误除外。
apt-get install -y unzip net-tools psmisc git htop nano haveged supervisor nginx
#step 1

#step 1.2
cd /root
wget -O - CHAINDB_PATH -q | tar -xzf - 
#step 1.2

# step 2.1 (nkn config.mainnet.json)
cd $NKN_DIR
wget https://raw.githubusercontent.com/nknorg/nkn/master/config.mainnet.json
mv config.mainnet.json config.json
# step 2.1

# step 2.2 (nkn-commercial)

cd $NKN_COMMERCIAL_DIR

wget -N https://commercial.nkn.org/downloads/nkn-commercial/linux-amd64.zip
sleep 1
unzip linux-amd64.zip
mv linux-amd64/nkn-commercial ./
rm -rf linux-amd64.zip linux-amd64
# step 2.2

cat <<EOF > /tmp/config.json
{
  "beneficiaryAddr": "$BENEFICIARY_ADDR",
  "dataDir": "$NKN_COMMERCIAL_DIR",
  "nkn-node": {
    "args": "--chaindb $NKN_DIR/ChainDB --log $NKN_DIR/Log --config $NKN_DIR/config.json"
  }
}
EOF

mv /tmp/config.json $NKN_COMMERCIAL_DIR/config.json

# step 2.2 (nkn-commercial)


# step 2.x (ChainDB)
if [ -d "/root/ChainDB" ]; then
  mv /root/ChainDB $NKN_DIR/ChainDB
fi
# step 2.x


# step 2.3 (nkn-commercial install)
cd $NKN_COMMERCIAL_DIR
$NKN_COMMERCIAL_DIR/nkn-commercial install
# step 2.3

exit 0
