
/*
2) Написать хранимую процедуру с входящим параметром СustomerID, выводящую сумму покупки по этому клиенту.
Использовать таблицы :
Sales.Customers
Sales.Invoices
Sales.InvoiceLines
*/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.MaxQtyClient'))
   exec('CREATE PROCEDURE [dbo].[MaxQtyClient] AS BEGIN SET NOCOUNT ON; END')
GO
GRANT EXECUTE ON OBJECT::dbo.MaxQtyClient 
    TO public;
go

ALTER PROCEDURE [dbo].[MaxQtyClient] 
   @CustomerID int,
   @QTY decimal(18,9) output 
AS
declare @retval int
select @retval = 0

select top 1  @qty = il.Quantity*il.UnitPrice
--Sales.Customers
from Sales.Invoices i
join Sales.InvoiceLines il 
  on IL.InvoiceID= i.InvoiceID
where i.CustomerID = @CustomerID
order by il.Quantity*il.UnitPrice desc

if @qty is null
select @retval = 1 

return @retval