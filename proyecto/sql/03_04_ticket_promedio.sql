USE dbec_ronald;
-- KPI: Ticket promedio vs. mediana para detectar sesgo por outliers.
SELECT 
    ROUND(AVG(order_total), 2) as ticket_promedio,
    PERCENTILE_APPROX(order_total, 0.5) as mediana_ticket
FROM (
    SELECT 
        InvoiceNo,
        SUM(Quantity * UnitPrice) as order_total
    FROM dbec_ronald.tec_ronald
    WHERE Quantity > 0 AND UnitPrice > 0
    GROUP BY InvoiceNo
) orders;
