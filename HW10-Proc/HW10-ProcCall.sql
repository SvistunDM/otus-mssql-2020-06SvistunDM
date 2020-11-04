--1) Написать функцию возвращающую Клиента с наибольшей суммой покупки.
declare @i int
        ,@name varchar(200)
exec dbo.TopClient @CustomerID = @i out --Можно и не писать тк в процедуре null
              ,@name = @name out --Можно и не писать тк в процедуре null
select @i,@name
/*
2) Написать хранимую процедуру с входящим параметром СustomerID, выводящую сумму покупки по этому клиенту.
Использовать таблицы :
Sales.Customers
Sales.Invoices
Sales.InvoiceLines
*/
set statistics time on
declare @CustomerID int
       ,@qty decimal(18,9)
select @CustomerID =894
Print '[MaxQtyClient]'
exec [dbo].[MaxQtyClient] 
      @CustomerID = @CustomerID
      ,@qty = @qty out


/*
3) Создать одинаковую функцию и хранимую процедуру, посмотреть в чем разница в производительности и почему.
*/
set statistics time on
declare @CustomerID int
       ,@qty decimal(18,9)
select @CustomerID =894
Print '[MaxQtyClientcopy]'
select   [dbo].[MaxQtyClientcopy] (@CustomerID)

--процедура CPU time = от 0 до 31 ms,  elapsed time = от 0 до 131 ms.
--функция CPU time = от 0 до 31 ms,  elapsed time = от 3до  120 ms.

--Разница во времяни не подвергается четкому анализу, достаточно схоже по времяни на таком количестве данных
/*
4) Создайте табличную функцию покажите как ее можно вызвать для каждой строки result set'а без использования цикла.
*/

select * 
  from dbo.RetTable() as x
  cross join dbo.RetTable() as y
  --Можно и с параметром то же самое сделать   
  /*типа dbo.RetTable(c.)
 select * 
  from sales.Customers as x 
  cross join dbo.RetTable(x.CustomerID) as y

  и там как-то обработать CustomerID

       select top 10 x.CustomerName,y.* 
  from sales.Customers as x 
  join dbo.RetTable() as y on 1=1
  */

/*
5) Опционально. Переписать процедуру kitchen sink с множеством входных параметров по поиску в заказах на динамический SQL. Сравнить планы запроса.
Текст процедуры в материалах к занятию в файле 70_Kitchen_sink_HomeTask.sql
*/

declare  @CustomerID                        int           
        ,@CustomerName                     nvarchar(100) 
        ,@BillToCustomerID                 int           
        ,@CustomerCategoryID               int           
        ,@BuyingGroupID                    int           
        ,@MinAccountOpenedDate             date          
        ,@MaxAccountOpenedDate             date          
        ,@DeliveryCityID                   int           
        ,@IsOnCreditHold                   bit           
        ,@OrdersCount			                 INT			     
        ,@PersonID				                 INT			     
        ,@DeliveryStateProvince            INT			     
        ,@PrimaryContactPersonIDIsEmployee BIT
        ,@SQL Nvarchar (max)
       
,   @Parameters    Nvarchar (max) 
       
       SET @Parameters = N'
   @CustomerID            int           
   ,@CustomerName          nvarchar(100) 
   ,@BillToCustomerID      int           
   ,@CustomerCategoryID    int           
   ,@BuyingGroupID         int           
   ,@MinAccountOpenedDate  date          
   ,@MaxAccountOpenedDate  date          
   ,@DeliveryCityID        int           
   ,@IsOnCreditHold        bit           
   ,@OrdersCount			      INT			     
   ,@PersonID				              INT			 
   ,@DeliveryStateProvince       INT			   
   ,@PrimaryContactPersonIDIsEmployee BIT
';

select @SQL =
 N'SELECT CustomerID, CustomerName, IsOnCreditHold
  FROM Sales.Customers AS Client
	JOIN Application.People AS Person ON 
		Person.PersonID = Client.PrimaryContactPersonID
	JOIN Application.Cities AS City ON
		City.CityID = Client.DeliveryCityID
  WHERE (@CustomerID IS NULL 
         OR Client.CustomerID = @CustomerID)
    AND (@CustomerName IS NULL 
         OR Client.CustomerName LIKE @CustomerName)
    AND (@BillToCustomerID IS NULL 
         OR Client.BillToCustomerID = @BillToCustomerID)
    AND (@CustomerCategoryID IS NULL 
         OR Client.CustomerCategoryID = @CustomerCategoryID)
    AND (@BuyingGroupID IS NULL 
         OR Client.BuyingGroupID = @BuyingGroupID)
    AND Client.AccountOpenedDate >= 
        COALESCE(@MinAccountOpenedDate, Client.AccountOpenedDate)
    AND Client.AccountOpenedDate <= 
        COALESCE(@MaxAccountOpenedDate, Client.AccountOpenedDate)
    AND (@DeliveryCityID IS NULL 
         OR Client.DeliveryCityID = @DeliveryCityID)
    AND (@IsOnCreditHold IS NULL 
         OR Client.IsOnCreditHold = @IsOnCreditHold)
	AND ((@OrdersCount IS NULL)
		OR ((SELECT COUNT(*) FROM Sales.Orders
			WHERE Orders.CustomerID = Client.CustomerID)
				>= @OrdersCount
			)
		)
	AND ((@PersonID IS NULL) 
		OR (Client.PrimaryContactPersonID = @PersonID))
	AND ((@DeliveryStateProvince IS NULL)
		OR (City.StateProvinceID = @DeliveryStateProvince))
	AND ((@PrimaryContactPersonIDIsEmployee IS NULL)
		OR (Person.IsEmployee = @PrimaryContactPersonIDIsEmployee)
		)';
    select @SQL

    exec sp_executesql @sql, @Parameters, @CustomerID                       
                                     ,@CustomerName                    
                                     ,@BillToCustomerID                
                                     ,@CustomerCategoryID              
                                     ,@BuyingGroupID                   
                                     ,@MinAccountOpenedDate            
                                     ,@MaxAccountOpenedDate            
                                     ,@DeliveryCityID                  
                                     ,@IsOnCreditHold                  
                                     ,@OrdersCount			                
                                     ,@PersonID				                
                                     ,@DeliveryStateProvince           
                                     ,@PrimaryContactPersonIDIsEmployee

exec CustomerSearch_KitchenSinkOtus


---по плану запроса отношения 50% на 50%