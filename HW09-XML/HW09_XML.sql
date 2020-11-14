/*1. Загрузить данные из файла StockItems.xml в таблицу Warehouse.StockItems.
Существующие записи в таблице обновить, отсутствующие добавить (сопоставлять записи по полю StockItemName).
Файл StockItems.xml в личном кабинете.
*/
declare @xml xml
declare @idoc int

SELECT @xml=a FROM OPENROWSET
(
BULK N'C:\otus-mssql-2020-06SvistunDM\otus-mssql-2020-06SvistunDM\HW09-XML\StockItems.xml', SINGLE_CLOB
) as result(a)
--select @xml

DECLARE @docHandle int
EXEC sp_xml_preparedocument @docHandle OUTPUT, @xml

insert into Warehouse.StockItems
 (  [StockItemName]       
       ,[SupplierID]          
       ,[UnitPackageID]       
       ,[OuterPackageID]      
       ,[QuantityPerOuter]    
       ,[TypicalWeightPerUnit]
       ,[LeadTimeDays]        
       ,[IsChillerStock]      
       ,[TaxRate]             
       ,[UnitPrice]   )        

select [StockItemName]       
       ,[SupplierID]          
       ,[UnitPackageID]       
       ,[OuterPackageID]      
       ,[QuantityPerOuter]    
       ,[TypicalWeightPerUnit]
       ,[LeadTimeDays]        
       ,[IsChillerStock]      
       ,[TaxRate]             
       ,[UnitPrice] 

FROM OPENXML(@docHandle, N'/StockItems/Item')
WITH ( 
  [StockItemName]        varchar(200) '@Name',
	[SupplierID]           int  'SupplierID',
	[UnitPackageID]        int 'Package/UnitPackageID',
	[OuterPackageID]       int 'Package/OuterPackageID',
	[QuantityPerOuter]     nvarchar(10) 'Package/QuantityPerOuter',
	[TypicalWeightPerUnit] decimal(18,9) 'Package/TypicalWeightPerUnit',
	[LeadTimeDays]         int 'LeadTimeDays',
  [IsChillerStock]       bit 'IsChillerStock',
  [TaxRate]              decimal(18,9) 'TaxRate',
  [UnitPrice]            decimal(18,9) 'UnitPrice'
  )


/*
2. Выгрузить данные из таблицы StockItems в такой же xml-файл, как StockItems.xml

Примечания к заданиям 1, 2:
* Если с выгрузкой в файл будут проблемы, то можно сделать просто SELECT c результатом в виде XML.
* Если у вас в проекте предусмотрен экспорт/импорт в XML, то можете взять свой XML и свои таблицы.
* Если с этим XML вам будет скучно, то можете взять любые открытые данные и импортировать их в таблицы (например, с https://data.gov.ru).
*/
--declare @xml xml

/*select @xml = --'<?xml version="1.0"?>'+ 
convert( VarChar(max),(SELECT TOP 5
  [StockItemName]        as '@Name',
	[SupplierID]           as 'SupplierID',
	[UnitPackageID]        as 'Package/UnitPackageID',
	[OuterPackageID]       as 'Package/OuterPackageID',
	[QuantityPerOuter]     as 'Package/QuantityPerOuter',
	[TypicalWeightPerUnit] as 'Package/TypicalWeightPerUnit',
	[LeadTimeDays]         as 'LeadTimeDays',
  [IsChillerStock]       as 'IsChillerStock',
  [TaxRate]              as 'TaxRate',
  [UnitPrice]            as 'UnitPrice'
FROM Warehouse.StockItems
FOR XML PATH('Items'), ROOT('StockItems')))
select @xml

DECLARE @Cmd NVARCHAR(4000);
SET @Cmd = N'sqlcmd -S ' + @@SERVERNAME + N' -d ' + DB_NAME() + 
N' -Q "SET NOCOUNT ON; DECLARE @Xml xml = '+char(39)+cast(@xml as varchar(3000))+char(39)+'; SELECT CONVERT(NVARCHAR(MAX), @Xml);" -o "C:\otus-mssql-2020-06SvistunDM\otus-mssql-2020-06SvistunDM\HW09-XML\StockItems1.xml" -y 0';

EXEC master..xp_cmdshell @Cmd, NO_OUTPUT;
*/

DECLARE @query NVARCHAR(max) 
select @query = N'SELECT TOP 5
  [StockItemName]        as ''@Name'',
	[SupplierID]           as ''SupplierID'',
	[UnitPackageID]        as ''Package/UnitPackageID'',
	[OuterPackageID]       as ''Package/OuterPackageID'',
	[QuantityPerOuter]     as ''Package/QuantityPerOuter'',
	[TypicalWeightPerUnit] as ''Package/TypicalWeightPerUnit'',
	[LeadTimeDays]         as ''LeadTimeDays'',
  [IsChillerStock]       as ''IsChillerStock'',
  [TaxRate]              as ''TaxRate'',
  [UnitPrice]            as ''UnitPrice''
FROM Warehouse.StockItems
FOR XML PATH(''Items''), ROOT(''StockItems'')'
SET @query = REPLACE(REPLACE(@query, CHAR(13), ' '), CHAR(10), ' ')

DECLARE @Cmd NVARCHAR(4000) = 'bcp "' + @Query + '" queryout "C:\otus-mssql-2020-06SvistunDM\otus-mssql-2020-06SvistunDM\HW09-XML\StockItems_exported.xml"  -T -c -S .\SQL2017 -d WideWorldImporters';

exec xp_cmdshell @Cmd;

/*
3. В таблице Warehouse.StockItems в колонке CustomFields есть данные в JSON.
Написать SELECT для вывода:
- StockItemID
- StockItemName
- CountryOfManufacture (из CustomFields)
- FirstTag (из поля CustomFields, первое значение из массива Tags)
*/

	SELECT 		
    StockItemID,
		StockItemName,
		json_value(CustomFields, '$.CountryOfManufacture') as CountryOfManufacture
    ,json_value(CustomFields, '$.Tags[0]') as Tags
	FROM Warehouse.StockItems

/*
4. Найти в StockItems строки, где есть тэг "Vintage".
Вывести:
- StockItemID
- StockItemName
- (опционально) все теги (из CustomFields) через запятую в одном поле

Тэги искать в поле CustomFields, а не в Tags.
Запрос написать через функции работы с JSON.
Для поиска использовать равенство, использовать LIKE запрещено.

Должно быть в таком виде:
... where ... = 'Vintage'

Так принято не будет:
... where ... Tags like '%Vintage%'
... where ... CustomFields like '%Vintage%'
*/

	SELECT 		
    StockItemID,
		StockItemName,
		CustomFields

    ,CustomFields
	FROM Warehouse.StockItems
  WHERE 'Vintage' IN ( SELECT value FROM OPENJSON(CustomFields,'$.Tags'))  

  SELECT
  wsi.StockItemID,
  wsi.StockItemName,
  wsi.CustomFields
FROM Warehouse.StockItems wsi
CROSS APPLY OPENJSON(wsi.CustomFields,'$.Tags') as tags
WHERE tags.value = 'Vintage'

/*
5. Пишем динамический PIVOT.
По заданию из занятия “Операторы CROSS APPLY, PIVOT, CUBE”.
Требуется написать запрос, который в результате своего выполнения формирует таблицу следующего вида:
Название клиента
МесяцГод Количество покупок

Нужно написать запрос, который будет генерировать результаты для всех клиентов.
Имя клиента указывать полностью из CustomerName.
Дата должна иметь формат dd.mm.yyyy например 01.12.2019*/



   DECLARE @R AS NVARCHAR(MAX),
    @query  AS NVARCHAR(MAX);

SET @R = STUFF((SELECT distinct ',' + QUOTENAME(sc.CustomerName) 
                    from sales.Invoices si 
                    join sales.Customers sc 
                      on sc.CustomerID = si.CustomerID
                    where si.CustomerID >=1
                      and si.CustomerID<=20
                   group by CustomerName,year(si.InvoiceDate),month(si.InvoiceDate)
            FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)') 
        ,1,1,'')
 
 --select @R

set @query = N'

select convert(varchar(10),InvoiceDate ,104) as InvoiceDate, ' + @R + '

  from (select sc.CustomerName
         ,cast(cast(year(si.InvoiceDate) as varchar)+format(month(si.InvoiceDate),''00'')+''01'' as date) as InvoiceDate
         ,count(si.InvoiceID) as num
    from sales.Invoices si 
    join sales.Customers sc 
      on sc.CustomerID = si.CustomerID
   where si.CustomerID >=1
     and si.CustomerID <=20
   group by CustomerName,year(si.InvoiceDate),month(si.InvoiceDate)
  -- order by year(si.InvoiceDate),month(si.InvoiceDate)
   ) as CusIn
 pivot(sum(CusIn.num) FOR CustomerName
IN (' + @R + ')
)AS PivotTable'

select len (@query)
execute(@query)
