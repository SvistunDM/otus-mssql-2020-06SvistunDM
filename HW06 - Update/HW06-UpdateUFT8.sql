/*Insert, Update, Merge
1. Довставлять в базу 5 записей используя insert в таблицу Customers или Suppliers
2. удалите 1 запись из Customers, которая была вами добавлена
3. изменить одну запись, из добавленных через UPDATE
4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть
5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert*/

--1. Довставлять в базу 5 записей используя insert в таблицу Customers или Suppliers
USE [WideWorldImporters]
GO
declare @id int,@n int
declare @name varchar (100)

select @n=0
select @id = max(CustomerID) from [Sales].[Customers]
---select * from [Sales].[Customers]
while @n<5 begin
select @n=@n+1,@id=@id+1
select @name = 'Name'+convert(varchar(10),@id)

INSERT INTO [Sales].[Customers]
           ([CustomerID]
           ,[CustomerName]
           ,[BillToCustomerID]
           ,[CustomerCategoryID]
           ,[PrimaryContactPersonID]
           ,[DeliveryMethodID]
           ,[DeliveryCityID]
           ,[PostalCityID]
           ,[AccountOpenedDate]
           ,[StandardDiscountPercentage]
           ,[IsStatementSent]
           ,[IsOnCreditHold]
           ,[PaymentDays]
           ,[PhoneNumber]
           ,[FaxNumber]
           ,[WebsiteURL]
           ,[DeliveryAddressLine1]
           ,[DeliveryPostalCode]
           ,[DeliveryLocation]
           ,[PostalAddressLine1]
           ,[PostalPostalCode]
           ,[LastEditedBy])
select     @id                                                                 
           ,@name                                                            
           ,@id                                                           
           ,3                                                               
           ,3134                                                            
           ,3                                                               
           ,23264                                                           
           ,31009                                                           
           ,'19000101'                                                      
           ,0                                                              
           ,0                                                               
           ,0                                                               
           ,1                                                               
           ,'(215) 555-0100'                                                
           ,'(215) 555-0101'                                                
           ,'http://www.microsoft.com/JayBhuiyan/'                          
           ,'Suite 22'                                                                                               
           ,'90081'                                                         
           ,0xE6100000010CFF1E61BDF6444140A89A0FBE66B253C0                  
           ,'PO Box 8070'                                                   
           ,'90492'                                                         
           ,1                                                               
                                                                              

end
--2. удалите 1 запись из Customers, которая была вами добавлена

delete from [Sales].[Customers] where [CustomerID] = @id
--3. изменить одну запись, из добавленных через UPDATE
update c  
   set CustomerName = 'Почти Вася, но серёжа'
  from [Sales].[Customers] c where c.[CustomerID] = @id-1
--4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть

MERGE [Sales].[Customers] AS target  -- таблица которую будем менять, таблица приемник
USING (SELECT top 1 CustomerID +  convert(bit, round(1*rand(),0)) as CustomerID 
            , CustomerName +'ЧЧЧ' as CustomerName
            , BillToCustomerID
            , CustomerCategoryID
            , BuyingGroupID
            , PrimaryContactPersonID
            , AlternateContactPersonID
            , DeliveryMethodID
            , DeliveryCityID
            , PostalCityID
            , CreditLimit
            , AccountOpenedDate
            , StandardDiscountPercentage
            , IsStatementSent
            , IsOnCreditHold
            , PaymentDays
            , PhoneNumber
            , FaxNumber
            , DeliveryRun
            , RunPosition
            , WebsiteURL
            , DeliveryAddressLine1
            , DeliveryAddressLine2
            , DeliveryPostalCode
            , DeliveryLocation
            , PostalAddressLine1
            , PostalAddressLine2
            , PostalPostalCode
            , LastEditedBy

      FROM [Sales].[Customers] order by CustomerID desc ) AS source 
  ON (target.CustomerID = source.CustomerID)  -- условие по которому сопоставляем источник и приемник
WHEN MATCHED AND target.CustomerName!=source.CustomerName -- Если такой уже есть, то проверяем не совпадает ли Name и если не совпадает то меняем
    THEN UPDATE SET target.CustomerName = source.CustomerName -- обновляем
WHEN NOT MATCHED  -- если такого Id нет в таблице target то добавляем
    THEN INSERT(CustomerID
                ,CustomerName
                ,BillToCustomerID
                ,CustomerCategoryID
                ,BuyingGroupID
                ,PrimaryContactPersonID
                ,AlternateContactPersonID
                ,DeliveryMethodID
                ,DeliveryCityID
                ,PostalCityID
                ,CreditLimit
                ,AccountOpenedDate
                ,StandardDiscountPercentage
                ,IsStatementSent
                ,IsOnCreditHold
                ,PaymentDays
                ,PhoneNumber
                ,FaxNumber
                ,DeliveryRun
                ,RunPosition
                ,WebsiteURL
                ,DeliveryAddressLine1
                ,DeliveryAddressLine2
                ,DeliveryPostalCode
                ,DeliveryLocation
                ,PostalAddressLine1
                ,PostalAddressLine2
                ,PostalPostalCode
                ,LastEditedBy)
        VALUES( source.CustomerID
                      , source.CustomerName
                      , source.BillToCustomerID
                      , source.CustomerCategoryID
                      , source.BuyingGroupID
                      , source.PrimaryContactPersonID
                      , source.AlternateContactPersonID
                      , source.DeliveryMethodID
                      , source.DeliveryCityID
                      , source.PostalCityID
                      , source.CreditLimit
                      , source.AccountOpenedDate
                      , source.StandardDiscountPercentage
                      , source.IsStatementSent
                      , source.IsOnCreditHold
                      , source.PaymentDays
                      , source.PhoneNumber
                      , source.FaxNumber
                      , source.DeliveryRun
                      , source.RunPosition
                      , source.WebsiteURL
                      , source.DeliveryAddressLine1
                      , source.DeliveryAddressLine2
                      , source.DeliveryPostalCode
                      , source.DeliveryLocation
                      , source.PostalAddressLine1
                      , source.PostalAddressLine2
                      , source.PostalPostalCode
                      , source.LastEditedBy

    
    ); -- добавление записи

--5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert

-- To allow advanced options to be changed.  
EXEC sp_configure 'show advanced options', 1;  
GO  
-- To update the currently configured value for advanced options.  
RECONFIGURE;  
GO  
-- To enable the feature.  
EXEC sp_configure 'xp_cmdshell', 1;  
GO  
-- To update the currently configured value for this feature.  
RECONFIGURE;  
GO  

SELECT @@SERVERNAME
declare @sql varchar(max),@sqlDiff varchar(40), @fileAndPath varchar(255)
select @fileAndPath = 'C:\bulk\SalesCustomers.txt'
select @sqlDiff = '@#Differ#'

select @sql = 'exec master..xp_cmdshell '+char(39)+'bcp "[WideWorldImporters].[Sales].[Customers]" out  "'
+@fileAndPath+'" -T -w -t"'
+@sqlDiff+'" -S '+@@SERVERNAME+char(39)

select @sql,@fileAndPath
EXEC (@sql)


drop table if exists [WideWorldImporters].[Sales].[Customers_Bulk]

CREATE TABLE [WideWorldImporters].[Sales].[Customers_Bulk](
	[CustomerID] int NOT NULL,
	[CustomerName] nvarchar(100) NOT NULL,
	[BillToCustomerID] int NOT NULL,
	[CustomerCategoryID] int NOT NULL,
	[BuyingGroupID] int NULL,
	[PrimaryContactPersonID] int NOT NULL,
	[AlternateContactPersonID] int NULL,
	[DeliveryMethodID] int NOT NULL,
	[DeliveryCityID] int NOT NULL,
	[PostalCityID] int NOT NULL,
	[CreditLimit] decimal(18, 2) NULL,
	[AccountOpenedDate] date NOT NULL,
	[StandardDiscountPercentage] decimal(18, 3) NOT NULL,
	[IsStatementSent] bit NOT NULL,
	[IsOnCreditHold] bit NOT NULL,
	[PaymentDays] int NOT NULL,
	[PhoneNumber] nvarchar(20) NOT NULL,
	[FaxNumber] nvarchar(20) NOT NULL,
	[DeliveryRun] nvarchar(5) NULL,
	[RunPosition] nvarchar(5) NULL,
	[WebsiteURL] nvarchar(256) NOT NULL,
	[DeliveryAddressLine1] nvarchar(60) NOT NULL,
	[DeliveryAddressLine2] nvarchar(60) NULL,
	[DeliveryPostalCode] nvarchar(10) NOT NULL,
	[DeliveryLocation] geography NULL,
	[PostalAddressLine1] nvarchar(60) NOT NULL,
	[PostalAddressLine2] nvarchar(60) NULL,
	[PostalPostalCode] nvarchar(10) NOT NULL,
	[LastEditedBy] int NOT NULL,
	[ValidFrom] datetime2,
	[ValidTo] datetime2
  )
----




select @sql = 
	'BULK INSERT [WideWorldImporters].[Sales].[Customers_Bulk]
				   FROM '+char(39)+@fileAndPath+char(39)+
				   'WITH 
					 (
						BATCHSIZE = 1000, 
						DATAFILETYPE = '+char(39)+'widechar'+char(39)+',
						FIELDTERMINATOR = '+char(39)+@sqlDiff+char(39)+',
						ROWTERMINATOR ='+char(39)+'\n'+char(39)+',
						KEEPNULLS,
						TABLOCK        
					  );'
select @sql
EXEC (@sql)


select Count(*) from [Sales].[Customers_Bulk];

TRUNCATE TABLE [Sales].[Customers_Bulk];