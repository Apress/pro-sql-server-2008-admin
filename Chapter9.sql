--Listing 9-1*********************************************************************
CREATE DATABASE Test_Snapshot_1 
 ON
(Name = AdventureWorks_Data,
 FileName = 'C:\Test_Data.ss')
 AS SNAPSHOT OF AdventureWorks

--Listing 9-2*********************************************************************
CREATE DATABASE <Snapshot Name>
 ON
(Name = <Logical_FileName_1>,
 FileName =<Snapshot File Location 1>),
(Name =<Logical_FileName_2>,
 FileName =<Snapshot File Location 2>)
 AS SNAPSHOT OF <DatabaseName>
 
--Listing 9-3*********************************************************************
SELECT B.name DatabaseName,
               A.name LogicalName,
               B.database_id,
               B.source_database_id,
               A.physical_name
 FROM master.sys.master_files A
             JOIN master.sys.databases B
            ON   A.database_id = B.database_id

--Listing 9-4*********************************************************************
Use master
GO
RESTORE DATABASE AdventureWorks FROM DATABASE_SNAPSHOT = 'Test_Snapshot_1'

--Listing 9-5*********************************************************************
Use AdventureWorks2008
GO

Create Table Orders
(OrderID int identity,
 OrderDate DateTime NOT NULL
   CONSTRAINT [DF_Orders_OrderDate] DEFAULT (getdate()) ) 

--Listing 9-6*********************************************************************
Use AdventureWorks2008
GO

--Drop the table if it currently exists
IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL
  DROP TABLE dbo.Orders;

--Create the Orders table
Create Table Orders
(OrderID int identity ,
 OrderDate DateTime NOT NULL) 

--Alter the Orders table to add the default constraint
 ALTER TABLE dbo.Orders 
 ADD CONSTRAINT [DF_Orders_OrderDate] 
 DEFAULT (getdate()) FOR OrderDate

--Listing 9-7*********************************************************************
Use AdventureWorks2008
GO

--Drop the table if it currently exists
IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL
  DROP TABLE dbo.Orders;

--Create the Orders table
Create Table Orders
(OrderID int NOT NULL) 

--Insert 3 records into the Orders table
Insert Into Orders (OrderID) 
Values(1),(2),(3)

--Alter the table to add the default
 ALTER TABLE dbo.Orders 
 ADD OrderDate Datetime  NULL
 CONSTRAINT [DF_Orders_OrderDate] 
 DEFAULT (getdate()) WITH VALUES

 --Select to see the default was applied to the existing rows
 Select OrderID, OrderDate From Orders

--Listing 9-8*********************************************************************
ALTER TABLE Orders DROP CONSTRAINT DF_Orders_OrderDate

--Listing 9-9*********************************************************************
Use AdventureWorks2008
GO

--Drop the table if it currently exists
IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL
  DROP TABLE dbo.Orders;

--Create the Orders table
Create Table Orders
(OrderID int NOT NULL CONSTRAINT PK_ORDERS PRIMARY KEY CLUSTERED)

--Listing 9-10*********************************************************************
Use AdventureWorks2008
GO

--Drop the table if it currently exists
IF OBJECT_ID('dbo.OrderDetails', 'U') IS NOT NULL
  DROP TABLE dbo.OrderDetails;

--Create the OrderDetails table
Create Table OrderDetails
(OrderID int NOT NULL,
 ProductID int NOT NULL) 

--Alter the OrderDetails table to add a composite key
ALTER TABLE OrderDetails 
ADD  CONSTRAINT PK_Order_Details PRIMARY KEY CLUSTERED 
(OrderID,
 ProductID)

--Listing 9-11*********************************************************************
ALTER TABLE OrderDetails DROP CONSTRAINT PK_Order_Details

--Listing 9-12*********************************************************************
Use AdventureWorks2008
GO

--Drop the table if it currently exists
IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL
  DROP TABLE dbo.Orders;

--Create the Orders table
Create Table Orders
(OrderID int NOT NULL CONSTRAINT PK_ORDERS PRIMARY KEY CLUSTERED,
 OrderNumber int NULL CONSTRAINT UQ_ORDER_NUMBER UNIQUE NONCLUSTERED)

--Listing 9-13*********************************************************************
Use AdventureWorks2008
GO

--Drop the table if it currently exists
IF OBJECT_ID('dbo.OrderDetails', 'U') IS NOT NULL
  DROP TABLE dbo.OrderDetails;

--Create the OrderDetails table
Create Table OrderDetails
(OrderID int NOT NULL CONSTRAINT PK_ORDERDETAILS PRIMARY KEY CLUSTERED,
 OrderNumber int NULL,
 CustomerNumber int NOT NULL) 

--Alter the OrderDetails table to add the unique constraint
ALTER TABLE OrderDetails 
ADD  CONSTRAINT UQ_ORDER_CUSTOMER_NBR UNIQUE
(OrderNumber,
 CustomerNumber)

--Listing 9-14*********************************************************************
ALTER TABLE OrderDetails DROP CONSTRAINT UQ_ORDER_CUSTOMER_NBR

--Listing 9-15*********************************************************************
Use AdventureWorks2008
GO

--Drop the tables if they currently exist
IF OBJECT_ID('dbo.OrderDetails', 'U') IS NOT NULL
  DROP TABLE dbo.OrderDetails;

IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL
  DROP TABLE dbo.Orders;

--Create the tables
Create Table Orders
(OrderID int NOT NULL CONSTRAINT PK_ORDERS PRIMARY KEY CLUSTERED,
OrderNumber int NULL CONSTRAINT UQ_ORDER_NUMBER UNIQUE NONCLUSTERED)
 
Create Table OrderDetails
(OrderDetailID int IDENTITY (1,1) NOT NULL 
CONSTRAINT PK_ORDER_DETAILS PRIMARY KEY CLUSTERED,
OrderID int NOT NULL,
ProductID int NOT NULL) 

--Add the foreign key constraint
ALTER TABLE OrderDetails WITH NOCHECK
ADD CONSTRAINT FK_OrderDetails_Orders FOREIGN KEY(OrderID) 
REFERENCES Orders (OrderID) 
ON UPDATE  CASCADE 
ON DELETE  CASCADE

--Listing 9-16*********************************************************************
--Disable the FK_OrderDetails_Orders constraint on the OrderDetails table
ALTER TABLE OrderDetails NOCHECK CONSTRAINT FK_OrderDetails_Orders 

--Disable the all constraints on the OrderDetails table
ALTER TABLE OrderDetails NOCHECK CONSTRAINT ALL

--Enable the FK_OrderDetails_Orders constraint on the OrderDetails table
ALTER TABLE OrderDetails CHECK CONSTRAINT FK_OrderDetails_Orders

--Enable the all constraints on the OrderDetails table
ALTER TABLE OrderDetails CHECK CONSTRAINT ALL

--Listing 9-17*********************************************************************
ALTER TABLE dbo.OrderDetails DROP CONSTRAINT FK_OrderDetails_Orders

--Listing 9-18*********************************************************************
Use AdventureWorks2008
GO

--Drop the Table if it currently exists
IF OBJECT_ID('dbo.CustInfo', 'U') IS NOT NULL
  DROP TABLE dbo.CustInfo;

CREATE TABLE CustInfo
(CustID int IDENTITY(1,1) PRIMARY KEY,
 DateOfBirth DATE 
 CONSTRAINT ValidDateOfBirth 
 CHECK (DateOfBirth > '1/1/1900' AND DateOfBirth < getdate()))

--Listing 9-19*********************************************************************
Use AdventureWorks2008
GO

--Drop the table if it currently exists
IF OBJECT_ID('dbo.CustInfo', 'U') IS NOT NULL
  DROP TABLE dbo.CustInfo;

--Create the table
CREATE TABLE CustInfo
(CustID int IDENTITY(1,1) PRIMARY KEY,
 DateOfBirth DATE)

--Alter the table to add the check constraint
ALTER TABLE CustInfo WITH NOCHECK
ADD CONSTRAINT ValidDateOfBirth 
CHECK (DateOfBirth > '1/1/1900' AND DateOfBirth < getdate())

--Listing 9-20*********************************************************************
ALTER TABLE CustInfo DROP CONSTRAINT ValidDateOfBirth

--Listing 9-21*********************************************************************
Use AdventureWorks2008
GO

--Drop the table if it currently exists
IF OBJECT_ID('dbo.CustInfo', 'U') IS NOT NULL
  DROP TABLE dbo.CustInfo;

--Create the table
CREATE TABLE CustInfo 
(CustID INT PRIMARY KEY, 
Addr_Line1 VARCHAR(100) NOT NULL, 
Addr_Line2 VARCHAR(100) NOT NULL, 
Addr_Line3 VARCHAR(100) NULL, 
Addr_Line4 VARCHAR(100) NULL, 
Addr_Line5 VARCHAR(100) SPARSE NULL, 
Addr_Line6 VARCHAR(100) SPARSE NULL)

--Listing 9-22*********************************************************************
ALTER TABLE CustInfo ALTER COLUMN Addr_Line4 ADD SPARSE

--Listing 9-23*********************************************************************
ALTER TABLE CustInfo ALTER COLUMN Addr_Line4 DROP SPARSE

--Listing 9-24*********************************************************************
Use AdventureWorks2008
GO

--Drop the table if it currently exists
IF OBJECT_ID('dbo.CustInfo', 'U') IS NOT NULL
  DROP TABLE dbo.CustInfo;

--Create the table with page compression
Create Table Orders
(OrderID int identity,
OrderDate DateTime NOT NULL)
WITH (DATA_COMPRESSION = PAGE)

--Listing 9-25*********************************************************************
ALTER TABLE Orders
REBUILD WITH (DATA_COMPRESSION = ROW)

--Listing 9-26*********************************************************************
USE AdventureWorks2008
GO

--Create partition function
CREATE PARTITION FUNCTION SamplePartitionFunction (Datetime)
AS RANGE RIGHT FOR VALUES ('1/1/2000');
GO

--Create partition scheme
CREATE PARTITION SCHEME SamplePartitionScheme
AS PARTITION SamplePartitionFunction
TO ([PRIMARY], [PRIMARY]);
GO

--Create partition table
CREATE TABLE SamplePartitionTable
 (ID INT NOT NULL,
 SomeDateColumn DATETIME)
 ON SamplePartitionScheme (SomeDateColumn);
GO

--Insert sample data
INSERT INTO SamplePartitionTable
VALUES (1,'1/1/1999'), (2,'1/15/1999'), (3,'1/21/1999'),
 (4,'1/1/2000'), (5,'1/20/2006')

--Query the sys.partitions table to show the inserted rows for each partition
SELECT partition_number, rows
FROM sys.partitions 
WHERE object_id = OBJECT_ID('SamplePartitionTable')

--Listing 9-27*********************************************************************
Use AdventureWorks2008
GO

Create Table Employee
(EmpID int NOT NULL CONSTRAINT PK_EMP PRIMARY KEY CLUSTERED,
EmpFisrtName Varchar(50),
EmpLastName Varchar(50),
EmpSSN Varchar(9),
DepartmentID int)
GO

Create Table Department
(DepartmentID int NOT NULL CONSTRAINT PK_DEPT PRIMARY KEY CLUSTERED,
DeparmentDscr Varchar(50))
GO

CREATE VIEW vMarketingEmployees
WITH ENCRYPTION
AS
SELECT dbo.Employee.EmpFisrtName AS FirstName, 
       dbo.Employee.EmpLastName AS LastName, 
       dbo.Department.DeparmentDscr AS Department
FROM  dbo.Department INNER JOIN
      dbo.Employee ON dbo.Department.DepartmentID = dbo.Employee.DepartmentID
WHERE dbo.Department.DepartmentID = 1

--Listing 9-28*********************************************************************
Use AdventureWorks2008
GO

ALTER VIEW vMarketingEmployees
AS
SELECT dbo.Employee.EmpFisrtName AS FirstName, 
       dbo.Employee.EmpLastName AS LastName, 
       dbo.Department.DeparmentDscr AS Department
FROM  dbo.Department INNER JOIN
      dbo.Employee ON dbo.Department.DepartmentID = dbo.Employee.DepartmentID
WHERE dbo.Department.DepartmentID = 2

--Listing 9-29*********************************************************************
DROP VIEW vMarketingEmployees

--Listing 9-30*********************************************************************
CREATE VIEW vDistributedSample
AS
Select col1, col2, col3 FROM Server1.DBName.dbo.TableName
UNION ALL
Select col1, col2, col3 FROM Server2. DBName.dbo.TableName
UNION ALL
Select col1, col2, col3 FROM Server3.DBName.dbo.TableName

--Listing 9-31*********************************************************************
Use AdventureWorks2008
GO

--Drop the view if it currently exists
IF OBJECT_ID('dbo.vMarketingEmployees', 'V') IS NOT NULL
  DROP VIEW dbo.vMarketingEmployees;

GO

--Create a view using the WITH CHECK option
CREATE VIEW vMarketingEmployees
AS
SELECT dbo.Employee.EmpFisrtName AS FirstName, 
       dbo.Employee.EmpLastName AS LastName, 
       dbo.Department.DepartmentID,
       dbo.Department.DeparmentDscr AS Department
FROM  dbo.Department INNER JOIN
      dbo.Employee ON dbo.Department.DepartmentID = dbo.Employee.DepartmentID
WHERE dbo.Department.DepartmentID = 1
WITH CHECK OPTION

--Listing 9-32*********************************************************************
USE AdventureWorks2008
GO

CREATE VIEW vEmployees
WITH SCHEMABINDING
AS
SELECT dbo.Employee.EmpFisrtName AS FirstName, 
       dbo.Employee.EmpLastName AS LastName, 
       dbo.Department.DepartmentID,
       dbo.Department.DeparmentDscr AS Department
FROM  dbo.Department INNER JOIN
      dbo.Employee ON dbo.Department.DepartmentID = dbo.Employee.DepartmentID
GO
--Create an index on the view
CREATE UNIQUE CLUSTERED INDEX IDX_vEmployee_Dept
 ON vEmployees (DepartmentID);
GO

--Listing 9-33*********************************************************************
USE AdventureWorks2008
GO

CREATE PROCEDURE dbo.DepartmentNameByGroup_Select (@GroupName nvarchar(50))
AS
Select DepartmentID, 
           Name AS DepartmentName
From HumanResources.Department
Where GroupName = @GroupName

GO
--Execute the stored procedure
EXEC dbo.DepartmentNameByGroup_Select 'Executive General and Administration'

--Listing 9-34*********************************************************************
USE AdventureWorks2008
GO
ALTER PROCEDURE dbo.DepartmentNameByGroup_Select
 (@GroupName nvarchar(50),
  @DepartmentCount int OUTPUT)
AS
SELECT  DepartmentID,
            Name AS DepartmentName
FROM HumanResources.Department
WHERE GroupName = @GroupName
GROUP BY DepartmentID,
         Name;
 
SELECT @DepartmentCount=COUNT(1) 
FROM HumanResources.Department
WHERE GroupName = @GroupName;
GO

--Execute the stored procedure
DECLARE @NbrOfDepartments int

EXEC dbo.DepartmentNameByGroup_Select 
     'Executive General and Administration',
     @NbrOfDepartments OUTPUT
     
Select 'There Are ' +  
Cast(@NbrOfDepartments as varchar(50)) + 
' Departments In This Group.'

--Listing 9-35*********************************************************************
USE AdventureWorks2008
GO
ALTER PROCEDURE dbo.DepartmentNameByGroup_Select
 (@GroupName nvarchar(50))
AS
SELECT  DepartmentID,
            Name AS DepartmentName
FROM HumanResources.Department
WHERE GroupName = @GroupName
GROUP BY DepartmentID,
         Name;
 
RETURN (SELECT COUNT(1) 
        FROM HumanResources.Department
        WHERE GroupName = @GroupName);

GO

--Execute the stored procedure
DECLARE @NbrOfDepartments int

EXEC @NbrOfDepartments = 
     dbo.DepartmentNameByGroup_Select 'Executive General and Administration'
     
Select 'There Are ' + 
Cast(@NbrOfDepartments as varchar(50)) +  
' Departments In This Group.'

--Listing 9-36*********************************************************************
USE AdventureWorks2008
GO
EXEC sp_recompile 'dbo.DepartmentNameByGroup_Select'
GO

--Listing 9-37*********************************************************************
DROP PROCEDURE dbo.DepartmentNameByGroup_Select
GO
--Listing 9-38*********************************************************************
sp_procoption @ProcName = 'uspSystemMaintenance', 
              @OptionName = 'startup', 
              @OptionValue = 'on'

--Listing 9-39*********************************************************************
--Create sample tables
CREATE TABLE CustOrders
(OrderID int PRIMARY KEY,
 CustID int,
 InvoiceAmt float)
 
CREATE TABLE Customers
 (CustID int PRIMARY KEY,
 CustName varchar(50))

--Insert sample data
INSERT INTO Customers 
VALUES (1,'Ken Simmons'),(2,'Sylvester Carstarphen')

INSERT INTO CustOrders
Values (1,1,500.25),(2,1,124.73),(3,1,42.86),(4,2,120.80),(5,2,12.74)
GO

--Create function to return running balance
CREATE FUNCTION dbo.udf_RunningSalesBalance
 (@CustID int,
 @OrderID int)
RETURNS float
AS 
BEGIN 
     RETURN (Select SUM(InvoiceAmt) 
                       From CustOrders 
                      Where CustID = @CustID AND OrderID <= @OrderID)
END

GO

--Query the new function
Select OrderID, 
           CustName,
           InvoiceAmt, 
           dbo.udf_RunningSalesBalance(Customers.CustID, OrderID) RunningSales
From Customers JOIN
          CustOrders ON Customers.CustID = CustOrders.CustID
GO

--Listing 9-40*********************************************************************
CREATE FUNCTION dbo.udf_TotalSalesByCustomer (@CustID int)
RETURNS TABLE
AS
RETURN 
(
 SELECT Customers.CustID, 
            CustName,
            SUM(InvoiceAmt) TotalSales 
 FROM Customers JOIN
           CustOrders ON Customers.CustID = CustOrders.CustID
 WHERE Customers.CustID = @CustID
 GROUP BY Customers.CustID, 
          CustName
)
GO

--Query the inline table-valued function with CustID 1
SELECT A.CustID,
           A.CustName,
           CustOrders.OrderID,
           CustOrders.InvoiceAmt,
           A.TotalSales
FROM dbo.udf_TotalSalesByCustomer(1) A 
     JOIN  CustOrders ON A.CustID = CustOrders.CustID
GO

--Listing 9-41*********************************************************************
CREATE FUNCTION dbo.udf_CustomerDiscount (@CustID int)
RETURNS @CustDiscount TABLE
          (OrderID int,
           InvoiceAmt float,
           InvoiceAmtWithDiscount decimal(10,2))
AS
BEGIN
  IF (SELECT SUM(InvoiceAmt) 
      FROM CustOrders 
      WHERE CustID = @CustID) > 500
      
      BEGIN
         INSERT INTO @CustDiscount 
         SELECT OrderID, InvoiceAmt, InvoiceAmt * .9
         FROM CustOrders 
         WHERE CustID = @CustID
      END
  ELSE
    BEGIN
         INSERT INTO @CustDiscount 
         SELECT OrderID, InvoiceAmt, InvoiceAmt
         FROM CustOrders 
         WHERE CustID = @CustID
    END
         
 RETURN 
      
END

GO

--Query the multi-statement table-valued function
SELECT * FROM dbo.udf_CustomerDiscount(1)

--Listing 9-42*********************************************************************
DROP FUNCTION dbo.udf_CustomerDiscount

--Listing 9-43*********************************************************************
USE AdventureWorks2008
GO

CREATE TRIGGER Sales.ModificationCheck
ON Sales.Store
AFTER UPDATE, DELETE
AS
IF (SELECT COUNT(*) FROM inserted ) > 1 OR 
    (SELECT COUNT(*) FROM deleted) > 1
    BEGIN
       RAISERROR('You may only modify one row at a time.',10,1); 
       ROLLBACK TRANSACTION
    END
GO

--Try to update multiple rows
UPDATE Sales.Store
SET Name = Name + '_1' 
--WHERE Sales.Store.BusinessEntityID = 292

--Listing 9-44*********************************************************************
USE AdventureWorks2008
GO

CREATE TRIGGER DropTableCheck
ON DATABASE 
FOR DROP_TABLE
AS 
DECLARE @EventData AS Varchar(1000)
SELECT @EventData= EVENTDATA().value
('(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]','nvarchar(max)')

DECLARE @Msg Varchar(1000)

IF (SELECT CAST(GETDATE() AS TIME)) > '08:00' AND 
    (SELECT CAST(GETDATE() AS TIME)) < '22:00'
     BEGIN
       SET @Msg = 'The Command - "' + @EventData + 
           '" is not allowed. You must drop tables during the maintence window.'
       RAISERROR (@Msg,10, 1)
       ROLLBACK TRANSACTION
     END
GO

--Create a sample table
CREATE TABLE VeryImportantTable
(ID INT)
GO

--Try to drop the table
DROP TABLE VeryImportantTable
GO

--Listing 9-45*********************************************************************
CREATE TRIGGER HostCheck
ON ALL SERVER 
FOR LOGON
AS
BEGIN
  DECLARE @ClientHost Varchar(1000)
  SET @ClientHost = EVENTDATA().value
  ('(/EVENT_INSTANCE/ClientHost)[1]', 'varchar(50)')

  IF @ClientHost Not IN ('<local machine>','192.168.0.101') 
     BEGIN
       Print 'Logon blocked for ' + @ClientHost
       ROLLBACK TRANSACTION
   END
END
GO

--Listing 9-46*********************************************************************
sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
sp_configure 'clr enabled', 1;
GO
RECONFIGURE;
GO

--Listing 9-47*********************************************************************
sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
sp_configure 'lightweight pooling', 0;
GO
RECONFIGURE;
GO

--Listing 9-48*********************************************************************
CREATE ASSEMBLY CLRProcDemo
FROM 'C:\ CLRProcDemo.dll'
WITH PERMISSION_SET = EXTERNAL_ACCESS

--Listing 9-49*********************************************************************
USE master 
GO 
CREATE ASYMMETRIC KEY CLRProcDemoKey FROM EXECUTABLE FILE = 'C:\ CLRProcDemo.dll'
CREATE LOGIN CLRDemoLogin FROM ASYMMETRIC KEY CLRProcDemoKey 
GRANT EXTERNAL ACCESS ASSEMBLY TO CLRDemoLogin 
GO

--Listing 9-50*********************************************************************
CREATE PROCEDURE TestCLRStoredProc
AS
EXTERNAL NAME AssemblyName.ClassName.MethodName
GO

--Listing 9-51*********************************************************************
DROP ASSEMBLY CLRProcDemo

