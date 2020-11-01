/*Pivot и Cross Apply
1. Требуется написать запрос, который в результате своего выполнения формирует таблицу следующего вида:
Название клиента
МесяцГод Количество покупок

Клиентов взять с ID 2-6, это все подразделение Tailspin Toys
имя клиента нужно поменять так чтобы осталось только уточнение
например исходное Tailspin Toys (Gasport, NY) - вы выводите в имени только Gasport,NY
дата должна иметь формат dd.mm.yyyy например 25.12.2019

Например, как должны выглядеть результаты:
InvoiceMonth Peeples Valley, AZ Medicine Lodge, KS Gasport, NY Sylvanite, MT Jessie, ND
01.01.2013 3 1 4 2 2
01.02.2013 7 3 4 2 1
*/
select convert(varchar(10),InvoiceDate ,104) as InvoiceDate,[Gasport, NY],
[Jessie, ND],
[Medicine Lodge, KS],
[Peeples Valley, AZ],
[Sylvanite, MT]

  from (select substring(sc.CustomerName,charindex('(',sc.CustomerName)+1,charindex(')',sc.CustomerName)-charindex('(',sc.CustomerName)-1) as CustomerName
         ,cast(cast(year(si.InvoiceDate) as varchar)+format(month(si.InvoiceDate),'00')+'01' as date) as InvoiceDate
         ,count(si.InvoiceID) as num
    from sales.Invoices si 
    join sales.Customers sc 
      on sc.CustomerID = si.CustomerID
   where si.CustomerID in (2,3,4,5,6)

   group by CustomerName,year(si.InvoiceDate),month(si.InvoiceDate)
  -- order by year(si.InvoiceDate),month(si.InvoiceDate)
   ) as CusIn
 pivot(sum(CusIn.num) FOR CustomerName
IN (
[Gasport, NY],
[Jessie, ND],
[Medicine Lodge, KS],
[Peeples Valley, AZ],
[Sylvanite, MT]) ) AS PivotTable




/*
2. Для всех клиентов с именем, в котором есть Tailspin Toys
вывести все адреса, которые есть в таблице, в одной колонке

Пример результатов
CustomerName AddressLine
Tailspin Toys (Head Office) Shop 38
Tailspin Toys (Head Office) 1877 Mittal Road
Tailspin Toys (Head Office) PO Box 8975
Tailspin Toys (Head Office) Ribeiroville
.....
*/
select scN.CustomerName 
      ,sca.DeliveryAddressLine1
    from sales.Customers scA 
    cross apply (select sc1.CustomerName
                   from sales.Customers sc1
                  where sc1.CustomerName like ('Tailspin Toys%')
        ) as scN

/*
3. В таблице стран есть поля с кодом страны цифровым и буквенным
сделайте выборку ИД страны, название, код - чтобы в поле был либо цифровой либо буквенный код
Пример выдачи

CountryId CountryName Code
1 Afghanistan AFG
1 Afghanistan 4
3 Albania ALB
3 Albania 8
*/

SELECT CountryID,CountryName,code
FROM (select 
       CountryID
      ,CountryName
      ,cast (IsoAlpha3Code  as varchar(6)) as IsoAlpha3Code
      ,cast (IsoNumericCode as varchar(6)) as IsoNumericCode
     
      --,cast(IsoNumericCode as varchar) as IsoNumericCode
  from Application.Countries ac
	) AS country
UNPIVOT (code FOR name IN (IsoAlpha3Code, IsoNumericCode)) AS unpt;

/*
4. Перепишите ДЗ из оконных функций через CROSS APPLY
Выберите по каждому клиенту 2 самых дорогих товара, которые он покупал
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки
*/

select res.*,sc.CustomerName
  from sales.Customers sc
  cross apply  
          (select top 2 * 
             from 
             (SELECT  si.CustomerID
                     ,wsi.StockItemName
                     ,wsi.StockItemID
                     ,wsi.RecommendedRetailPrice
                     ,max(si.InvoiceDate) as InvoiceDate              
                from Sales.Invoices si
                join Sales.InvoiceLines sil 
                  on sil.InvoiceID = si.InvoiceID 
                join Warehouse.StockItems wsi 
                  on wsi.StockItemID = sil.StockItemID          
               GROUP by wsi.StockItemID,si.CustomerID,wsi.RecommendedRetailPrice,wsi.StockItemName
               ) as x
              where x.CustomerID = sc.CustomerID
              order by RecommendedRetailPrice desc
            ) as res


/*
5. Code review (опционально). Запрос приложен в материалы Hometask_code_review.sql.
Что делает запрос?
Чем можно заменить CROSS APPLY - можно ли использовать другую стратегию выборки\запроса?*/

/*SELECT T.FolderId,
		   T.FileVersionId,
		   T.FileId		
	FROM dbo.vwFolderHistoryRemove FHR
	CROSS APPLY (SELECT TOP 1 FileVersionId, FileId, FolderId, DirId
			FROM #FileVersions V
			WHERE RowNum = 1
				AND DirVersionId <= FHR.DirVersionId
			ORDER BY V.DirVersionId DESC) T 

	WHERE FHR.[FolderId] = T.FolderId
	  AND FHR.DirId = T.DirId
	  AND EXISTS (SELECT 1 FROM #FileVersions V WHERE V.DirVersionId <= FHR.DirVersionId)
	  AND NOT EXISTS (
	  		SELECT 1
	  		  FROM dbo.vwFileHistoryRemove DFHR
	  		  WHERE DFHR.FileId = T.FileId
	  	  		AND DFHR.[FolderId] = T.FolderId
	  	  		AND DFHR.DirVersionId = FHR.DirVersionId
	  	  		AND NOT EXISTS (
	  	  			SELECT 1
	  		    		FROM dbo.vwFileHistoryRestore DFHRes
	  		    		WHERE DFHRes.[FolderId] = T.FolderId
	  		    			AND DFHRes.FileId = T.FileId
	  			    		AND DFHRes.PreviousFileVersionId = DFHR.FileVersionId
					)
			)*/

-- vwFolderHistoryRemove видимо история удаления каталогов
-- CROSS APPLY --FileVersionId  возможно последняя версия файла что была из удалённого каталога
-- EXISTS ' проверяют не становлен ли файл уже из того который подобрали в CROSS APPLY

-- наверное запрос для проверки каких-то удалённых архивов
--идеи уверенные что с ходу сделать в голову не приходят, вроде конструкция сходу ужас в глазах не вызывает