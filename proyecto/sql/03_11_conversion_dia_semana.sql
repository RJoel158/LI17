USE dbec_ronald;
-- KPI: Día con mayor ingreso para programar lanzamientos/promociones.
SELECT 
    DAYOFWEEK(InvoiceDate) as dia_semana, -- 1=Domingo, 7=Sábado
    CASE DAYOFWEEK(InvoiceDate)
        WHEN 1 THEN 'Domingo' WHEN 2 THEN 'Lunes' WHEN 3 THEN 'Martes'
        WHEN 4 THEN 'Miércoles' WHEN 5 THEN 'Jueves' WHEN 6 THEN 'Viernes'
        ELSE 'Sábado' END as dia_nombre,
    COUNT(DISTINCT InvoiceNo) as pedidos,
    ROUND(SUM(Quantity * UnitPrice), 2) as ingresos
FROM dbec_ronald.tec_ronald
WHERE Quantity > 0 AND UnitPrice > 0
GROUP BY DAYOFWEEK(InvoiceDate)
ORDER BY dia_semana;
