USE dbec_ronald;
-- KPI: Tendencia mensual para planificación de inventario.
SELECT 
    YEAR(InvoiceDate) as anio,
    MONTH(InvoiceDate) as mes,
    COUNT(DISTINCT InvoiceNo) as pedidos,
    ROUND(SUM(Quantity * UnitPrice), 2) as ingresos
FROM dbec_ronald.tec_ronald
WHERE Quantity > 0 AND UnitPrice > 0
GROUP BY YEAR(InvoiceDate), MONTH(InvoiceDate)
ORDER BY anio, mes;
