/*1. Напишите запрос с временной таблицей и перепишите его с табличной переменной. Сравните планы.
В качестве запроса с временной таблицей и табличной переменной можно взять свой запрос или следующий запрос:
Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года (в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки)
Выведите id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом
Пример
Дата продажи Нарастающий итог по месяцу
2015-01-29 4801725.31
2015-01-30 4801725.31
2015-01-31 4801725.31
2015-02-01 9626342.98
2015-02-02 9626342.98
2015-02-03 9626342.98
Продажи можно взять из таблицы Invoices.
Нарастающий итог должен быть без оконной функции.
*/
Declare @Temp TABLE
(InvoiceID int,
CustomerName varchar(100),
InvoiceDate date,
TransactionAmount decimal(18, 2),
SumTA decimal(18, 2)

)

IF OBJECT_ID(N'tempdb..#temptable', N'U') IS NOT NULL   
DROP TABLE #temptable; 

select si.InvoiceID
      ,c.CustomerName
      ,si.InvoiceDate
      ,trans.TransactionAmount 
      ,(select  sum(trans1.TransactionAmount) 
          from Sales.Invoices si1
        join Sales.CustomerTransactions AS trans1
	        on si1.InvoiceID = trans1.InvoiceID
       where si1.InvoiceDate>='20150101'
         and si1.InvoiceDate<dateadd(dd,1,eomonth(si.InvoiceDate))  
      ) as SumTA 
      into #temptable
  from Sales.Invoices si
    join Sales.Customers c
      on c.CustomerID = si.CustomerID 
    join Sales.CustomerTransactions AS trans
	    on si.InvoiceID = trans.InvoiceID
  where si.InvoiceDate>='20150101'

  insert into @Temp (InvoiceID ,
                     CustomerName ,
                     InvoiceDate ,
                     TransactionAmount ,
                     SumTA )
  select si.InvoiceID
      ,c.CustomerName
      ,si.InvoiceDate
      ,trans.TransactionAmount 
      ,(select  sum(trans1.TransactionAmount) 
          from Sales.Invoices si1
        join Sales.CustomerTransactions AS trans1
	        on si1.InvoiceID = trans1.InvoiceID
       where si1.InvoiceDate>='20150101'
         and si1.InvoiceDate<dateadd(dd,1,eomonth(si.InvoiceDate))  
      ) as SumTA 
  from Sales.Invoices si
    join Sales.Customers c
      on c.CustomerID = si.CustomerID 
    join Sales.CustomerTransactions AS trans
	    on si.InvoiceID = trans.InvoiceID
  where si.InvoiceDate>='20150101'
/*2. Если вы брали предложенный выше запрос, то сделайте расчет суммы нарастающим итогом с помощью оконной функции.
Сравните 2 варианта запроса - через windows function и без них. Написать какой быстрее выполняется, сравнить по set statistics time on;
*/

set statistics time on
 select si.InvoiceID
      ,c.CustomerName
      ,si.InvoiceDate
      ,trans.TransactionAmount 
      ,sum(trans.TransactionAmount) OVER (order BY year(si.InvoiceDate),month(si.InvoiceDate) ) as SumTA 
  from Sales.Invoices si
    join Sales.Customers c
      on c.CustomerID = si.CustomerID 
    join Sales.CustomerTransactions AS trans
	    on si.InvoiceID = trans.InvoiceID
  where si.InvoiceDate>='20150101'
/* SQL Server Execution Times:
   CPU time = 281 ms,  elapsed time = 865 ms.
   против запроса без оконной функции
    SQL Server Execution Times:
   CPU time = 10500 ms,  elapsed time = 10510 ms.
   */

/*3. Вывести список 2х самых популярных продуктов (по кол-ву проданных) в каждом месяце за 2016й год (по 2 самых популярных продукта в каждом месяце)
*/
with c as (
select distinct wsi.StockItemName as [Наименование товара]  ,
      sum(sil.Quantity) OVER (PARTITION BY sil.StockItemID, month(si.InvoiceDate) ) as Quantity 
      --,ROW_NUMBER() OVER (PARTITION BY sil.StockItemID,month(si.InvoiceDate) ORDER BY sil.StockItemID,month(si.InvoiceDate) )
      ,month(si.InvoiceDate) as mon
      --,ROW_NUMBER() OVER (PARTITION BY sil.StockItemID ORDER BY month(si.InvoiceDate) ) as SumTA 
  from Sales.Invoices si
  join Sales.InvoiceLines sil 
    on sil.InvoiceID = si.InvoiceID 
  join Warehouse.StockItems wsi 
    on wsi.StockItemID = sil.StockItemID
  where year(si.InvoiceDate) = 2016 --and  month(si.InvoiceDate) = 1
),
itog as (select ROW_NUMBER() OVER (PARTITION BY mon ORDER BY Quantity DESC) AS QuantityRank
      ,Quantity
      ,[Наименование товара]
      ,mon
  from c
)
select [Наименование товара]
      ,mon as [месяц]
  from itog
 where QuantityRank <3


/*4. Функции одним запросом
Посчитайте по таблице товаров, в вывод также должен попасть ид товара, название, брэнд и цена
пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
посчитайте общее количество товаров и выведете полем в этом же запросе
посчитайте общее количество товаров в зависимости от первой буквы названия товара
отобразите следующий id товара исходя из того, что порядок отображения товаров по имени
предыдущий ид товара с тем же порядком отображения (по имени)
названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
сформируйте 30 групп товаров по полю вес товара на 1 шт
Для этой задачи НЕ нужно писать аналог без аналитических функций
*/

 select DENSE_RANK() OVER (ORDER BY left(wsi.StockItemName,1)) 
        ,wsi.StockItemID
        ,StockItemName  as [наменование товара]
        ,UnitPrice as [цена]
        ,count(wsi.StockItemID) over() as [общее количество товаров]  
        ,ps.SupplierName as [наименование бренда]
        ,count(wsi.StockItemID) OVER (PARTITION BY left(wsi.StockItemName,1) ORDER BY left(wsi.StockItemName,1)) as [количествоот первой буквы]
        ,Lead(wsi.StockItemID) OVER (ORDER BY wsi.StockItemName) as [предыдущий ид]
        ,Lag(wsi.StockItemName,2,'No items') OVER (ORDER BY wsi.StockItemName) 
        ,gr1.[группаПо1шт]

   from Warehouse.StockItems wsi   
   join Purchasing.Suppliers ps on ps.SupplierID = wsi.SupplierID
   left join (select ntile(30) OVER (PARTITION BY wsi1.QuantityPerOuter  ORDER BY wsi1.QuantityPerOuter ) as [группаПо1шт]
        ,wsi1.StockItemID
               
           from Warehouse.StockItems wsi1
          where wsi1.QuantityPerOuter = 1

         ) as gr1 on gr1.StockItemID = wsi.StockItemID

/*5. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал
В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки
*/
;
with itog as (
select  ap.PersonID
       ,ap.FullName
       ,sc.CustomerID
       ,sc.CustomerName
       ,si.InvoiceDate
       ,trans.TransactionAmount
       ,rank() over (partition by ap.PersonID order by si.InvoiceDate desc ,si.InvoiceID desc) as RN
  from sales.Invoices si
  join Application.People ap 
    on ap.PersonID = si.SalespersonPersonID
  join sales.Customers sc
    on sc.CustomerID = si.CustomerID
  join Sales.CustomerTransactions AS trans
	  on trans.InvoiceID  = si.InvoiceID

)
select PersonID
       ,FullName
       ,CustomerID
       ,CustomerName
       ,InvoiceDate
       ,TransactionAmount
  from itog
 where rn = 1
 ;

/*6. Выберите по каждому клиенту 2 самых дорогих товара, которые он покупал
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки
*/

with c as (
select 
       sc.CustomerID
       ,wsi.StockItemName
       ,wsi.StockItemID
       ,wsi.RecommendedRetailPrice
       ,max(si.InvoiceDate) as InvoiceDate 
--       ,rank() over (partition by sc.CustomerID order by wsi.RecommendedRetailPrice desc) RN

  from Sales.Invoices si
  join Sales.InvoiceLines sil 
    on sil.InvoiceID = si.InvoiceID 
  join Warehouse.StockItems wsi 
    on wsi.StockItemID = sil.StockItemID
  join sales.Customers sc
    on sc.CustomerID = si.CustomerID
 group by sc.CustomerID              ,wsi.StockItemName
       ,wsi.StockItemID       ,wsi.RecommendedRetailPrice)
,
b as (
select 
        CustomerID
       ,StockItemName
       ,RecommendedRetailPrice
       ,StockItemID
       ,InvoiceDate
       ,rank() over (partition by CustomerID order by RecommendedRetailPrice desc) RN

  from c
)


select  CustomerID
       ,StockItemName
       ,RecommendedRetailPrice
       ,StockItemID
       ,InvoiceDate
  from b
 where rn <3
 ;

--Опционально можно сделать вариант запросов для заданий 2,5,6 без использования windows function и сравнить скорость как в задании 1.