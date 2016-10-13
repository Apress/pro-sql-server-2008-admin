--Listing 7-1*********************************************************************
Create Procedure CrossServerSelect
AS

Select Distinct City
FROM [SQLInstanceName].AdventureWorks.Person.Address
GO

--Listing 7-2*********************************************************************
SELECT @@SERVERNAME LocalServer,
               OBJECT_NAME (referencing_id) referencing_object_name, 
               referenced_server_name, 
               referenced_database_name, 
               referenced_schema_name, 
               referenced_entity_name
FROM sys.sql_expression_dependencies


--Listing 7-3*********************************************************************
SELECT @@SERVERNAME LocalServer,
               referenced_server_name, 
               referenced_database_name, 
               referenced_schema_name,
               referenced_entity_name
FROM sys.dm_sql_referenced_entities ('dbo.CrossServerSelect','OBJECT')

--Listing 7-4*********************************************************************
USE msdb
GO

SELECT OBJECT_NAME(referencing_id) AS referencing_entity_name,
                referenced_database_name AS database_name,
                referenced_schema_name,
                referenced_entity_name
FROM sys.sql_expression_dependencies 
WHERE referenced_entity_name = 'sysjobhistory'

--Listing 7-5*********************************************************************
USE msdb
GO

SELECT referencing_entity_name
FROM sys.dm_sql_referencing_entities ('dbo.sysjobhistory','OBJECT')

USE msdb
GO

--Listing 7-6*********************************************************************
SELECT referenced_schema_name, 
               referenced_entity_name, 
               referenced_minor_name
FROM sys.dm_sql_referenced_entities ('dbo.sp_help_job','OBJECT')



