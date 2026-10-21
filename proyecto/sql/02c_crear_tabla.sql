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
