use WideWorldImporters;
/*
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal". Вывести: ИД товара, наименование товара.
Таблицы: Warehouse.StockItems.
*/

select StockItemID
      ,StockItemName 
  from Warehouse.StockItems 
 where StockItemName like '%urgent%'
    or StockItemName like 'Animal%'
;
/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders). Сделать через JOIN, с 
подзапросом задание принято не будет. 
Вывести: ИД поставщика, наименование поставщика.
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
*/

select ps.SupplierID
      ,ps.SupplierName
  from Purchasing.Suppliers PS
  left join Purchasing.PurchaseOrders PP 
    on pp.SupplierID = ps.SupplierID
 where pp.PurchaseOrderID is null
 ;
 /*
 3. Заказы (Orders) с ценой товара более 100$ либо количеством единиц товара более 20 штук и присутствующей датой комплектации всего заказа 
 (PickingCompletedWhen).
Вывести:
* OrderID
* дату заказа в формате ДД.ММ.ГГГГ
* название месяца, в котором была продажа
* номер квартала, к которому относится продажа
* треть года, к которой относится дата продажи (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой, пропустив первую 1000 и отобразив следующие 100 записей. 
Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).
Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
 */
 select o.OrderID 
 ,FORMAT( o.OrderDate, 'dd.MM.yyyy', 'en-US' ) AS [ДД.ММ.ГГГГ]
 ,format(o.OrderDate, 'MMMM', 'ru-RU')  AS [название месяца]
 ,datepart(qq, o.OrderDate) AS [номер квартала]
 ,(month(o.OrderDate)/4) + IIF(month(o.OrderDate)%4 > 0,1,0) AS [треть года]
/*  + (month(o.OrderDate)%4%3&1)
  + (month(o.OrderDate)%4%3/2)
  + (month(o.OrderDate)%4/3) AS [треть года]*/
 ,C.CustomerName AS [имя заказчика]
   from Sales.Orders o
   join Sales.OrderLines ol 
     on ol.OrderID = o.OrderID
   join Sales.Customers c
     on c.CustomerID = o.CustomerID
   WHERE (OL.UnitPrice>100 OR OL.Quantity>20) AND OL.PickingCompletedWhen IS NOT NULL
  ORDER BY [номер квартала] DESC,[треть года] DESC,[ДД.ММ.ГГГГ] DESC

  OFFSET 1000 rows fetch first 100 rows only

 /*
  4. Заказы поставщикам (Purchasing.Suppliers), которые были исполнены в январе 2014 года с доставкой Air Freight 
  или Refrigerated Air Freight (DeliveryMethodName).
Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)

Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
 */


 select dm.DeliveryMethodName as [способ доставки]
       ,po.ExpectedDeliveryDate as [дата доставки]
       ,s.SupplierName as [имя поставщика]
       ,p.FullName as [имя контактного лица принимавшего заказ]
 from Purchasing.Suppliers s
 join Purchasing.PurchaseOrders po
   on po.SupplierID=s.SupplierID
  and po.ExpectedDeliveryDate between '20140101' and '20140131'
 join Application.DeliveryMethods dm
   on dm.DeliveryMethodID = po.DeliveryMethodID 
  and dm.DeliveryMethodName in ('Air Freight', 'Refrigerated Air Freight')
 join Application.People p 
   on p.PersonID = po.ContactPersonID

   /*5. Десять последних продаж (по дате) с именем клиента и именем сотрудника, который оформил заказ (SalespersonPerson).
   */

   select top 10 
          so.OrderDate as [Дата продажи]
         ,c.CustomerName as [Имя Клиента]
         ,p.FullName as [Имя сотрудника]
     from Sales.Orders so
     join Application.People p 
       on p.PersonID = so.SalespersonPersonID
     join Sales.Customers c 
       on c.CustomerID = so.CustomerID
    order by so.OrderDate desc



/*6. Все ид и имена клиентов и их контактные телефоны, 
которые покупали товар Chocolate frogs 250g. Имя товара 
смотреть в Warehouse.StockItems.
*/
   select c.CustomerID
         ,c.CustomerName as [Имя Клиента]
         ,c.PhoneNumber as [контактный телефон]
     from Sales.Orders so
     join sales.OrderLines ol
       on ol.OrderID = so.OrderID
     join Sales.Customers c 
       on c.CustomerID = so.CustomerID
    join Warehouse.StockItems si
      on si.StockItemID = ol.StockItemID
     and si.StockItemName = 'Chocolate frogs 250g'