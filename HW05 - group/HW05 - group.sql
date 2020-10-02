use WideWorldImporters;
/*


Группировки и агрегатные функции
1. Посчитать среднюю цену товара, общую сумму продажи по месяцам

Вывести:
* Год продажи
* Месяц продажи
* Средняя цена за месяц по всем товарам
* Общая сумма продаж

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

select year(si.InvoiceDate) as [Год продажи]
      ,DATENAME(month,max(InvoiceDate)) as [Месяц продажи]
      ,avg(sil.UnitPrice) as [Средняя цена]
      ,sum(sil.Quantity*sil.UnitPrice) as [сумма продаж]
from Sales.Invoices si
join Sales.InvoiceLines sil on sil.InvoiceID = si.InvoiceID 
group by year(InvoiceDate),month(InvoiceDate)
order by year(InvoiceDate),month(InvoiceDate)

/*
2. Отобразить все месяцы, где общая сумма продаж превысила 10 000

Вывести:
* Год продажи
* Месяц продажи
* Общая сумма продаж

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

select year(si.InvoiceDate) as [Год продажи]
      ,DATENAME(month,max(InvoiceDate)) as [Месяц продажи]
      ,sum(sil.Quantity*sil.UnitPrice) as [сумма продаж]
from Sales.Invoices si
join Sales.InvoiceLines sil on sil.InvoiceID = si.InvoiceID 
group by year(InvoiceDate),month(InvoiceDate)
having sum(sil.Quantity*sil.UnitPrice)>10000


/*
3. Вывести сумму продаж, дату первой продажи и количество проданного по месяцам, по товарам, продажи которых менее 50 ед в месяц.
Группировка должна быть по году, месяцу, товару.

Вывести:
* Год продажи
* Месяц продажи
* Наименование товара
* Сумма продаж
* Дата первой продажи
* Количество проданного

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/
select year(si.InvoiceDate) as [Год продажи]
      ,DATENAME(month,max(InvoiceDate)) as [Месяц продажи]
      ,wsi.StockItemName as [Наименование товараъ
      ,sum(sil.Quantity*sil.UnitPrice) as [сумма продаж]
      ,min(si.InvoiceDate)          
      ,sum(sil.Quantity) as [Количество проданного]
from Sales.Invoices si
join Sales.InvoiceLines sil 
  on sil.InvoiceID = si.InvoiceID 
join Warehouse.StockItems wsi 
  on wsi.StockItemID = sil.StockItemID
group by year(InvoiceDate),month(InvoiceDate),sil.StockItemID,wsi.StockItemName
having sum(sil.Quantity) < 50

/*
4. Написать рекурсивный CTE sql запрос и заполнить им временную таблицу и табличную переменную

Дано :
CREATE TABLE dbo.MyEmployees
(
EmployeeID smallint NOT NULL,
FirstName nvarchar(30) NOT NULL,
LastName nvarchar(40) NOT NULL,
Title nvarchar(50) NOT NULL,
DeptID smallint NOT NULL,
ManagerID int NULL,
CONSTRAINT PK_EmployeeID PRIMARY KEY CLUSTERED (EmployeeID ASC)
);

INSERT INTO dbo.MyEmployees VALUES
(1, N'Ken', N'Sánchez', N'Chief Executive Officer',16,NULL)
,(273, N'Brian', N'Welcker', N'Vice President of Sales',3,1)
,(274, N'Stephen', N'Jiang', N'North American Sales Manager',3,273)
,(275, N'Michael', N'Blythe', N'Sales Representative',3,274)
,(276, N'Linda', N'Mitchell', N'Sales Representative',3,274)
,(285, N'Syed', N'Abbas', N'Pacific Sales Manager',3,273)
,(286, N'Lynn', N'Tsoflias', N'Sales Representative',3,285)
,(16, N'David',N'Bradley', N'Marketing Manager', 4, 273)
,(23, N'Mary', N'Gibson', N'Marketing Specialist', 4, 16);

Результат вывода рекурсивного CTE:
EmployeeID Name Title EmployeeLevel
1 Ken Sánchez Chief Executive Officer 1
273 | Brian Welcker Vice President of Sales 2
16 | | David Bradley Marketing Manager 3
23 | | | Mary Gibson Marketing Specialist 4
274 | | Stephen Jiang North American Sales Manager 3
276 | | | Linda Mitchell Sales Representative 4
275 | | | Michael Blythe Sales Representative 4
285 | | Syed Abbas Pacific Sales Manager 3
286 | | | Lynn Tsoflias Sales Representative 4
*/



IF OBJECT_ID (N'dbo.MyEmployees', N'U') IS not NULL drop TABLE dbo.MyEmployees

CREATE TABLE dbo.MyEmployees
(
EmployeeID smallint NOT NULL,
FirstName nvarchar(30) NOT NULL,
LastName nvarchar(40) NOT NULL,
Title nvarchar(50) NOT NULL,
DeptID smallint NOT NULL,
ManagerID int NULL,
CONSTRAINT PK_EmployeeID PRIMARY KEY CLUSTERED (EmployeeID ASC)
);

declare @MyEmployees table 
(
EmployeeID smallint NOT NULL,
FirstName nvarchar(30) NOT NULL,
LastName nvarchar(40) NOT NULL,
Title nvarchar(50) NOT NULL,
EmployeeLevel int NOT NULL
)


INSERT INTO dbo.MyEmployees VALUES
(1, N'Ken', N'Sánchez', N'Chief Executive Officer',16,NULL)
,(273, N'Brian', N'Welcker', N'Vice President of Sales',3,1)
,(274, N'Stephen', N'Jiang', N'North American Sales Manager',3,273)
,(275, N'Michael', N'Blythe', N'Sales Representative',3,274)
,(276, N'Linda', N'Mitchell', N'Sales Representative',3,274)
,(285, N'Syed', N'Abbas', N'Pacific Sales Manager',3,273)
,(286, N'Lynn', N'Tsoflias', N'Sales Representative',3,285)
,(16, N'David',N'Bradley', N'Marketing Manager', 4, 273)
,(23, N'Mary', N'Gibson', N'Marketing Specialist', 4, 16);


WITH Recursive  (EmployeeID, FirstName, LastName, Title,EmployeeLevel)
AS
(
    SELECT EmployeeID, FirstName, LastName, Title,1
    FROM dbo.MyEmployees e
    WHERE e.EmployeeID = 1 
    UNION ALL
    SELECT e.EmployeeID,  e.FirstName, e.LastName, e.Title, EmployeeLevel+1
    FROM dbo.MyEmployees e
        JOIN Recursive  r ON r.EmployeeID = e.ManagerID
        WHERE e.EmployeeID <> e.ManagerID
)
SELECT EmployeeID, FirstName, LastName, Title,EmployeeLevel
into #MyEmployees
FROM Recursive  r

insert into @MyEmployees
select * from #MyEmployees






/*
Опционально:
Написать запросы 1-3 так, чтобы если в каком-то месяце не было продаж, то этот месяц также отображался бы в результатах, но там были нули.
*/



;
with M(monN,monV) as 
(select 1,'January'
union select 2,'February'
union select 3,'March'
union select 4,'April'
union select 5,'May'
union select 6,'June'
union select 7,'July'
union select 8,'August'
union select 9,'September'
union select 10,'October'
union select 11,'November'
union select 12,'December'
),
Y (yearN) as
(select distinct year(si.InvoiceDate)
  from Sales.Invoices si
),
MY as 
( select * 
    from Y
    cross join M
 )

select MY.yearN as [Год продажи]
      ,MY.monV as [Месяц продажи]
      ,isnull(avg(sil.UnitPrice),0) as [Средняя цена]
      ,isnull(sum(sil.Quantity*sil.UnitPrice),0) as [сумма продаж]
from MY
left join Sales.Invoices si 
  on year(si.InvoiceDate) = MY.yearN
 and month(si.InvoiceDate) = MY.monN
left join Sales.InvoiceLines sil on sil.InvoiceID = si.InvoiceID 
group by MY.yearN,MY.monV ,MY.monN

order by MY.yearN,MY.monN




;
with M(monN,monV) as 
(select 1,'January'
union select 2,'February'
union select 3,'March'
union select 4,'April'
union select 5,'May'
union select 6,'June'
union select 7,'July'
union select 8,'August'
union select 9,'September'
union select 10,'October'
union select 11,'November'
union select 12,'December'
),
Y (yearN) as
(select distinct year(si.InvoiceDate)
  from Sales.Invoices si
),
MY as 
( select * 
    from Y
    cross join M
 )
 ,inv as (
 select year(si.InvoiceDate) as [Год продажи]
      ,month(InvoiceDate) as [monN]
      ,avg(sil.UnitPrice) as [Средняя цена]
      ,sum(sil.Quantity*sil.UnitPrice) as [сумма продаж]
from Sales.Invoices si
join Sales.InvoiceLines sil on sil.InvoiceID = si.InvoiceID 
group by year(InvoiceDate),month(InvoiceDate)

 )
 select MY.yearN as [Год продажи]
       ,My.monV
       ,isnull(inv.[Средняя цена],0)
       ,isnull(inv.[сумма продаж],0)
   from MY 
   left join inv 
     on inv.[Год продажи] = MY.yearN
    and inv.monN = MY.monn
    order by MY.yearN,MY.monn


    ;
with M(monN,monV) as 
(select 1,'January'
union select 2,'February'
union select 3,'March'
union select 4,'April'
union select 5,'May'
union select 6,'June'
union select 7,'July'
union select 8,'August'
union select 9,'September'
union select 10,'October'
union select 11,'November'
union select 12,'December'
),
Y (yearN) as
(select distinct year(si.InvoiceDate)
  from Sales.Invoices si
),
MY as 
( select * 
    from Y
    cross join M
 )
 ,inv as (
select year(si.InvoiceDate) as [Год продажи]
      ,month(InvoiceDate) as monn
      ,sum(sil.Quantity*sil.UnitPrice) as [сумма продаж]
from Sales.Invoices si
join Sales.InvoiceLines sil on sil.InvoiceID = si.InvoiceID 
group by year(InvoiceDate),month(InvoiceDate)
having sum(sil.Quantity*sil.UnitPrice)>10000

 )
 select MY.yearN as [Год продажи]
       ,My.monV
       ,isnull(inv.[сумма продаж],0)
   from MY 
   left join inv 
     on inv.[Год продажи] = MY.yearN
    and inv.monN = MY.monn
    order by MY.yearN,MY.monn


    ;
with M(monN,monV) as 
(select 1,'January'
union select 2,'February'
union select 3,'March'
union select 4,'April'
union select 5,'May'
union select 6,'June'
union select 7,'July'
union select 8,'August'
union select 9,'September'
union select 10,'October'
union select 11,'November'
union select 12,'December'
),
Y (yearN) as
(select distinct year(si.InvoiceDate)
  from Sales.Invoices si
),
MY as 
( select * 
    from Y
    cross join M
 )
 ,inv as (
select year(si.InvoiceDate) as [Год продажи]
      ,month(InvoiceDate) as monn
      ,wsi.StockItemName as [Наименование товара]
      ,sum(sil.Quantity*sil.UnitPrice) as [сумма продаж]
      ,min(si.InvoiceDate) as minD         
      ,sum(sil.Quantity) as [Количество проданного]
from Sales.Invoices si
join Sales.InvoiceLines sil 
  on sil.InvoiceID = si.InvoiceID 
join Warehouse.StockItems wsi 
  on wsi.StockItemID = sil.StockItemID
group by year(InvoiceDate),month(InvoiceDate),sil.StockItemID,wsi.StockItemName
having sum(sil.Quantity) < 50

 )
 select MY.yearN as [Год продажи]
       ,My.monV
       ,isnull(inv.[сумма продаж],0)
      ,isnull(inv.[Наименование товара],'') as [Наименование товара]
      ,isnull(inv.[сумма продаж],0) as [сумма продаж]
      ,isnull(minD ,'19000101'     ) as [Первая продажа]
      ,isnull(inv.[Количество проданного],0) as [Количество проданного] 
   from MY 
   left join inv 
     on inv.[Год продажи] = MY.yearN
    and inv.monN = MY.monn
  order by MY.yearN,MY.monn