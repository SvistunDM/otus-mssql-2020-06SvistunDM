use WideWorldImporters;
/*Подзапросы и CTE
Для всех заданий, где возможно, сделайте два варианта запросов:
1) через вложенный запрос


2) через WITH (для производных таблиц)
*/
/*
Напишите запросы:
1. Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), 
и не сделали ни одной продажи 04 июля 2015 года. Вывести ИД сотрудника и его полное имя. 
Продажи смотреть в таблице Sales.Invoices.
*/
--вариат 0 без СТЕ
select ap.PersonID
      ,ap.FullName
  from Application.People ap
  left join Sales.Invoices si 
    on si.SalespersonPersonID = ap.PersonID
   and si.InvoiceDate ='20150704'
  where ap.IsSalesPerson = 1
    and si.InvoiceID is null
  ;
--вариат 1 СТЕ
  with a as 
(select ap.PersonID
       ,ap.FullName 
  from Application.People ap
  left join Sales.Invoices si 
    on si.SalespersonPersonID = ap.PersonID
   and si.InvoiceDate ='20150704'
  where ap.IsSalesPerson = 1
    and si.InvoiceID is null)
  select a.FullName
        ,a.FullName 
    from a
    ;
--вариат 2 СТЕ
with a as 
(select ap.PersonID
       ,ap.FullName 
  from Application.People ap
  where ap.IsSalesPerson = 1
)
  select a.PersonID 
        ,a.FullName 
    from a
    left join Sales.Invoices si 
      on si.SalespersonPersonID = a.PersonID
     and si.InvoiceDate ='20150704'
     and si.InvoiceID is null
    ;

/*
2. Выберите товары с минимальной ценой (подзапросом). Сделайте два варианта подзапроса. 
Вывести: ИД товара, наименование товара, цена.
*/
--вариат 0 без СТЕ
select si.StockItemID
      ,si.UnitPrice 
      ,si.StockItemName
  from Warehouse.StockItems si
 where si.UnitPrice = (select min(sii.UnitPrice) 
                      from Warehouse.StockItems sii)
;

--вариат 1 без СТЕ
select si.StockItemID
      ,si.UnitPrice 
      ,si.StockItemName
  from Warehouse.StockItems si
  join (select min(sii.UnitPrice) as UnitPrice
                      from Warehouse.StockItems sii) as x 
    on x.UnitPrice = si.UnitPrice
;

--вариат 2 с СТЕ
with x as (select min(sii.UnitPrice) as UnitPrice
                      from Warehouse.StockItems sii)
select si.StockItemID
      ,si.UnitPrice 
      ,si.StockItemName
  from Warehouse.StockItems si
  join x 
    on x.UnitPrice = si.UnitPrice
;

/*
3. Выберите информацию по клиентам, которые перевели компании пять максимальных платежей из Sales.CustomerTransactions. 
Представьте несколько способов (в том числе с CTE).
*/

select top 5 
       ct.TransactionAmount
      ,c.CustomerName
      ,c.PhoneNumber
  from Sales.CustomerTransactions ct
  join Sales.Customers c
    on c.CustomerID = ct.CustomerID 
  order by ct.TransactionAmount desc
;

select x.TransactionAmount
      ,c.CustomerName
      ,c.PhoneNumber
  from (select top 5 
               ct.TransactionAmount 
              ,ct.CustomerID 
          from Sales.CustomerTransactions ct
         order by ct.TransactionAmount desc
      ) as x
  join Sales.Customers c
    on c.CustomerID = x.CustomerID
  
;

with x as 
(select top 5 
               ct.TransactionAmount 
              ,ct.CustomerID 
          from Sales.CustomerTransactions ct
         order by ct.TransactionAmount desc
      ) 
select x.TransactionAmount
      ,c.CustomerName
      ,c.PhoneNumber
  from x
  join Sales.Customers c
    on c.CustomerID = x.CustomerID
  
;
/*
4. Выберите города (ид и название), в которые были доставлены товары, входящие в тройку 
самых дорогих товаров, 
а также имя сотрудника, который осуществлял упаковку заказов (PackedByPersonID).
*/
select distinct 
       c.CityName
      ,c.CityID
      ,ap.FullName
  from 
  (select top 3 sii.StockItemID
                      from Warehouse.StockItems sii
          order by sii.UnitPrice desc) x --первые 3 товара отсортированные по цене
  join Sales.InvoiceLines sil on sil.StockItemID = x.StockItemID -- разшифровка счета фактуры
  join Sales.Invoices inv on inv.InvoiceID = sil.InvoiceID --счета фактуры
  join Application.People ap  --человеки
    on ap.PersonID = inv.PackedByPersonID
  join sales.Customers scu --живые люди покупатели
    on scu.CustomerID = inv.CustomerID
  join Application.Cities c -- города доставки вот этих вот(scu) выше
    on c.CityID = scu.DeliveryCityID
;

with si as (select top 3 sii.StockItemID
                      from Warehouse.StockItems sii
          order by sii.UnitPrice desc)
select distinct 
       c.CityName
      ,c.CityID
      ,ap.FullName
  from si
  join Sales.InvoiceLines sil on sil.StockItemID = si.StockItemID
  join Sales.Invoices inv on inv.InvoiceID = sil.InvoiceID
  join Application.People ap 
    on ap.PersonID = inv.PackedByPersonID
  join sales.Customers scu 
    on scu.CustomerID = inv.CustomerID
  join Application.Cities c 
    on c.CityID = scu.DeliveryCityID
;

SELECT      COLUMN_NAME AS 'ColumnName'
            ,TABLE_NAME AS  '*TableName'
            ,TABLE_SCHEMA
FROM        INFORMATION_SCHEMA.COLUMNS
WHERE       COLUMN_NAME LIKE '%PackedByPersonID%'

/*
Опционально:

5. Объясните, что делает и оптимизируйте запрос:



Можно двигаться как в сторону улучшения читабельности запроса, так и в сторону 
упрощения плана\ускорения. Сравнить производительность запросов можно через 
SET STATISTICS IO, TIME ON. Если знакомы с планами запросов, то используйте их 
(тогда к решению также приложите планы). Напишите ваши рассуждения по поводу оптимизации.
*/
;
--оригинальный запрос 73% по плану относительно CTE
SELECT
  Invoices.InvoiceID,
  Invoices.InvoiceDate,
  (SELECT People.FullName 
     FROM Application.People
    WHERE People.PersonID = Invoices.SalespersonPersonID --упаковщик из сч фактуры
  ) AS SalesPersonName,
  SalesTotals.TotalSumm AS TotalSummByInvoice,
  (SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice) -- кол-во * стоимость единицы
     FROM Sales.OrderLines   --строки заказов
    WHERE OrderLines.OrderId = (SELECT Orders.OrderId
                                  FROM Sales.Orders
                                 WHERE Orders.PickingCompletedWhen IS NOT NULL --завершенность не пуста
                                   AND Orders.OrderId = Invoices.OrderId)
  ) AS TotalSummForPickedItems
  FROM Sales.Invoices
  JOIN (SELECT InvoiceId
             , SUM(Quantity*UnitPrice) AS TotalSumm
         FROM Sales.InvoiceLines
        GROUP BY InvoiceId
        HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
    ON Invoices.InvoiceID = SalesTotals.InvoiceID
 ORDER BY TotalSumm DESC
;
--запрос CTE 27% по плану относительно CTE -- 
with sumLine as (
  SELECT SUM(ol.PickedQuantity * ol.UnitPrice) as TotalSummForPickedItems-- кол-во * стоимость единицы
         ,o.OrderId
   FROM Sales.OrderLines ol  --строки заказов
   join Sales.Orders o 
     on ol.OrderId = o.OrderId
    and o.PickingCompletedWhen IS NOT NULL
  group by o.OrderId
  ),
  selsum as (SELECT InvoiceId
                  , SUM(Quantity * UnitPrice) AS TotalSumm
              FROM Sales.InvoiceLines
             GROUP BY InvoiceId)  
SELECT
  Invoices.InvoiceID,
  Invoices.InvoiceDate,
  People.FullName AS SalesPersonName,
  SalesTotals.TotalSumm AS TotalSummByInvoice,
  sumLine.TotalSummForPickedItems
  FROM Sales.Invoices
  join sumLine 
    on sumLine.OrderID = Invoices.OrderId 
   and sumline.TotalSummForPickedItems > 27000
  join Application.People 
    on People.PersonID = Invoices.SalespersonPersonID
  JOIN selsum AS SalesTotals
    ON Invoices.InvoiceID = SalesTotals.InvoiceID
   and SalesTotals.TotalSumm > 27000
 ORDER BY TotalSumm DESC

/*
6. В материалах к вебинару есть файл HT_reviewBigCTE.sql - прочтите этот запрос и напишите, 
что он должен вернуть и в чем его смысл. Если есть идеи по улучшению запроса, то напишите их.*/