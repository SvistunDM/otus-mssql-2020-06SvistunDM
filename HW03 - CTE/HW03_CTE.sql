use WideWorldImporters;
/*���������� � CTE
��� ���� �������, ��� ��������, �������� ��� �������� ��������:
1) ����� ��������� ������


2) ����� WITH (��� ����������� ������)
*/
/*
�������� �������:
1. �������� ����������� (Application.People), ������� �������� ������������ (IsSalesPerson), 
� �� ������� �� ����� ������� 04 ���� 2015 ����. ������� �� ���������� � ��� ������ ���. 
������� �������� � ������� Sales.Invoices.
*/
--������ 0 ��� ���
select ap.PersonID
      ,ap.FullName
  from Application.People ap
  left join Sales.Invoices si 
    on si.SalespersonPersonID = ap.PersonID
   and si.InvoiceDate ='20150704'
  where ap.IsSalesPerson = 1
    and si.InvoiceID is null
  ;
--������ 1 ���
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
--������ 2 ���
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
2. �������� ������ � ����������� ����� (�����������). �������� ��� �������� ����������. 
�������: �� ������, ������������ ������, ����.
*/
--������ 0 ��� ���
select si.StockItemID
      ,si.UnitPrice 
      ,si.StockItemName
  from Warehouse.StockItems si
 where si.UnitPrice = (select min(sii.UnitPrice) 
                      from Warehouse.StockItems sii)
;

--������ 1 ��� ���
select si.StockItemID
      ,si.UnitPrice 
      ,si.StockItemName
  from Warehouse.StockItems si
  join (select min(sii.UnitPrice) as UnitPrice
                      from Warehouse.StockItems sii) as x 
    on x.UnitPrice = si.UnitPrice
;

--������ 2 � ���
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
3. �������� ���������� �� ��������, ������� �������� �������� ���� ������������ �������� �� Sales.CustomerTransactions. 
����������� ��������� �������� (� ��� ����� � CTE).
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
4. �������� ������ (�� � ��������), � ������� ���� ���������� ������, �������� � ������ 
����� ������� �������, 
� ����� ��� ����������, ������� ����������� �������� ������� (PackedByPersonID).
*/
select distinct 
       c.CityName
      ,c.CityID
      ,ap.FullName
  from 
  (select top 3 sii.StockItemID
                      from Warehouse.StockItems sii
          order by sii.UnitPrice desc) x --������ 3 ������ ��������������� �� ����
  join Sales.InvoiceLines sil on sil.StockItemID = x.StockItemID -- ����������� ����� �������
  join Sales.Invoices inv on inv.InvoiceID = sil.InvoiceID --����� �������
  join Application.People ap  --��������
    on ap.PersonID = inv.PackedByPersonID
  join sales.Customers scu --����� ���� ����������
    on scu.CustomerID = inv.CustomerID
  join Application.Cities c -- ������ �������� ��� ���� ���(scu) ����
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
�����������:

5. ���������, ��� ������ � ������������� ������:



����� ��������� ��� � ������� ��������� ������������� �������, ��� � � ������� 
��������� �����\���������. �������� ������������������ �������� ����� ����� 
SET STATISTICS IO, TIME ON. ���� ������� � ������� ��������, �� ����������� �� 
(����� � ������� ����� ��������� �����). �������� ���� ����������� �� ������ �����������.
*/
;
--������������ ������ 73% �� ����� ������������ CTE
SELECT
  Invoices.InvoiceID,
  Invoices.InvoiceDate,
  (SELECT People.FullName 
     FROM Application.People
    WHERE People.PersonID = Invoices.SalespersonPersonID --��������� �� �� �������
  ) AS SalesPersonName,
  SalesTotals.TotalSumm AS TotalSummByInvoice,
  (SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice) -- ���-�� * ��������� �������
     FROM Sales.OrderLines   --������ �������
    WHERE OrderLines.OrderId = (SELECT Orders.OrderId
                                  FROM Sales.Orders
                                 WHERE Orders.PickingCompletedWhen IS NOT NULL --������������� �� �����
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
--������ CTE 27% �� ����� ������������ CTE -- 
with sumLine as (
  SELECT SUM(ol.PickedQuantity * ol.UnitPrice) as TotalSummForPickedItems-- ���-�� * ��������� �������
         ,o.OrderId
   FROM Sales.OrderLines ol  --������ �������
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
6. � ���������� � �������� ���� ���� HT_reviewBigCTE.sql - �������� ���� ������ � ��������, 
��� �� ������ ������� � � ��� ��� �����. ���� ���� ���� �� ��������� �������, �� �������� ��.*/