use WideWorldImporters;
/*
1. ��� ������, � �������� ������� ���� "urgent" ��� �������� ���������� � "Animal". �������: �� ������, ������������ ������.
�������: Warehouse.StockItems.
*/

select StockItemID
      ,StockItemName 
  from Warehouse.StockItems 
 where StockItemName like '%urgent%'
    or StockItemName like 'Animal%'
;
/*
2. ����������� (Suppliers), � ������� �� ���� ������� �� ������ ������ (PurchaseOrders). ������� ����� JOIN, � 
����������� ������� ������� �� �����. 
�������: �� ����������, ������������ ����������.
�������: Purchasing.Suppliers, Purchasing.PurchaseOrders.
*/

select ps.SupplierID
      ,ps.SupplierName
  from Purchasing.Suppliers PS
  left join Purchasing.PurchaseOrders PP 
    on pp.SupplierID = ps.SupplierID
 where pp.PurchaseOrderID is null
 ;
 /*
 3. ������ (Orders) � ����� ������ ����� 100$ ���� ����������� ������ ������ ����� 20 ���� � �������������� ����� ������������ ����� ������ 
 (PickingCompletedWhen).
�������:
* OrderID
* ���� ������ � ������� ��.��.����
* �������� ������, � ������� ���� �������
* ����� ��������, � �������� ��������� �������
* ����� ����, � ������� ��������� ���� ������� (������ ����� �� 4 ������)
* ��� ��������� (Customer)
�������� ������� ����� ������� � ������������ ��������, ��������� ������ 1000 � ��������� ��������� 100 �������. 
���������� ������ ���� �� ������ ��������, ����� ����, ���� ������ (����� �� �����������).
�������: Sales.Orders, Sales.OrderLines, Sales.Customers.
 */
 select o.OrderID 
 ,FORMAT( o.OrderDate, 'dd.MM.yyyy', 'en-US' ) AS [��.��.����]
 ,format(o.OrderDate, 'MMMM', 'ru-RU')  AS [�������� ������]
 ,datepart(qq, o.OrderDate) AS [����� ��������]
 ,(month(o.OrderDate)/4) + IIF(month(o.OrderDate)%4 > 0,1,0) AS [����� ����]
/*  + (month(o.OrderDate)%4%3&1)
  + (month(o.OrderDate)%4%3/2)
  + (month(o.OrderDate)%4/3) AS [����� ����]*/
 ,C.CustomerName AS [��� ���������]
   from Sales.Orders o
   join Sales.OrderLines ol 
     on ol.OrderID = o.OrderID
   join Sales.Customers c
     on c.CustomerID = o.CustomerID
   WHERE (OL.UnitPrice>100 OR OL.Quantity>20) AND OL.PickingCompletedWhen IS NOT NULL
  ORDER BY [����� ��������] DESC,[����� ����] DESC,[��.��.����] DESC

  OFFSET 1000 rows fetch first 100 rows only

 /*
  4. ������ ����������� (Purchasing.Suppliers), ������� ���� ��������� � ������ 2014 ���� � ��������� Air Freight 
  ��� Refrigerated Air Freight (DeliveryMethodName).
�������:
* ������ �������� (DeliveryMethodName)
* ���� ��������
* ��� ����������
* ��� ����������� ���� ������������ ����� (ContactPerson)

�������: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
 */


 select dm.DeliveryMethodName as [������ ��������]
       ,po.ExpectedDeliveryDate as [���� ��������]
       ,s.SupplierName as [��� ����������]
       ,p.FullName as [��� ����������� ���� ������������ �����]
 from Purchasing.Suppliers s
 join Purchasing.PurchaseOrders po
   on po.SupplierID=s.SupplierID
  and po.ExpectedDeliveryDate between '20140101' and '20140131'
 join Application.DeliveryMethods dm
   on dm.DeliveryMethodID = po.DeliveryMethodID 
  and dm.DeliveryMethodName in ('Air Freight', 'Refrigerated Air Freight')
 join Application.People p 
   on p.PersonID = po.ContactPersonID

   /*5. ������ ��������� ������ (�� ����) � ������ ������� � ������ ����������, ������� ������� ����� (SalespersonPerson).
   */

   select top 10 
          so.OrderDate as [���� �������]
         ,c.CustomerName as [��� �������]
         ,p.FullName as [��� ����������]
     from Sales.Orders so
     join Application.People p 
       on p.PersonID = so.SalespersonPersonID
     join Sales.Customers c 
       on c.CustomerID = so.CustomerID
    order by so.OrderDate desc



/*6. ��� �� � ����� �������� � �� ���������� ��������, 
������� �������� ����� Chocolate frogs 250g. ��� ������ 
�������� � Warehouse.StockItems.
*/
   select c.CustomerID
         ,c.CustomerName as [��� �������]
         ,c.PhoneNumber as [���������� �������]
     from Sales.Orders so
     join sales.OrderLines ol
       on ol.OrderID = so.OrderID
     join Sales.Customers c 
       on c.CustomerID = so.CustomerID
    join Warehouse.StockItems si
      on si.StockItemID = ol.StockItemID
     and si.StockItemName = 'Chocolate frogs 250g'