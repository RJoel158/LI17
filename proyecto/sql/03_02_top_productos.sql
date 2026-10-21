USE dbec_ronald;
-- KPI: Top productos para priorizar stock y promoción.
SELECT 
    Description,
    SUM(Quantity) as unidades_vendidas,
    COUNT(DISTINCT InvoiceNo) as pedidos_con_producto
FROM dbec_ronald.tec_ronald
WHERE Quantity > 0
GROUP BY Description
ORDER BY unidades_vendidas DESC
LIMIT 10;
