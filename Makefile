mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(dir $(mkfile_path))
hadoop_home := $(addsuffix tools/hadoop-2.10.1, $(current_dir))
spark_home := $(addsuffix tools/spark-3.0.1-bin-without-hadoop, $(current_dir))

#########################################
# Configuration and start/stop commands #
#########################################

download: download_hadoop download_spark 

download_hadoop:
	mkdir -p ${current_dir}tools
	cd ${current_dir}tools; wget https://ftp.cixug.es/apache/hadoop/common/hadoop-2.10.1/hadoop-2.10.1.tar.gz && tar -xvf hadoop-2.10.1.tar.gz && rm -rf hadoop-2.10.1.tar.gz

download_spark:
	mkdir -p ${current_dir}tools
	cd ${current_dir}tools; wget https://ftp.cixug.es/apache/spark/spark-3.0.1/spark-3.0.1-bin-without-hadoop.tgz && tar -xvf spark-3.0.1-bin-without-hadoop.tgz && rm -rf spark-3.0.1-bin-without-hadoop.tgz

install_java:
	#Install OpenJDK
	sudo apt-get update
	sudo apt-get install openjdk-14-jdk

configure: configure_hadoop configure_spark

configure_hadoop:
	#Install Ubuntu dependencies
	sudo apt-get install -y ssh rsync
	#Set JAVA_HOME explicitly
	sed -i "s#.*export JAVA_HOME.*#export JAVA_HOME=${JAVA_HOME}#g" ${hadoop_home}/etc/hadoop/hadoop-env.sh 
	#Set HADOOP_CONF_DIR explicitly
	sed -i "s#.*export HADOOP_CONF_DIR.*#export HADOOP_CONF_DIR=${hadoop_home}/etc/hadoop#" ${hadoop_home}/etc/hadoop/hadoop-env.sh
	#Define fs.default.name in core-site.xml
	sed -i '/<\/configuration>/i <property><name>fs.default.name</name><value>hdfs://localhost:9000</value></property>' ${hadoop_home}/etc/hadoop/core-site.xml
	sed -i '/<\/configuration>/i <property><name>hadoop.tmp.dir</name><value>file://${current_dir}data/hadoop-tmp</value></property>' ${hadoop_home}/etc/hadoop/core-site.xml
	#Set dfs.replication and dfs.namenode.name.dir
	mkdir -p ${current_dir}data/hadoop
	sed -i '/<\/configuration>/i <property><name>dfs.replication</name><value>1</value></property>' ${hadoop_home}/etc/hadoop/hdfs-site.xml
	sed -i '/<\/configuration>/i <property><name>dfs.namenode.name.dir</name><value>file://${current_dir}data/hadoop</value></property>' ${hadoop_home}/etc/hadoop/hdfs-site.xml
	${hadoop_home}/bin/hdfs namenode -format
	ssh-keygen -t dsa -P '' -f ~/.ssh/id_dsa
	cat ~/.ssh/id_dsa.pub >> ~/.ssh/authorized_keys
	chmod 0600 ~/.ssh/authorized_keys
	ssh-add

start_hadoop:
	${hadoop_home}/sbin/start-dfs.sh
stop_hadoop:
	${hadoop_home}/sbin/stop-dfs.sh

configure_spark:
	# Change logging level from INFO to WARN
	cp ${spark_home}/conf/log4j.properties.template ${spark_home}/conf/log4j.properties
	sed -i "s#log4j.rootCategory=INFO, console#log4j.rootCategory=WARN, console#g" ${spark_home}/conf/log4j.properties
	# Set up Spark environment variables
	echo 'export SPARK_LOCAL_IP=127.0.0.1' >> ${spark_home}/conf/spark-env.sh
	echo 'export HADOOP_CONF_DIR="${hadoop_home}/etc/hadoop"'>> ${spark_home}/conf/spark-env.sh
	echo 'export SPARK_DIST_CLASSPATH="$(shell ${hadoop_home}/bin/hadoop classpath)"'>> ${spark_home}/conf/spark-env.sh
	echo 'export SPARK_MASTER_IP=127.0.0.1'>> ${spark_home}/conf/spark-env.sh
	mkdir -p ${current_dir}data/spark-rdd
	echo 'export SPARK_LOCAL_DIRS=${current_dir}data/spark-rdd'

start_spark:
	${spark_home}/sbin/start-all.sh
stop_spark:
	${spark_home}/sbin/stop-all.sh

######################
# Interactive shells #
######################

pyspark:
	IPYTHON=1 ${spark_home}/bin/pyspark
spark_shell:
	${spark_home}/bin/spark-shell


