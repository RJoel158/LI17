USE dbec_ronald;
-- KPI: Ingreso total validado para reporting financiero.
SELECT 
    ROUND(SUM(Quantity * UnitPrice), 2) as ingreso_total
FROM dbec_ronald.tec_ronald
WHERE Quantity > 0
  AND UnitPrice > 0
  AND CustomerID IS NOT NULL;
