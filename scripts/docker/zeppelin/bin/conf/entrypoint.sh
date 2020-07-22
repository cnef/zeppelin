#!/usr/bin/env bash
set -e
set -x

export HADOOP_HOME=/opt/hadoop
export HADOOP_CLASSPATH=${HADOOP_HOME}/share/hadoop/tools/lib/*
export HADOOP_LIBEXEC_DIR=${HADOOP_HOME}/libexec
export PATH=${PATH}:/opt/hadoop/bin/:/opt/hive/bin/ 
export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:/bin/java::")
envsubst < /opt/hadoop/etc/hadoop/hive-site.xml.tpl > /opt/hadoop/etc/hadoop/hive-site.xml


until mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p${MYSQL_PASSWORD} -e "USE ${MYSQL_DB};"; do 
  echo "Createing ${MYSQL_DB} database"
  mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p${MYSQL_PASSWORD} -e "CREATE DATABASE ${MYSQL_DB} DEFAULT CHARACTER SET latin1;"
  sleep 1
done

(
while true; do
  until mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p${MYSQL_PASSWORD} -e "select DB_LOCATION_URI from ${MYSQL_DB}.DBS;"; do
    echo "Waiting for ${MYSQL_DB} initial finished."
    sleep 1
  done
  WAREHOUSE_DIR=${WAREHOUSE_DIR:-"vzfs:///spark_warehouse"}
  defaultDbs=$(echo $(mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p${MYSQL_PASSWORD} -e "select DB_LOCATION_URI from ${MYSQL_DB}.DBS;")|awk '{print $NF}')
  if [ "X${defaultDbs}" == "X${WAREHOUSE_DIR}" ]; then
    break
  else 
    mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p${MYSQL_PASSWORD} -e "update ${MYSQL_DB}.DBS set DB_LOCATION_URI=\"${WAREHOUSE_DIR}\";"
  fi 
  echo "Changeing default DBS"
  sleep 1
done

)&
exec "$@"
