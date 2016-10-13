--Listing 16-1*********************************************************************
SELECT * FROM sys.messages
CROSS JOIN sys.messages B
WHERE B.language_id = 1033 AND 
 B.text like '%Warning%' AND
 B.text like '%instance%'
 
 --Listing 16-2*********************************************************************
 DBCC FREEPROCCACHE 
GO
SELECT * FROM sys.messages WHERE severity = 23
GO
SELECT * FROM sys.messages WHERE severity = 23
GO
SELECT * FROM sys.messages WHERE severity = 23;
GO
SELECT * FROM sys.messages WHERE severity=23
GO
SELECT * FROM sys.messages WHERE severity = 24
GO 
SELECT * FROM sys.messages WHERE severity IN (24)
GO 
SELECT * FROM sys.messages WHERE severity in (23,24)
GO

--Listing 16-3*********************************************************************
SELECT qs.query_hash,
       qs.query_plan_hash,
       st.text ,
       qs.execution_count,
       qs.total_worker_time
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text (plan_handle) st
WHERE st.text like 'Select * From sys.messages%'
ORDER BY qs.total_worker_time DESC 

--Listing 16-4*********************************************************************
SELECT qs.query_hash,
       qs.query_plan_hash,
       MIN(st.text) QueryTextLike,
       SUM(qs.execution_count) ExecutionCount,
       SUM(qs.total_worker_time)TotalWorkerTime
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text (plan_handle) st
WHERE st.text LIKE 'SELECT * FROM sys.messages%'
GROUP BY qs.query_hash, qs.query_plan_hash
ORDER BY TotalWorkerTime DESC

--Listing 16-5*********************************************************************
SELECT TOP 10 
    creation_time,
    last_execution_time, 
    (total_worker_time+0.0)/1000 as total_worker_time,
    (total_worker_time+0.0)/(execution_count*1000) as [AvgCPUTime],
    total_logical_reads as [LogicalReads],
    total_logical_writes as [LogicalWrites],
    execution_count,
    total_logical_reads+total_logical_writes as [AggIO],
    (total_logical_reads+total_logical_writes)/(execution_count+0.0) as [AvgIO],
    case when sql_handle IS NULL
         then ' '
         else ( substring(st.text,(qs.statement_start_offset+2)/2,
              (case when qs.statement_end_offset = -1
                then len(convert(nvarchar(MAX),st.text))*2
                else qs.statement_end_offset
                end - qs.statement_start_offset) /2  ) )
    end as query_text,
       db_name(st.dbid) as db_name,
       st.objectid as object_id
FROM sys.dm_exec_query_stats  qs
CROSS apply sys.dm_exec_sql_text(sql_handle) st
WHERE total_worker_time  > 0 
ORDER BY [AvgCPUTime] desc

--Listing 16-6*********************************************************************
USE AdventureWorks2008
GO

SELECT B.CustomerID
FROM Sales.SalesOrderDetail A
     JOIN Sales.SalesOrderHeader B
     ON A.SalesOrderID = B.SalesOrderID
WHERE A.OrderQty = 1

--Listing 16-7*********************************************************************
USE AdventureWorks2008
GO

SELECT B.CustomerID
FROM Sales.SalesOrderDetail A
     JOIN Sales.SalesOrderHeader B
     ON A.SalesOrderID = B.SalesOrderID
WHERE A.OrderQty = 10

--Listing 16-8*********************************************************************
USE AdventureWorks2008
GO

DECLARE @ID int =10 

SELECT B.CustomerID
FROM Sales.SalesOrderDetail A
      JOIN Sales.SalesOrderHeader B
      ON A.SalesOrderID = B.SalesOrderID
WHERE A.OrderQty = @ID
OPTION (OPTIMIZE FOR (@ID = 1))

--Listing 16-9*********************************************************************
USE AdventureWorks2008
GO

DECLARE @ID2 int =1 

SELECT B.CustomerID
FROM Sales.SalesOrderDetail A
      JOIN Sales.SalesOrderHeader B
      ON A.SalesOrderID = B.SalesOrderID
WHERE A.OrderQty = @ID2
OPTION (OPTIMIZE FOR (@ID2 UNKNOWN))

--Listing 16-10*********************************************************************
USE AdventureWorks2008
GO

SELECT * 
FROM HumanResources.Employee A  
      JOIN HumanResources.EmployeeDepartmentHistory B 
       ON A.BusinessEntityID = B.BusinessEntityID
WHERE A.BusinessEntityID > 270 OR
          (A.BusinessEntityID < 10 and B.DepartmentID =1)

--Listing 16-11*********************************************************************
USE AdventureWorks2008
GO

SELECT * 
FROM HumanResources.Employee A  
      JOIN HumanResources.EmployeeDepartmentHistory B WITH (FORCESEEK) 
       ON A.BusinessEntityID = B.BusinessEntityID
WHERE A.BusinessEntityID > 270 OR
          (A.BusinessEntityID < 10 and B.DepartmentID =1)

--Listing 16-13*********************************************************************
USE AdventureWorks2008
GO

EXEC sp_create_plan_guide 
     @name = N'[PlanGuide-Ch15Test]', 
     @stmt = N'Select * 
FROM HumanResources.Employee A
      JOIN HumanResources.EmployeeDepartmentHistory B
       ON A.BusinessEntityID = B.BusinessEntityID
WHERE A.BusinessEntityID > 270 OR
          (A.BusinessEntityID < 10 and B.DepartmentID =1)', 
    @type = N'SQL',
    @hints = N'OPTION (TABLE HINT(B, FORCESEEK))'
GO

--Listing 16-14*********************************************************************
--Create the Backup pool
CREATE RESOURCE POOL BackupPool
 WITH
( MIN_CPU_PERCENT = 0, 
 MAX_CPU_PERCENT = 20, 
 MIN_MEMORY_PERCENT = 0, 
 MAX_MEMORY_PERCENT = 20)
GO

--Create the Reporting pool
CREATE RESOURCE POOL ReportingPool
 WITH
( MIN_CPU_PERCENT = 0, 
 MAX_CPU_PERCENT = 25, 
 MIN_MEMORY_PERCENT = 0, 
 MAX_MEMORY_PERCENT = 25)
GO

--Enable Resource Governor
ALTER RESOURCE GOVERNOR RECONFIGURE
GO

--Listing 16-15*********************************************************************
CREATE WORKLOAD GROUP BackupGroup
USING BackupPool
GO

CREATE WORKLOAD GROUP ReportingGroup
WITH 
 (IMPORTANCE = MEDIUM,
 REQUEST_MAX_MEMORY_GRANT_PERCENT = 30,
 REQUEST_MAX_CPU_TIME_SEC = 0,
 REQUEST_MEMORY_GRANT_TIMEOUT_SEC = 0,
 MAX_DOP = 0,
 GROUP_MAX_REQUESTS = 0)
USING ReportingPool
GO

CREATE WORKLOAD GROUP TestingGroup
WITH 
 (IMPORTANCE = LOW,
 REQUEST_MAX_MEMORY_GRANT_PERCENT = 20,
 REQUEST_MAX_CPU_TIME_SEC = 180,
 REQUEST_MEMORY_GRANT_TIMEOUT_SEC = 0,
 MAX_DOP = 1,
 GROUP_MAX_REQUESTS = 20)
GO

ALTER RESOURCE GOVERNOR RECONFIGURE
GO

--Listing 16-16*********************************************************************
USE master
GO

CREATE FUNCTION RG_Classifier_V1 ()
RETURNS sysname
WITH SCHEMABINDING
AS
BEGIN

    DECLARE @GroupName sysname

    IF (IS_MEMBER('KEN-PC\TestingGroup') = 1)
       SET @GroupName = 'TestingGroup' 
 
     ELSE IF (APP_NAME() LIKE '%REPORT SERVER%') 
       SET @GroupName = 'ReportingGroup' 
 
     ELSE IF (SUSER_NAME() = 'BackupUser')
       SET @GroupName = 'BackupGroup' 
 
     ELSE
       SET @GroupName = 'default'
 
   RETURN @GroupName
 
END
GO

--Assign the function to the Resource Governor and reconfigure
ALTER RESOURCE GOVERNOR WITH (CLASSIFIER_FUNCTION = dbo.RG_Classifier_V1)
GO
ALTER RESOURCE GOVERNOR RECONFIGURE
GO

--Listing 16-17*********************************************************************
ALTER RESOURCE GOVERNOR WITH (CLASSIFIER_FUNCTION = NULL);
GO
ALTER RESOURCE GOVERNOR RECONFIGURE;

--Listing 16-18*********************************************************************
SELECT * 
FROM sys.dm_os_performance_counters 
WHERE object_name IN 
  ('MSSQL$SQL2K8:Workload Group Stats','MSSQL$SQL2K8:Resource Pool Stats') 
   AND instance_name = 'default'

--Listing 16-19*********************************************************************
SELECT * FROM sys.dm_resource_governor_workload_groups
SELECT * FROM sys.dm_resource_governor_resource_pools
SELECT * FROM sys.dm_resource_governor_configuration

--Listing 16-20*********************************************************************
SELECT * FROM sys.resource_governor_workload_groups
SELECT * FROM sys.resource_governor_resource_pools
SELECT * FROM sys.resource_governor_configuration
