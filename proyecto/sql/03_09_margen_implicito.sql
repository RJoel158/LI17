USE dbec_ronald;
-- KPI: Score de margen para priorizar productos en promociones (alto precio * alta rotación).
SELECT 
    Description,
    ROUND(AVG(UnitPrice), 2) as precio_promedio,
    COUNT(DISTINCT InvoiceNo) as pedidos_con_producto,
    ROUND(AVG(UnitPrice) * COUNT(DISTINCT InvoiceNo), 2) as score_margen_proxy
FROM dbec_ronald.tec_ronald
WHERE Quantity > 0 AND UnitPrice > 0
GROUP BY Description
HAVING COUNT(DISTINCT InvoiceNo) >= 5
ORDER BY score_margen_proxy DESC
LIMIT 20;
