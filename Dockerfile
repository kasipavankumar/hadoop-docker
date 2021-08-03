# Ubuntu as the base image
FROM ubuntu:20.04

# Set working directory to /home
WORKDIR /

# Install required dependencies
RUN apt-get update && apt-get install -y \ 
    openjdk-8-jdk \
    openssh-server \
    openssh-client \
    nano \
    && rm -rf /var/lib/apt/lists/*

# Generate SSH key pair for password less login
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa \
    && cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys \
    && chmod 0600 ~/.ssh/authorized_keys

# Download Hadoop 3.3.1
RUN wget https://mirrors.estointernet.in/apache/hadoop/common/hadoop-3.3.1/hadoop-3.3.1.tar.gz

# Unzip the .tar.gz
RUN tar xzf hadoop-3.3.1.tar.gz

# Remove the .tar.gz file
RUN rm ./hadoop-3.3.1.tar.gz

# Hadoop home
ENV HADOOP_HOME=/hadoop-3.3.1

# Other Hadoop environment variables
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

    # For start-all.sh
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

CMD [ "bash", "./bootstrap.sh" ]
