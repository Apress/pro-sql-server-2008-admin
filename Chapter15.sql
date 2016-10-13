--Listing 15-1*********************************************************************
-- This is the syntax for creating an audit

--CREATE SERVER AUDIT audit_name
--TO { [ FILE (<file_options> [, ...n]) ] | APPLICATION_LOG | SECURITY_LOG }
--[ WITH ( <audit_options> [, ...n] ) ]

--Listing 15-2*********************************************************************
USE master;
GO
CREATE SERVER AUDIT exampleAudit
TO FILE
( FILEPATH = 'C:\', MAXSIZE = 1 GB
)
WITH( ON_FAILURE = CONTINUE)
GO

--Listing 15-3*********************************************************************
-- Syntax for creating a server audit specification

--CREATE SERVER AUDIT SPECIFICATION audit_specification_name
--FOR SERVER AUDIT audit_name
--ADD (audit_action_group_name ), ...n,
--WITH ( STATE= ON|OFF)

--Listing 15-4*********************************************************************
CREATE SERVER AUDIT SPECIFICATION serverSpec
FOR SERVER AUDIT exampleAudit
ADD (SERVER_ROLE_MEMBER_CHANGE_GROUP)
GO

--Listing 15-5*********************************************************************
USE master;
GO
-- Create the server audit
CREATE SERVER AUDIT permissionChanges
TO FILE ( FILEPATH = 'C:\',MAXSIZE = 1 GB)
WITH( ON_FAILURE = CONTINUE)
GO
-- Create the server audit specification
CREATE SERVER AUDIT SPECIFICATION serverPermissionChanges
FOR SERVER AUDIT permissionChanges
ADD (SERVER_ROLE_MEMBER_CHANGE_GROUP),
ADD (DATABASE_ROLE_MEMBER_CHANGE_GROUP),
ADD (SERVER_PERMISSION_CHANGE_GROUP),
ADD (SERVER_OBJECT_PERMISSION_CHANGE_GROUP),
ADD (DATABASE_PERMISSION_CHANGE_GROUP),
ADD (DATABASE_OBJECT_PERMISSION_CHANGE_GROUP)
GO
-- Turn the audit and server audit specification ON
ALTER SERVER AUDIT permissionChanges
WITH (STATE = ON)
GO

ALTER SERVER AUDIT SPECIFICATION serverPermissionChanges
WITH (STATE = ON)
GO

-- Creates actions that the audit will pick up
CREATE LOGIN auditTest
WITH PASSWORD = 'Test123!'
GO

EXEC sp_addsrvrolemember auditTest, sysadmin
GO
EXEC sp_dropsrvrolemember auditTest,sysadmin
GO
EXEC sp_addsrvrolemember auditTest, serveradmin
GO

EXEC sp_addsrvrolemember auditTest, processAdmin

--Listing 15-6*********************************************************************
--Syntax for creating a Database Audit Specification

--CREATE DATABASE AUDIT SPECIFICATION audit_specification_name
--FOR SERVER AUDIT audit_name
--ADD ( <audit_action_specification> | audit_action_group_name ) , ...n
--WITH ( STATE= ON|OFF)
--audit_action_specification = action [ ,...n ]ON [class ::]securable BY principal [ ,...n ]

--Listing 15-7*********************************************************************
USE master;
GO
-- Create the server audit
CREATE SERVER AUDIT salaryViewing
TO FILE ( FILEPATH = 'C:\'’,MAXSIZE = 1 GB)
GO
-- Create the database audit specification in the database you want audited
USE AdventureWorks2008
GO
CREATE DATABASE AUDIT SPECIFICATION salaryQueries
FOR SERVER AUDIT salaryViewing
ADD (SELECT,UPDATE ON humanresources.EmployeePayHistory by dbo),
ADD (DATABASE_PRINCIPAL_CHANGE_GROUP)
GO
USE master;
GO

ALTER SERVER AUDIT salaryViewing
WITH (STATE = ON)
GO

USE AdventureWorks2008
GO
ALTER DATABASE AUDIT SPECIFICATION salaryQueries
WITH (STATE = ON)
GO

SELECT TOP 10 *
FROM AdventureWorks2008.HumanResources.EmployeePayHistory

SELECT JobTitle, Rate,RateChangeDate
FROM AdventureWorks2008.HumanResources.Employee e
JOIN AdventureWorks2008.HumanResources.EmployeePayHistory eh
ON e.BusinessEntityID = eh.BusinessEntityId
ORDER BY jobTitle, RateChangeDate DESC

SELECT JobTitle, Rate,RateChangeDate
FROM AdventureWorks2008.HumanResources.Employee e
JOIN AdventureWorks2008.HumanResources.EmployeePayHistory eh
ON e.BusinessEntityID = eh.BusinessEntityId
WHERE rate > 50.
ORDER BY jobTitle, RateChangeDate DESC

USE Adventureworks2008
GO
CREATE USER sneakyUser FOR LOGIN auditTest
GO

