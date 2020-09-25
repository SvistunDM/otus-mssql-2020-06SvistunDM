/*����� ��������� ��������� DDL �������:
1. ������� ���� ������.*/
--drop database Science
Create database Science
go
use Science
go
/*2. 3-4 �������� ������� ��� ������ �������.*/
IF OBJECT_ID (N'institution', N'U') IS NULL 
Create table institution   --����������� ���� ������������� ��������
(InstitutionID numeric(20) not null,
 Brief varchar(30),
 name varchar(255),
 comment varchar(255),
 TypeID numeric(20)
  CONSTRAINT check_name CHECK 
    (name like '[�-�]%')
)

IF OBJECT_ID (N'GroupInst', N'U') IS NULL 
Create table GroupInst   --������ ������
(GroupInstID numeric(20) not null,
 Brief varchar(30),
 name varchar(255),
 DateStart datetime,
 DateEnd datetime,
 InstitutionID numeric(20),
 CourseID numeric(20),
 Comment varchar(255),
 TypeID numeric(20)
 CONSTRAINT check_DateStart CHECK 
 (DateStart <>'19000101')
)

IF OBJECT_ID (N'course', N'U') IS NULL 
Create table course   --����, �����������,�������������
(courseID numeric(20) not null,
 Brief varchar(30),
 name varchar(255),
 InstitutionID numeric(20),
 Comment varchar(255),
 TypeID numeric(20)
  CONSTRAINT check_Comment CHECK 
 (Comment <>'')
)

IF OBJECT_ID (N'type', N'U') IS NULL 
Create table type --��� ����
(TypeID numeric(20) not null,
 Brief varchar(30),
 name varchar(255),
 TypeOfTypeId numeric(20) null
   CONSTRAINT check_name CHECK 
 (len(name) > 1)
)

IF OBJECT_ID (N'Contact', N'U') IS NULL 
Create table Contact   --�������
(ContactID numeric(20) not null,
 InstitutionID numeric(20),
 name varchar(255),
 typeID numeric(20)
 CONSTRAINT check_name CHECK 
 (len(name) > 5)
)

go

/*3. ��������� � ������� ����� ��� ���� ��������� ������.*/
/*4. 1-2 ������� �� �������.*/
/*5. �������� �� ������ ����������� � ������ ������� �� ���� ������.*/
ALTER TABLE [institution] ADD  CONSTRAINT [PK_institution] PRIMARY KEY CLUSTERED 
(
	[institutionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, 
ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

ALTER TABLE [GroupInst] ADD  CONSTRAINT [PK_GroupInst] PRIMARY KEY CLUSTERED 
(
	[GroupInstID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, 
ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

ALTER TABLE [course] ADD  CONSTRAINT [PK_course] PRIMARY KEY CLUSTERED 
(
	[courseID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, 
ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO


ALTER TABLE [type] ADD  CONSTRAINT [PK_type] PRIMARY KEY CLUSTERED 
(
	[typeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, 
ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO


ALTER TABLE [Contact] ADD  CONSTRAINT [PK_Contact] PRIMARY KEY CLUSTERED 
(
	[ContactID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, 
ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
--���������
ALTER TABLE [institution]  
WITH CHECK ADD  CONSTRAINT [FK_institution_TypeID_Type_TypeID] FOREIGN KEY([TypeID])
REFERENCES [type] ([TypeID])
GO

ALTER TABLE [GroupInst]  
WITH CHECK ADD  CONSTRAINT [FK_GroupInst_InstitutionID_Institution_InstitutionID] FOREIGN KEY([InstitutionID])
REFERENCES [Institution] ([InstitutionID])
GO

ALTER TABLE [GroupInst]  
WITH CHECK ADD  CONSTRAINT [FK_GroupInst_CourseID_Course_CourseID] FOREIGN KEY([CourseID])
REFERENCES [Course] ([CourseID])
GO



/*
institution(TypeID)
GroupInst(CourseID,InstitutionID,TypeID)
course(InstitutionID,TypeID)
type(TypeOfTypeId)
Contact(InstitutionID,TypeID)
*/




ALTER TABLE [Institution] ADD  CONSTRAINT [UQ_Institution_Name] UNIQUE NONCLUSTERED 
(
	[Name] ASC
)WITH (PAD_INDEX = OFF, 
STATISTICS_NORECOMPUTE = OFF, 
SORT_IN_TEMPDB = OFF, 
IGNORE_DUP_KEY = OFF, 
ONLINE = OFF, 
ALLOW_ROW_LOCKS = ON, 
ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

ALTER TABLE [Institution] ADD  CONSTRAINT [UQ_Institution_Brief] UNIQUE NONCLUSTERED 
(
	[Brief] ASC
)WITH (PAD_INDEX = OFF, 
STATISTICS_NORECOMPUTE = OFF, 
SORT_IN_TEMPDB = OFF, 
IGNORE_DUP_KEY = OFF, 
ONLINE = OFF, 
ALLOW_ROW_LOCKS = ON, 
ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

