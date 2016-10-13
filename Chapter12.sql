--Listing 12-1*********************************************************************
USE master
GO
RESTORE LOG AdventureWorks2008
FROM DISK = 'c:\backups\AdventureWorks_log.bak'
WITH FILE =1,
STANDBY = 'C:\backups\UNDO.BAK',
STATS

RESTORE LOG AdventureWorks2008
FROM DISK = 'c:\backups\AdventureWorks_log.bak'
WITH FILE =2,
RECOVERY,
STATS

--Listing 12-2*********************************************************************
RESTORE DATABASE AdventureWorks2008
FILE = 'AdventureWorksIndex.ndf',
FILEGROUP = 'Indexes'
FROM DISK = 'c:\backups\AdventureWorksFileGroup.bak'
WITH RECOVERY,
STATS

--Listing 12-3*********************************************************************
RESTORE DATABASE AdventureWorks2008
FILE = 'AdventureWorksIndex.ndf',
FILEGROUP = 'Indexes'
FROM DISK = 'c:\backups\AdventureWorksFileGroup.bak'
WITH NORECOVERY,
STATS

RESTORE LOG AdventureWorks2008
FROM DISK = 'c:\backups\AdventureWorks_log.bak'
WITH RECOVERY,
STATS

--Listing 12-4*********************************************************************
USE master
GO
RESTORE DATABASE AdventureWorks2008
PAGE = '4:300'
FROM DISK = 'c:\backups\AdventureWorksFileGroup3.bak'
WITH RECOVERY

--Listing 12-5*********************************************************************
USE master
GO
RESTORE DATABASE AdventureWorks2008
FILEGROUP = 'Primary'
FROM DISK = 'c:\backups\AdventureWorksFileGroup3.bak'
WITH PARTIAL,
RECOVERY,
STATS

--Listing 12-6*********************************************************************
USE master
GO
RESTORE DATABASE Adventureworks
FROM DATABASE_SNAPSHOT = 'AdventureWorks_ss'

--Listing 12-7*********************************************************************
USE master
GO
-- Create the PiecemealRestore database
CREATE DATABASE PiecemealRestore
ON PRIMARY
( NAME = CLUSTEREDINDEX, FILENAME = 'c:\PiecemealRestore_Clus_data.mdf'),
FILEGROUP NONCLUSTINDEXES
( NAME = NONCLUSTEREDINDEX, FILENAME = 'c:\PiecemealRestore_NonClus_data.ndf')
GO
-- Review the files and filegroups post-creation
USE PiecemealRestore
GO
EXEC sp_helpfile
GO
-- Back up the database so you can always get back to a clean database
BACKUP DATABASE PiecemealRestore
TO DISK = 'c:\PiecemealRestoreCLean.bak'
-- Add the three tables to the PiecemealRestore

SELECT *
INTO Product
FROM AdventureWorks2008.Production.Product
SELECT *
INTO SalesOrderDetail
FROM AdventureWorks2008.Sales.SalesOrderDetail
SELECT *
INTO SalesOrderHeader
FROM AdventureWorks2008.Sales.SalesOrderHeader

--Validate that the tables have data in them
SELECT TOP 10 *
FROM Product

SELECT TOP 10 *
FROM SalesOrderDetail

SELECT TOP 10 *
FROM SalesOrderHeader

-- Create clustered index
CREATE CLUSTERED INDEX ix_SalesOrderId ON SalesOrderHeader(SalesOrderId)ON [Primary]
CREATE CLUSTERED INDEX ix_ProductId ON Product(ProductId)ON [Primary]
CREATE CLUSTERED INDEX ix_SalesOrderIdDetailId ON SalesOrderDetail(SalesOrderId,SalesOrderDetailId)ON [Primary]

-- Create nonclustered indexes
CREATE NONCLUSTERED INDEX ix_OrderDatewInclude2 ON SalesOrderHeader(orderDate)INCLUDE(subTotal, TaxAmt, TotalDue)ON NONCLUSTINDEXES
CREATE NONCLUSTERED INDEX ix_ProductIdInclude ON SalesOrderDetail(ProductId) INCLUDE(OrderQty)ON NONCLUSTINDEXES
GO

BACKUP LOG PiecemealRestore
TO DISK = 'C:\PiecemealRestore_tlog.bak'

--Listing 12-8*********************************************************************
USE PiecemealRestore
GO
SELECT soh.SalesOrderID,soh.SubTotal, soh.TaxAmt, soh.TotalDue
FROM SalesOrderHeader soh
WHERE soh.OrderDate > '2003-12-31'

SELECT sod.SalesOrderID,sod.SalesOrderDetailID,p.Name,sod.OrderQty
FROM SalesOrderDetail sod join Product p on sod.ProductID = p.ProductID
WHERE p.ProductID = 843

--Listing 12-9*********************************************************************
USE master
GO

RESTORE DATABASE PiecemealRestore
FILEGROUP = 'PRIMARY'
FROM DISK = 'c:\PiecemealRestoreCLean.bak'
WITH PARTIAL,
STANDBY = 'undoRestore.bak',
STATS
GO

USE PiecemealRestore
GO

-- Failures will occur when querying the following three tables
SELECT TOP 10 *
FROM Product

SELECT TOP 10 *
FROM SalesOrderDetail

SELECT TOP 10 *
FROM SalesOrderHeader

SELECT name,state_desc,create_lsn,redo_start_lsn
FROM sys.master_files
WHERE database_id = DB_ID('PiecemealRestore')

--Listing 12-10*********************************************************************
USE master
GO
RESTORE LOG PiecemealRestore
FROM DISK = 'C:\PiecemealRestore_tlog.bak'
WITH FILE = 1,
STANDBY = 'c:\undoRestore.bak',
STATS
GO
-- Query the tables
USE PiecemealRestore
GO

-- Validate that you have data within the tables
SELECT TOP 10 *
FROM Product

SELECT TOP 10 *
FROM SalesOrderDetail

SELECT TOP 10 *
FROM SalesOrderHeader

-- Ensure that the database is still pending restore status

SELECT name,state_desc,create_lsn,redo_start_lsn
FROM sys.master_files
WHERE database_id = DB_ID('PiecemealRestore')

--Listing 12-11*********************************************************************
USE master
GO
-- Bring the primary filegroup back online
RESTORE DATABASE PiecemealRestore
WITH RECOVERY

-- Verify the status of the other filegroup
SELECT name,state_desc,create_lsn,redo_start_lsn
FROM sys.master_files
WHERE database_id = DB_ID('PiecemealRestore')

--Listing 12-12*********************************************************************
--Restore the other filegroup
USE master
GO
RESTORE DATABASE PiecemealRestore
FILEGROUP = 'NONCLUSTINDEXES'
FROM DISK = 'c:\PiecemealRestoreCLean.bak'
WITH NORECOVERY,
STATS
GO
-- Verify the status of the filegroup
SELECT name,state_desc,create_lsn,redo_start_lsn
FROM sys.master_files
WHERE database_id = DB_ID('PiecemealRestore')

--Listing 12-13*********************************************************************
-- Run query and review the current execution plan
USE PiecemealRestore
GO
SELECT soh.SalesOrderID,soh.SubTotal, soh.TaxAmt, soh.TotalDue
FROM SalesOrderHeader soh
WHERE soh.OrderDate > '2003-12-31'

SELECT sod.SalesOrderID,sod.SalesOrderDetailID,p.Name,sod.OrderQty
FROM SalesOrderDetail sod join Product p
on sod.ProductID = p.ProductID
WHERE p.ProductID = 843

INSERT INTO SalesOrderDetail
(SalesOrderID,ProductID,OrderQty,SpecialOfferID,UnitPrice,UnitPriceDiscount,LineTotal,rowguid,ModifiedDate)
VALUES( 46608,843, 10, 2,15.00, .00, 150.00, NEWID(), GETDATE())

--Listing 12-14*********************************************************************
USE master
GO
CREATE MASTER KEY ENCRYPTION BY PASSWORD = '3ncrypt1on!'
GO

BACKUP MASTER KEY TO FILE = 'c:\databaseKeyFile'
encryption by password = '3ncryption'
GO

CREATE CERTIFICATE DataEnc
WITH SUBJECT = 'Transparent Data Encryption'
GO

CREATE DATABASE apressReader
GO

BACKUP CERTIFICATE DataEnc
TO FILE = 'c:\certDataEncrypt'
WITH PRIVATE KEY (FILE = 'c:\certDataEncrypt_key',
encryption by password = '3ncryption')
GO

USE apressReader
GO

CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM = AES_256
ENCRYPTION BY SERVER CERTIFICATE DataEnc
GO

ALTER DATABASE apressReader
SET ENCRYPTION ON
GO
EXEC sp_configure 'backup compression default',1
GO
RECONFIGURE
GO
CREATE TABLE tblReader
(
ReaderId int identity(1,1),
fName varchar(25),
lName varchar(50),
jobTitle varchar(100),
companyName varchar(50)
)
GO

BACKUP DATABASE apressReader
TO DISK = 'c:\apressReader.bak'
GO

INSERT INTO tblReader
VALUES ('Kim', 'Sue' , 'DBA', 'Top IT Consult'),
('Monique', 'Cee','DBA Developer','MC Prof'),
('Ant', 'Sams', 'DBA', 'Refer Academy'),
('Kend','Squeak','DBA', 'ABCComp')
GO

BACKUP LOG apressReader
TO DISK = 'c:\apressReader_log.bak'
GO
INSERT INTO tblReader
VALUES ('Lil', 'Jay' , 'JR DBA', 'Junior Techs'),
('Kd', 'Fra','JR DBA' ,'Junior Techs'),
('Nose', 'Samps', 'Lead DBA', 'Junior Techs')
BEGIN TRANSACTION lastInsert
INSERT INTO tblReader
VALUES ('JW', 'Walk' , 'DBA Dev', 'Top Balla'),
('Sammy', 'Walk','DBA Dev' ,'Top Balla'),
('Rome', 'Southern', 'DBA Dev', 'Top Balla')
COMMIT TRANSACTION lastInsert

SELECT * FROM apressReader.dbo.tblReader

BEGIN TRANSACTION DeleteRows WITH mark 'Delete Last Rows'
DELETE FROM tblReader
COMMIT

BACKUP LOG apressReader
TO DISK = 'c:\apressreader_log.bak'

-- Backing up tail end of the log. Always a good practice.
BACKUP LOG apressReader
TO DISK = 'c:\apressreader_log.bak'

--Listing 12-15*********************************************************************
RESTORE LOG apressReaderTmp
FROM DISK = 'c:\apressReader_log.bak'
WITH FILE = 1,
STANDBY = 'c:\apressReader_undo.bak'

SELECT * FROM apressReaderTmp.dbo.tblReader

RESTORE LOG apressReaderTmp
FROM DISK = 'c:\apressReader_log.bak'
WITH FILE = 2,
STOPBEFOREMARK = 'DeleteRows',
STANDBY = 'c:\apressReader_undo.bak'

SELECT * FROM apressReaderTmp.dbo.tblReader

--Listing 12-16*********************************************************************
RESTORE LOG apressReaderTmp
FROM DISK = 'c:\apressReader_log.bak'
WITH FILE = 1,
STANDBY = 'c:\apressReader_undo.bak'

SELECT * FROM apressReaderTmp.dbo.tblReader

RESTORE LOG apressReaderTmp
FROM DISK = 'c:\apressReader_log.bak'
WITH FILE = 2,
STOPBEFOREMARK = 'DeleteRows',
STANDBY = 'c:\apressReader_undo.bak'

SELECT * FROM apressReaderTmp.dbo.tblReader
