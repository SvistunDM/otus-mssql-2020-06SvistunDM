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
  WHERE 1 = 1 '

  
   if (@CustomerID is not null) 
    select @sql = @sql + ' and Client.CustomerID = @CustomerID'

   if (@CustomerName is not null)
   select @sql = @sql + ' and Client.CustomerName like ' + @CustomerName

   if (@BillToCustomerID is not null) 
    select @sql = @sql + ' and Client.BillToCustomerID = @BillToCustomerID'

   if (@CustomerCategoryID is not null) 
    select @sql = @sql + ' and Client.CustomerCategoryID = @CustomerCategoryID'

   if (@BuyingGroupID is not null) 
    select @sql = @sql + ' and Client.BuyingGroupID = @BuyingGroupID'

   if (@MaxAccountOpenedDate is not null) 
    select @sql = @sql + ' AND Client.AccountOpenedDate >= 
        @MinAccountOpenedDate
    AND Client.AccountOpenedDate <= 
        @MaxAccountOpenedDate'

   if (@DeliveryCityID is not null) 
    select @sql = @sql + ' and Client.DeliveryCityID = @DeliveryCityID'

   if (@IsOnCreditHold is not null) 
    select @sql = @sql + ' and Client.IsOnCreditHold = @IsOnCreditHold'

   if (@IsOnCreditHold is not null) 
    select @sql = @sql + ' and (SELECT COUNT(*) FROM Sales.Orders
			WHERE Orders.CustomerID = Client.CustomerID)
				>= @IsOnCreditHold
			)'

   if (@PersonID is not null) 
    select @sql = @sql + ' and Client.PrimaryContactPersonID = @PersonID'

   if (@DeliveryStateProvince is not null) 
    select @sql = @sql + ' and Client.StateProvinceID = @DeliveryStateProvince'

   if (@PrimaryContactPersonIDIsEmployee is not null) 
    select @sql = @sql + ' and Person.IsEmployee = @PrimaryContactPersonIDIsEmployee'

   -- select @SQL = @SQL + ';'
    
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

--exec CustomerSearch_KitchenSinkOtus


---по плану запроса отношения 50% на 50%