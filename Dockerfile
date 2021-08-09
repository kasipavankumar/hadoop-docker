# Ubuntu as the base image
FROM ubuntu:20.04

LABEL author="D. Kasi Pavan Kumar <devdkpk@gmail.com>"
LABEL version="1.0.2"

# Set working directory to /
WORKDIR /

# Install required dependencies
RUN apt-get update && apt-get install --yes --no-install-recommends \ 
    openjdk-8-jdk \
    openssh-server \
    openssh-client \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Generate SSH key pair for password less login
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa \
    && cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys \
    && chmod 0600 ~/.ssh/authorized_keys

# Set HADOOP_HOME variable
ENV HADOOP_HOME=/hadoop-3.3.1

# Other Hadoop variables
ENV HADOOP_INSTALL=${HADOOP_HOME} \
    HADOOP_MAPRED_HOME=${HADOOP_HOME} \
    HADOOP_COMMON_HOME=${HADOOP_HOME} \
    HADOOP_HDFS_HOME=${HADOOP_HOME} \
    YARN_HOME=${HADOOP_HOME} \
    HADOOP_COMMON_LIB_NATIVE_DIR=${HADOOP_HOME}/lib/native \
    PATH=$PATH:${HADOOP_HOME}/sbin:${HADOOP_HOME}/bin \
    HADOOP_OPTS="-Djava.library.path=${HADOOP_HOME}/lib/nativ" \
    # Java home
    JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/ \
    # For staring Hadoop services using `start-all.sh`
    HDFS_NAMENODE_USER="root" \
    HDFS_DATANODE_USER="root" \
    HDFS_SECONDARYNAMENODE_USER="root" \
    YARN_RESOURCEMANAGER_USER="root" \
    YARN_NODEMANAGER_USER="root"

# Dump environment variables since connecting 
# to localhost via SSH wipes them out
RUN env | grep _ >> /etc/environment

# Copy Hadoop configuration files to the "etc" directory
COPY /etc/* ${HADOOP_HOME}/etc/hadoop/

# Copy bootstrap.sh
COPY ./bootstrap.sh /

# Download Hadoop 3.3.1
RUN wget -qO- https://mirrors.estointernet.in/apache/hadoop/common/hadoop-3.3.1/hadoop-3.3.1.tar.gz | tar xvz \
    && apt-get remove --yes wget \
    && apt-get autoremove --yes

CMD [ "bash", "./bootstrap.sh" ]
