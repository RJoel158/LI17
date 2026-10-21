USE dbec_ronald;
-- KPI: Países con alta cancelación -> investigar causas logísticas/culturales.
SELECT 
    Country,
    COUNT(CASE WHEN Quantity < 0 OR InvoiceNo LIKE 'C%' THEN 1 END) as cancelaciones,
    COUNT(CASE WHEN Quantity > 0 THEN 1 END) as ventas_validas,
    ROUND(
        COUNT(CASE WHEN Quantity < 0 OR InvoiceNo LIKE 'C%' THEN 1 END) * 100.0 / 
        NULLIF(COUNT(*), 0), 2
    ) as tasa_cancelacion_pct
FROM dbec_ronald.tec_ronald
GROUP BY Country
HAVING COUNT(*) >= 50
ORDER BY tasa_cancelacion_pct DESC;
