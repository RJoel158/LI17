USE dbec_ronald;
-- KPI: Productos con >40% de ventas en 1-2 meses -> planificación de stock estacional.
SELECT 
    Description,
    MONTH(InvoiceDate) as mes,
    SUM(Quantity) as unidades_mes,
    ROUND(SUM(Quantity) * 100.0 / SUM(SUM(Quantity)) OVER (PARTITION BY Description), 2) as distribucion_pct
FROM dbec_ronald.tec_ronald
WHERE Quantity > 0
GROUP BY Description, MONTH(InvoiceDate)
HAVING SUM(Quantity) > 50
ORDER BY Description, mes;
