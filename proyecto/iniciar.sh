#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
docker compose up -d
docker compose exec -T namenode hdfs dfsadmin -safemode wait
docker compose exec -T namenode hdfs dfs -mkdir -p /user/hive/warehouse /tmp
docker compose exec -T namenode hdfs dfs -chmod -R 777 /user/hive /tmp
echo 'HDFS preparado. NameNode: http://localhost:9870/dfshealth.html'
echo 'Cliente: docker compose exec hive-server beeline -u jdbc:hive2://localhost:10000 -n hive'
