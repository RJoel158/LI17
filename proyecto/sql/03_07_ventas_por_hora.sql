USE dbec_ronald;
-- KPI: Hora pico para programar campañas de email/push.
SELECT 
    HOUR(InvoiceDate) as hora,
    COUNT(DISTINCT InvoiceNo) as pedidos,
    ROUND(SUM(Quantity * UnitPrice), 2) as ingresos,
    ROUND(AVG(Quantity * UnitPrice), 2) as ticket_promedio
FROM dbec_ronald.tec_ronald
WHERE Quantity > 0 AND UnitPrice > 0
GROUP BY HOUR(InvoiceDate)
ORDER BY hora;
