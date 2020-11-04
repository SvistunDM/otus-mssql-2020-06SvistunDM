/*
4) Создайте табличную функцию покажите как ее можно вызвать для каждой строки result set'а без использования цикла.
*/
DROP FUNCTION IF EXISTS  dbo.[RetTable]

go


CREATE FUNCTION dbo.RetTable ()
RETURNS TABLE  
AS  
RETURN   
(  
    SELECT top 10 c.CustomerName
    FROM Sales.Customers c
);  
GO