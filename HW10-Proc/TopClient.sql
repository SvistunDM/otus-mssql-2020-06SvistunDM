--1) Написать функцию возвращающую Клиента с наибольшей суммой покупки.

IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.TopClient'))
   exec('CREATE PROCEDURE [dbo].[TopClient] AS BEGIN SET NOCOUNT ON; END')
GO
GRANT EXECUTE ON OBJECT::dbo.TopClient  
    TO public;
go

ALTER PROCEDURE [dbo].[TopClient] 
   @CustomerID int = null output ,
   @name varchar (200) =null output 
AS
declare @retval int

select top 1 @CustomerID = ct.CustomerID
            ,@name = c.CustomerName
  from sales.CustomerTransactions ct 
  join sales.Customers c 
    on c.CustomerID = ct.CustomerID
 order by ct.TransactionAmount desc

 if @CustomerID is null 
   select @retval = 0
  else select @retval = 1
  
return @retval
GO


