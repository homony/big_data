#!/bin/bash
sudo apt-get update -y
sudo apt install openjdk-11-jdk -y
echo JAVA_HOME=\"/usr/lib/jvm/java-11-openjdk-amd64/\" >> /etc/environment
source /etc/environment
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export HADOOP_INSTALL=/usr/local/hadoop
export PATH=$PATH:$HADOOP_INSTALL/bin
export PATH=$PATH:$HADOOP_INSTALL/sbin
export HADOOP_MAPRED_HOME=$HADOOP_INSTALL
export HADOOP_COMMON_HOME=$HADOOP_INSTALL
export HADOOP_HDFS_HOME=$HADOOP_INSTALL
export YARN_HOME=$HADOOP_INSTALL
export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_INSTALL/lib/native
export HADOOP_OPTS="-Djava.library.path=$HADOOP_INSTALL/lib"
export HADOOP_PREFIX=$HADOOP_INSTALL
export HADOOP_CONF_DIR=$HADOOP_PREFIX/etc/hadoop
export SSH_OPTS="-o StrictHostKeyChecking=no"
sudo apt-get install openssh-server -y
yes "" | ssh-keygen -t rsa -P ""
cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys
ssh-keyscan -H localhost >> ~/.ssh/known_hosts
ssh-keyscan -H 0.0.0.0 >> ~/.ssh/known_hosts
sudo systemctl restart ssh
wget https://downloads.apache.org/hadoop/common/hadoop-2.10.2/hadoop-2.10.2.tar.gz
tar -zxvf hadoop-2.10.2.tar.gz
rm -rf hadoop-2.10.2.tar.gz
mkdir /usr/local/hadoop
mv hadoop-2.10.2/* /usr/local/hadoop/
rm -rf hadoop-2.10.2
echo -e "export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export HADOOP_INSTALL=/usr/local/hadoop
export PATH=\$PATH:\$HADOOP_INSTALL/bin
export PATH=\$PATH:\$HADOOP_INSTALL/sbin
export HADOOP_MAPRED_HOME=\$HADOOP_INSTALL
export HADOOP_COMMON_HOME=\$HADOOP_INSTALL
export HADOOP_HDFS_HOME=\$HADOOP_INSTALL
export YARN_HOME=\$HADOOP_INSTALL
export HADOOP_COMMON_LIB_NATIVE_DIR=\$HADOOP_INSTALL/lib/native
export HADOOP_OPTS=\"-Djava.library.path=\$HADOOP_INSTALL/lib\"
export HADOOP_PREFIX=\$HADOOP_INSTALL
export HADOOP_CONF_DIR=\$HADOOP_PREFIX/etc/hadoop" >> /root/.bashrc
mkdir -p /usr/local/hadoop_store/hdfs
cd /usr/local/hadoop_store/hdfs
mkdir namenode
mkdir datanode
echo -n > /usr/local/hadoop/etc/hadoop/hdfs-site.xml
echo -e "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>
<configuration>
<property>
<name>dfs.replication</name>
<value>1</value>
<description>Default block replication.</description>
</property>
<property>
<name>dfs.permissions</name>
<value>false</value>
</property>
<property>
<name>dfs.namenode.name.dir</name>
<value>file:/usr/local/hadoop_store/hdfs/namenode</value>
</property>
<property>
<name>dfs.datanode.data.dir</name>
<value>file:/usr/local/hadoop_store/hdfs/datanode</value>
</property>
</configuration>" >> /usr/local/hadoop/etc/hadoop/hdfs-site.xml
mkdir -p /app/hadoop/tmp
echo -n > /usr/local/hadoop/etc/hadoop/core-site.xml
echo -e "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>
<configuration>
<property>
<name>hadoop.tmp.dir</name>
<value>/app/hadoop/tmp</value>
<description>A base for other temporary directories.</description>
</property>
<property>
<name>fs.default.name</name>
<value>hdfs://localhost:54310</value>
<description>The name of the default file system.</description>
</property>
</configuration>" >> /usr/local/hadoop/etc/hadoop/core-site.xml
cp /usr/local/hadoop/etc/hadoop/mapred-site.xml.template /usr/local/hadoop/etc/hadoop/mapred-site.xml
echo -n > /usr/local/hadoop/etc/hadoop/mapred-site.xml
echo -e "<?xml version=\"1.0\"?>
<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>
<configuration>
<property>
<name>mapreduce.framework.name</name>
<value>yarn</value>
</property>
</configuration>" >> /usr/local/hadoop/etc/hadoop/mapred-site.xml
echo -n > /usr/local/hadoop/etc/hadoop/yarn-site.xml
echo -e "<?xml version=\"1.0\"?>
<configuration>
<property>
<name>yarn.nodemanager.aux-services</name>
<value>mapreduce_shuffle</value>
</property>
<property>
<name>yarn.nodemanager.auxservices.mapreduce.shuffle.class</name>
<value>org.apache.hadoop.mapred.ShuffleHandler</value>
</property>
</configuration>" >> /usr/local/hadoop/etc/hadoop/yarn-site.xml
cd
hadoop namenode -format
/usr/local/hadoop/sbin/start-all.sh
wget https://archive.apache.org/dist/pig/pig-0.15.0/pig-0.15.0.tar.gz
tar -zxvf pig-0.15.0.tar.gz
rm -rf pig-0.15.0.tar.gz
mv pig-0.15.0 pig
mv pig /usr/local/
cd /usr/local/pig
echo -e "export PIG_HOME=/usr/local/pig
export PATH=\$PATH:/usr/local/pig/bin" >> /etc/profile
export PIG_HOME=/usr/local/pig
export PATH=$PATH:/usr/local/pig/bin
. /etc/profile
wget https://archive.apache.org/dist/sqoop/1.4.7/sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz
tar -xvzf  sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz
rm -rf sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz
mv sqoop-1.4.7.bin__hadoop-2.6.0 sqoop
mv sqoop /usr/local/
export SQOOP_HOME=/usr/local/sqoop
export PATH=$PATH:$SQOOP_HOME/bin
echo -e "export SQOOP_HOME=/usr/local/sqoop
export PATH=\$PATH:\$SQOOP_HOME/bin" >> ~/.bashrc
source ~/.bashrc
cd /usr/local/sqoop/conf/ 
cp sqoop-env-template.sh sqoop-env.sh
export HADOOP_COMMON_HOME=/usr/local/hadoop
export HADOOP_MAPRED_HOME=/usr/local/hadoop 
echo -e "export HADOOP_COMMON_HOME=/usr/local/hadoop
export HADOOP_MAPRED_HOME=/usr/local/hadoop" >> sqoop-env.sh  
wget https://dlcdn.apache.org/commons/lang/binaries/commons-lang-2.6-bin.tar.gz
tar -zxvf commons-lang-2.6-bin.tar.gz
rm -rf commons-lang-2.6-bin.tar.gz
cd commons-lang-2.6
mv commons-lang-2.6.jar /usr/local/sqoop/lib
cd
rm -rf commons-lang-2.6
ls /usr/local/sqoop/lib | grep commons-lang-2.6.jar
wget  https://cdn.mysql.com/archives/mysql-connector-java-5.1/mysql-connector-java-5.1.34.tar.gz
tar -zxvf mysql-connector-java-5.1.34.tar.gz
rm -rf mysql-connector-java-5.1.34.tar.gz
cd mysql-connector-java-5.1.34
mv mysql-connector-java-5.1.34-bin.jar /usr/local/sqoop/lib
ls /usr/local/sqoop/lib | grep  mysql-connector-java-5.1.34-bin.jar
apt install -y python3
apt install -y python3-pip
echo "———————————————————"
java -version
hadoop version
jps
pig -version
sqoop version
python3 --version
pip3 --version
echo "———————————————————"
