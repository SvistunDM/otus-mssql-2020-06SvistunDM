/*
3) Создать одинаковую функцию и хранимую процедуру, посмотреть в чем разница в производительности и почему.
*/

DROP FUNCTION IF EXISTS  dbo.[MaxQtyClientCopy]

go

create Function [dbo].[MaxQtyClientCopy]
   (@CustomerID int)
RETURNS decimal(18,9)


AS
Begin
declare @qty decimal(18,9)

select top 1  @qty = il.Quantity*il.UnitPrice
--Sales.Customers
from Sales.Invoices i
join Sales.InvoiceLines il 
  on IL.InvoiceID= i.InvoiceID
where i.CustomerID = @CustomerID
order by il.Quantity*il.UnitPrice desc

return @qty
end
