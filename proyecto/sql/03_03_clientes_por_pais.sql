USE dbec_ronald;
-- KPI: Distribución geográfica para focalizar expansión.
SELECT 
    Country,
    COUNT(DISTINCT CustomerID) as clientes_unicos,
    ROUND(COUNT(DISTINCT CustomerID) * 100.0 / 
          SUM(COUNT(DISTINCT CustomerID)) OVER (), 2) as porcentaje
FROM dbec_ronald.tec_ronald
WHERE CustomerID IS NOT NULL
GROUP BY Country
ORDER BY clientes_unicos DESC;
