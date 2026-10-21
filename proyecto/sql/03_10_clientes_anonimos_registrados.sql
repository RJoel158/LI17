USE dbec_ronald;
-- KPI: Diferencia en ticket promedio -> justifica campañas de registro/loyalty.
SELECT 
    CASE WHEN CustomerID IS NULL THEN 'Anónimo' ELSE 'Registrado' END as tipo_cliente,
    COUNT(DISTINCT InvoiceNo) as pedidos,
    ROUND(AVG(Quantity * UnitPrice), 2) as ticket_promedio,
    ROUND(SUM(Quantity * UnitPrice), 2) as revenue_total
FROM dbec_ronald.tec_ronald
WHERE Quantity > 0 AND UnitPrice > 0
GROUP BY CASE WHEN CustomerID IS NULL THEN 'Anónimo' ELSE 'Registrado' END;
