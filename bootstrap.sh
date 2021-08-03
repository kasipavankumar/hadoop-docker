#!/bin/bash

# 1. Start the SSH server
/etc/init.d/ssh start

# 2. Connect to "localhost" via SSH
# https://askubuntu.com/a/123080
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -t localhost << EOF

  # 3. Source the environment variables dumped in /etc/enviroment
  source /etc/environment

  # 4. Set Hadoop's "sbin" & "bin" in path
  export PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin

EOF

# 3. Format "Namenode"
hdfs namenode -format

# 4. Start all Hadoop services
$HADOOP_HOME/sbin/start-all.sh

# 5. Leave user with the shell
/bin/bash
