--Listing 8-1*********************************************************************

--Syntax for Create Login
--CREATE LOGIN loginName {WITH PASSWORD OPTIONS, Additional Options 
	--| FROM SOURCE}

--Listing 8-2*********************************************************************
USE AdventureWorks2008
GO
CREATE ROLE JR_DBA
GO
GRANT VIEW DATABASE STATE,SELECT to JR_DBA
GO

--Listing 8-3*********************************************************************
USE master
GO
CREATE LOGIN apressWriter WITH PASSWORD = 'P@ssw0rd!' ,
CHECK_POLICY = ON, CHECK_EXPIRATION = ON,
DEFAULT_DATABASE = Adventureworks2008
GO

USE AdventureWorks2008
GO
CREATE USER apressWriter
FOR LOGIN apressWriter
WITH DEFAULT_SCHEMA = SALES
GO
EXEC sp_addrolemember db_datareader, apressWriter
GO

--Listing 8-4*********************************************************************
USE AdventureWorks2008
GO
CREATE SCHEMA APWriter AUTHORIZATION apressWriter
CREATE TABLE APWriter.books
(bookId int,
Title varchar(100)
)
GO
EXEC sp_droprolemember db_datareader, apressWriter
GO

--Listing 8-5*********************************************************************
USE [master]
GO
CREATE LOGIN [apressGUIDemo] WITH PASSWORD=N'ABC123#@'
MUST_CHANGE, DEFAULT_DATABASE=[AdventureWorksDW2008], 
CHECK_EXPIRATION=ON, CHECK_POLICY=ON
GO
ALTER LOGIN [apressGUIDemo] ADD CREDENTIAL [apressCred]
GO
EXEC master..sp_addsrvrolemember @loginame = N'apressGUIDemo',@rolename = N'dbcreator'
GO
EXEC master..sp_addsrvrolemember @loginame = N'apressGUIDemo',@rolename = N'securityadmin'
GO
USE [AdventureWorks2008]
GO
CREATE USER [apressGUIDemo] FOR LOGIN [apressGUIDemo]
GO
USE [AdventureWorks2008]
GO
EXEC sp_addrolemember N'db_datareader', N'apressGUIDemo'
GO
USE [AdventureWorks2008]
GO
EXEC sp_addrolemember N'db_datawriter', N'apressGUIDemo'
GO
use [master]
GO
DENY VIEW ANY DEFINITION TO [apressGUIDemo]
GO

--Listing 8-6*********************************************************************
USE AdventureWorks2008
GO
declare @encryptedAuthor varchar(1000),
@author varchar(50) = 'Sylvester Carstarphen',
@decryptedAuthor varchar(1000),
@certificatePassword nvarchar(64) = '53cur3Dem0!'
set @encryptedAuthor = ENCRYPTBYCERT(cert_id('secureDemo1'),@author)
print @encryptedAuthor
set @decryptedAuthor = DECRYPTBYCERT(cert_id('secureDemo1'),@encryptedAuthor,@certificatePassword)
print @decryptedAuthor


--Listing 8-7*********************************************************************
declare @encryptedAuthor varchar(1000),
@author varchar(50) = 'Sylvester Carstarphen',
@decryptedAuthor varchar(1000),
@certificatePassword nvarchar(64) = '@5ymm3tr1c'
set @encryptedAuthor = ENCRYPTBYASYMKEY(ASYMKEY_ID('secureDemo3'),@author)
print @encryptedAuthor
set @decryptedAuthor = DECRYPTBYASYMKEY(ASYMKEY_ID('secureDemo3'),@encryptedAuthor ,@certificatePassword)
print @decryptedAuthor

--Listing 8-8*********************************************************************
USE AdventureWorks2008
GO
declare @encryptedAuthor varchar(1000),
@author varchar(50) = 'Sylvester Carstarphen',
@decryptedAuthor varchar(1000),
@certificatePassword nvarchar(64) = '@5ymm3tr1c'
OPEN SYMMETRIC KEY secureDemo5
DECRYPTION BY ASYMMETRIC KEY secureDemo3 WITH PASSWORD = '@5ymm3tr1c'
set @encryptedAuthor = ENCRYPTBYKEY(KEY_GUID('secureDemo5'),@author)
print @encryptedAuthor
set @decryptedAuthor = DECRYPTBYASYMKEY(ASYMKEY_ID('secureDemo3'),@encryptedAuthor,@certificatePassword)
set @decryptedAuthor = DECRYPTBYKEY(@encryptedAuthor)
print @decryptedAuthor

