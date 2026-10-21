USE dbec_ronald;
-- KPI: % devoluciones por producto para reducir desperdicio logístico.
SELECT 
    Description,
    COUNT(CASE WHEN Quantity < 0 OR InvoiceNo LIKE 'C%' THEN 1 END) as devoluciones,
    COUNT(CASE WHEN Quantity > 0 THEN 1 END) as ventas_validas,
    ROUND(
        COUNT(CASE WHEN Quantity < 0 OR InvoiceNo LIKE 'C%' THEN 1 END) * 100.0 / 
        NULLIF(COUNT(*), 0), 2
    ) as tasa_devolucion_pct
FROM dbec_ronald.tec_ronald
WHERE CustomerID IS NOT NULL
GROUP BY Description
HAVING COUNT(*) >= 10
ORDER BY tasa_devolucion_pct DESC
LIMIT 15;
