# HDFS/Spark Local Development Setup

This repository provides the installation instructions for
* OpenJDK 14
* Hadoop 2.10.1,
* Spark 3.0.1 

```
????????? data
????????? Makefile
????????? src
????????? tools
    ????????? hadoop-2.10.1
    ????????? spark-3.0.1-bin-without-hadoop
```
* Makefile. Used for running various tasks such as starting up the hadoop/spark, running interactive shells for spark/hadoop etc.
* src/ directory. Contains git repositories with various spark applications.
* tools/ directory. Contains hadoop/spark binaries.
* data/ directory contains HDFS data and spark-rdd data.

## Usage

Clone this repository into the folder where you want to create your HDFS/Spark setup:

```
mkdir -p ~/Workspace/hadoop-spark && cd ~/Workspace/hadoop-spark
git clone https://github.com/earthquakesan/hdfs-spark-hive-dev-setup ./
```

### Install Make

```
sudo apt-get install build-essential
```

### Install OpenJDK 14

```
make install_java
```

### Configure OpenJDK 14

```
export JAVA_HOME=/usr/lib/jvm/java-14-openjdk-amd64
export PATH=/usr/lib/jvm/java-14-openjdk-amd64/bin
echo $JAVA_HOME
echo $PATH
export PATH="/usr/bin:$PATH"
```

### Download HDFS/Spark binaries

```
make download
```

After this step you should have tools/ folder with the following structure:
```
????????? tools
    ????????? hadoop-3.3.0
    ????????? spark-3.0.1-bin
```

### Configure HDFS/Spark
```
make configure
```

### Start HDFS
Start hadoop DFS (distributed file system), basically 1 namenode and 1 datanode:
```
make start_hadoop
```

Open your browser and go to localhost:50070. If you can open the page and see 1 datanode registered on your namenode, then hadoop setup is finished.

### Start Spark
Start local Spark cluster:
```
make start_spark
```

Open your browser and go to localhost:8080. If you can open the page and see 1 spark-worker registered with spark-master, then spark setup is finished.

### Stopping HDFS/Spark
To stop HDFS:
```
make stop_hadoop
```

To stop Spark:
```
make stop_spark
```
