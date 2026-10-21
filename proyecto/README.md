# Laboratorio LI16 con Apache Hive y HDFS

Autor del laboratorio: Ronald Joel Saavedra Vargas.

Configuración propia para Tecnologías Emergentes I. Utiliza imágenes oficiales de Apache Hadoop 3.4.1 y Apache Hive 4.0.1. No se clonó Big Data Europe.

Servicios: NameNode, DataNode, Hive Metastore con Derby persistente y HiveServer2. El laboratorio usa MapReduce local para las consultas y HDFS para los datos; no despliega YARN. La replicación de uno y los permisos simplificados corresponden a un entorno académico local.

Inicio desde Ubuntu: `bash iniciar.sh`. El script levanta Compose y prepara los directorios HDFS. La configuración espera que el metastore esté saludable antes de depender de él.

Interfaz NameNode: http://localhost:9870

Cliente SQL: `docker compose exec hive-server beeline -u jdbc:hive2://localhost:10000 -n hive`.

La guía usa nombres y puertos de otra arquitectura. Aquí se usan los nombres de servicio de Compose y Beeline en lugar del antiguo CLI de Hive. El metastore usa Derby para mantener el entorno académico pequeño.

## Cargar el dataset

Conservar el CSV original y generar una copia sin encabezado. En la carpeta de trabajo de Windows, `scripts/preparar_datos.py` realiza esa preparación y valida los 15 campos. El CSV utilizado se conserva en `datos/pseudo_facebook_ronald.csv` junto con su hash.

Desde la carpeta del proyecto, con el archivo sin encabezado en el directorio actual:

```bash
docker compose cp pseudo_facebook_ronald.csv namenode:/tmp/
docker compose exec -T namenode hdfs dfs -put /tmp/pseudo_facebook_ronald.csv /user/hive/warehouse/
docker compose cp sql hive-server:/tmp/
docker compose exec -T hive-server beeline -u jdbc:hive2://localhost:10000 -n hive -f /tmp/sql/15a.sql
docker compose exec -T hive-server beeline -u jdbc:hive2://localhost:10000 -n hive -f /tmp/sql/15c.sql
docker compose exec -T hive-server beeline -u jdbc:hive2://localhost:10000 -n hive -f /tmp/sql/15d.sql
docker compose exec -T hive-server beeline -u jdbc:hive2://localhost:10000 -n hive -f /tmp/sql/15e.sql
docker compose exec -T hive-server beeline -u jdbc:hive2://localhost:10000 -n hive -f /tmp/sql/15f.sql
for punto in a b c d e f g; do
  docker compose exec -T hive-server beeline -u jdbc:hive2://localhost:10000 -n hive -f "/tmp/sql/16${punto}.sql"
done
```

Estos pasos de carga se ejecutan una sola vez sobre un entorno nuevo. `LOAD DATA` mueve el archivo al directorio de la tabla. Para seguir consultando el entorno ya cargado, ejecutar solamente las consultas 16a a 16g.

El orden de columnas se conserva y `NA` se interpreta como nulo. La tabla no transaccional es traducida a externa por Hive 4; la ruta real se comprueba con DESCRIBE FORMATTED.

## Evidencias

El informe distingue capturas reales de HDFS de imágenes de registros renderizados. El reloj añadido a las páginas locales de HDFS sirve para mostrar la hora actual; los registros incluyen la hora original de ejecución. Los JSON originales conservan las advertencias de logging y los códigos de salida.

Referencias de implementación:

- https://hive.apache.org/docs/latest/admin/setting-up-hive-with-docker/
- https://hadoop.apache.org/docs/r3.4.1/hadoop-project-dist/hadoop-hdfs/HDFSCommands.html
