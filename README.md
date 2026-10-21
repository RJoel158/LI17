# Apache Hive & Hadoop HDFS Distributed Analytics Cluster
**Laboratorio LI17 — 2.ª Práctica con Apache Hive: Análisis E-Commerce**  
**Universidad Privada del Valle (Univalle Bolivia)**  
**Materia:** Tecnologías Emergentes I  
**Estudiante:** Ronald Joel Saavedra Vargas  

Este repositorio contiene la arquitectura de infraestructura distribuida basada en **Apache Hadoop 3.4.1** y **Apache Hive 4.0.1** orquestada con **Docker Compose**, orientada al procesamiento analítico masivo (OLAP) sobre un dataset transaccional de comercio electrónico internacional (*E-Commerce Online Retail Dataset* con más de 540.000 registros).

---

## 1. Arquitectura del Clúster y Matriz de Red

El clúster analítico se ejecuta en contenedores desacoplados sobre una red privada bridge (`li17-ronald_default`), garantizando aislamiento de servicios, almacenamiento persistente en volúmenes Docker y ejecución SQL distribuida mediante el protocolo Thrift y JDBC.

```
       +--------------------------------------------------------------+
       |                      HOST (WINDOWS 11)                       |
       |                                                              |
       |    Navegador Web                 Consola / Cliente SQL       |
       |    http://localhost:9870         Beeline JDBC (:10000)       |
       +--------------+------------------------------+----------------+
                      |                              |
                      | 127.0.0.1:9870               | 127.0.0.1:10000
                      v                              v
       +-----------------------------+ +------------------------------+
       |   li17-ronald-namenode-1    | |  li17-ronald-hive-server-1   |
       |     (Hadoop NameNode)       | |        (HiveServer2)         |
       |                             | |                              |
       |  - Puerto Web: 9870         | |  - Puerto JDBC: 10000        |
       |  - Puerto RPC: 9000 (int.)  | |  - Puerto Web: 10002         |
       |  - Volumen: namenode:/data  | |  - Motor: MapReduce Local    |
       +--------------+--------------+ +--------------+---------------+
                      |                               |
        Red Interna   |                 Thrift RPC    |
          HDFS        |                 Puerto 9083   |
                      v                               v
       +-----------------------------+ +------------------------------+
       |   li17-ronald-datanode-1    | | li17-ronald-hive-metastore-1 |
       |     (Hadoop DataNode)       | |       (Hive Metastore)       |
       |                             | |                              |
       |  - Bloques de datos CSV     | |  - Catálogo esquemas/tablas  |
       |  - Puertos int: 9864/9866   | |  - Base relacional Derby     |
       |  - Volumen: datanode:/data  | |  - Volumen: metastore:/data  |
       +-----------------------------+ +------------------------------+
```

### Matriz de Contenedores y Puertos Expuestos

| Servicio | Nombre del Contenedor | Imagen Base | Puerto Host | Puerto Contenedor | Protocolo / Función | Exposición |
| :--- | :--- | :--- | :---: | :---: | :--- | :--- |
| **NameNode** | `li17-ronald-namenode-1` | `apache/hadoop:3.4.1` | **`9870`** | `9870` | HTTP / HDFS NameNode Web UI | Host (`127.0.0.1:9870`) |
| **NameNode** | `li17-ronald-namenode-1` | `apache/hadoop:3.4.1` | - | `9000` | IPC / Metadatos de Bloques HDFS | Red interna del clúster |
| **DataNode** | `li17-ronald-datanode-1` | `apache/hadoop:3.4.1` | - | `9864, 9866` | TCP / Almacenamiento y flujo de bloques HDFS | Red interna del clúster |
| **Hive Metastore**| `li17-ronald-hive-metastore-1` | `apache/hive:4.0.1` | - | **`9083`** | Thrift RPC / Catálogo de esquemas y tablas | Red interna (HiveServer2) |
| **HiveServer2** | `li17-ronald-hive-server-1` | `apache/hive:4.0.1` | **`10000`** | `10000` | TCP / Motor SQL Beeline JDBC | Host (`127.0.0.1:10000`) |
| **HiveServer2** | `li17-ronald-hive-server-1` | `apache/hive:4.0.1` | **`10002`** | `10002` | HTTP / HiveServer2 Status & Metrics Web UI | Host (`127.0.0.1:10002`) |

---

## 2. Orquestador Docker Compose (`proyecto/compose.yaml`)

El clúster implementa inicialización desatendida del sistema de archivos distribuido HDFS, sincronización mediante *healthchecks* sobre el puerto Thrift 9083 del Metastore, y persistencia de catálogos mediante base de datos relacional embebida Apache Derby en `/data/metastore_db`.

---

## 3. Modelo de Datos y Pipeline de Ingesta

### Dataset: E-Commerce Data (`data_ronald.csv`)
El conjunto de datos contiene transacciones comerciales minoristas de ventas internacionales (*Online Retail*).

| Columna | Tipo de Dato Hive | Descripción Técnica / Negocio |
| :--- | :---: | :--- |
| `InvoiceNo` | `STRING` | Código de factura único. Si inicia con 'C', representa una cancelación. |
| `StockCode` | `STRING` | Identificador único del producto en catálogo. |
| `Description` | `STRING` | Denominación o nombre comercial del artículo. |
| `Quantity` | `INT` | Unidades compradas por transacción (valores negativos indican devoluciones). |
| `InvoiceDate` | `TIMESTAMP` | Marca temporal (fecha y hora) en que ocurrió la transacción. |
| `UnitPrice` | `DOUBLE` | Precio unitario del artículo en libras esterlinas (£). |
| `CustomerID` | `INT` | Identificador del cliente (NULL para compradores no registrados). |
| `Country` | `STRING` | País de residencia o destino del comprador. |

### Definición DDL de Tabla en Hive (`tec_ronald`)
```sql
CREATE DATABASE IF NOT EXISTS dbec_ronald;
USE dbec_ronald;

CREATE TABLE IF NOT EXISTS dbec_ronald.tec_ronald (
    InvoiceNo STRING,
    StockCode STRING,
    Description STRING,
    Quantity INT,
    InvoiceDate TIMESTAMP,
    UnitPrice DOUBLE,
    CustomerID INT,
    Country STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
TBLPROPERTIES ("skip.header.line.count"="1");
```

---

## 4. Matriz de Consultas Analíticas (KPIs de Negocio)

### Nivel Básico
1. **Ingreso Total Validado:** Facturación neta de ventas válidas (`Quantity > 0`, `UnitPrice > 0`, `CustomerID IS NOT NULL`).  
   *KPI:* Ingreso total validado para reporting financiero.
2. **Top 10 Productos Más Vendidos:** Ranking por volumen de unidades y presencia en pedidos distintos.  
   *KPI:* Top productos para priorizar stock y promoción.
3. **Distribución Geográfica de Clientes:** Recuento de clientes únicos por país y porcentaje relativo mediante función de ventana (`OVER ()`).  
   *KPI:* Distribución geográfica para focalizar expansión.
4. **Ticket Promedio vs. Mediana por Orden:** Agrupación por orden calculando media aritmética y aproximación del percentil 50 (`PERCENTILE_APPROX`).  
   *KPI:* Ticket promedio vs. mediana para detectar sesgo por outliers.
5. **Evolución Mensual de Ventas:** Agregación temporal por año y mes analizando recuento de órdenes e ingresos consolidados.  
   *KPI:* Tendencia mensual para planificación de inventario.

### Nivel Intermedio
6. **Tasa de Devolución por Producto:** Ratio de ítems devueltos (`Quantity < 0` o `InvoiceNo LIKE 'C%'`) sobre el total de transacciones.  
   *KPI:* % devoluciones por producto para reducir desperdicio logístico.
7. **Patrón Horario de Demanda:** Distribución horaria (`HOUR(InvoiceDate)`) de pedidos, recaudación y ticket promedio.  
   *KPI:* Hora pico para programar campañas de email/push.
8. **Estacionalidad de Productos:** Distribución porcentual de ventas por mes de cada artículo (`SUM(Quantity) OVER (PARTITION BY Description)`).  
   *KPI:* Productos con >40% de ventas en 1-2 meses -> planificación de stock estacional.
9. **Margen Implícito (Proxy):** Evaluación de productos de alto valor unitario combinados con alta rotación de pedidos.  
   *KPI:* Score de margen para priorizar productos en promociones (alto precio * alta rotación).
10. **Comportamiento Clientes Registrados vs. Anónimos:** Segmentación por presencia de `CustomerID` para comparar ticket promedio y revenue.  
    *KPI:* Diferencia en ticket promedio -> justifica campañas de registro/loyalty.
11. **Conversión por Día de la Semana:** Agrupación por `DAYOFWEEK` (1=Domingo a 7=Sábado) evaluando flujo transaccional e ingresos.  
    *KPI:* Día con mayor ingreso para programar lanzamientos/promociones.
12. **Tasa de Cancelación por País:** Proporción de cancelaciones geográficas en mercados con volumen significativo (>= 50 transacciones).  
    *KPI:* Países con alta cancelación -> investigar causas logísticas/culturales.

---

## 5. Instrucciones de Ejecución

### Acceso a Beeline (Hive CLI)
```bash
docker exec -it li16-ronald-hive-server-1 beeline -u "jdbc:hive2://localhost:10000" -n hive
```

### Ejecución de Scripts SQL
Todos los scripts se encuentran versionados en `proyecto/sql/` y pueden ejecutarse directamente contra HiveServer2.
