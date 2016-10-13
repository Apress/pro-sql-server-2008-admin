--Listing 1-1*********************************************************************
DECLARE @DateRecords TABLE (RecordID int, StartDate Datetime)

--Multiple inserts using UNION ALL
INSERT INTO @DateRecords
SELECT 1,'1/1/2008'
UNION ALL
SELECT 2,'1/2/2008'
UNION ALL
SELECT 3,'1/3/2008'

--Multiple inserts using single statements
INSERT INTO @DateRecords VALUES(4,'1/4/2008')
INSERT INTO @DateRecords VALUES(5,'1/5/2008')
INSERT INTO @DateRecords VALUES(6,'1/6/2008')

--Multiple inserts using row constructors
INSERT INTO @DateRecords
VALUES(7,'1/7/2008'),
      (8,'1/8/2008'),
      (9,'1/9/2008')

--Display INSERT results
SELECT * FROM @DateRecords

--Listing 1-2*********************************************************************
USE tempdb
GO

--1. Prep work
--Drop objects
IF OBJECT_ID('CustomerPreferences') IS NOT NULL
  DROP TABLE CustomerPreferences;
GO

IF OBJECT_ID('CustomerPreferences_Insert') IS NOT NULL
  DROP PROCEDURE CustomerPreferences_Insert;
GO

IF  EXISTS (SELECT * FROM sys.types st 
                JOIN sys.schemas ss 
                ON st.schema_id = ss.schema_id 
            WHERE st.name = N'CustomerPreferenceTableType'
              AND ss.name = N'dbo')
  DROP TYPE [dbo].[CustomerPreferenceTableType]
GO
  
--Create table to hold results from procedure
CREATE TABLE CustomerPreferences
(CustomerID INT, PreferenceID INT)

GO

--2. Create table type
CREATE TYPE CustomerPreferenceTableType AS TABLE 
( CustomerID INT, 
  PreferenceID INT );
GO

--3. Create procedure
CREATE PROCEDURE CustomerPreferences_Insert 
 @CustomerPrefs CustomerPreferenceTableType READONLY
AS 
SET NOCOUNT ON

INSERT INTO CustomerPreferences  
SELECT *
FROM  @CustomerPrefs;

 GO

--4. Execute procedure

--Table variable
DECLARE @CustomerPreference
AS CustomerPreferenceTableType;

--Insert data into the table variable
INSERT INTO @CustomerPreference 
    Values (1,1),(1,2),(1,3);

--Pass the table variable data to a stored procedure
EXEC CustomerPreferences_Insert  @CustomerPreference;

--View the results inserted using the table-valued function
SELECT * FROM CustomerPreferences


--Listing 1-3*********************************************************************
--Prep work
DECLARE @DateRecords TABLE (RecordID int, StartDate Datetime)

INSERT INTO @DateRecords VALUES(1,'1/1/2008'),
                               (2,'1/2/2008'),
                               (3,'1/4/2008'),
                               (5,'1/5/2008')

 --Display original dataset                              
SELECT * FROM @DateRecords ORDER BY RecordID

--Sample UPDATE WHEN MATCHED
MERGE @DateRecords AS Target
 USING (Select '1/4/2008') as Source (StartDate)
 ON (Target.StartDate = Source.StartDate)
 WHEN MATCHED THEN
   UPDATE SET StartDate = '1/3/2008'
 WHEN NOT MATCHED THEN
   INSERT (RecordID, StartDate)
     VALUES (4,'1/4/2008')
     OUTPUT deleted.*, $action, inserted.*;

--Display changed result set
SELECT * FROM @DateRecords ORDER BY RecordID

--Sample INSERT WHEN NOT MATCHED
MERGE @DateRecords AS target
 USING (Select '1/4/2008') as Source (StartDate)
 ON (target.StartDate = Source.StartDate)
 WHEN MATCHED THEN
   DELETE 
 WHEN NOT MATCHED THEN
   INSERT (RecordID, StartDate)
     VALUES (4,'1/4/2008')
     OUTPUT deleted.*, $action, inserted.*;

--Display changed result set
SELECT * FROM @DateRecords ORDER BY RecordID

--Running the same query again will result 
--in a Delete now that the record exists.
MERGE @DateRecords AS target
 USING (Select '1/4/2008') as Source (StartDate)
 ON (target.StartDate = Source.StartDate)
 WHEN MATCHED THEN
   DELETE 
 WHEN NOT MATCHED THEN
   INSERT (RecordID, StartDate)
     VALUES (4,'1/4/2008')
     OUTPUT deleted.*, $action, inserted.*;

--Display changed result set          
SELECT * FROM @DateRecords ORDER BY RecordID

--Listing 1-4*********************************************************************
DECLARE @DateRecords TABLE (RecordID int, StartDate Datetime)

INSERT INTO @DateRecords 
VALUES(1,'1/1/2008'),
      (2,'1/2/2008'),
      (3,'1/4/2008'),
      (4,'1/4/2008')


--GROUP BY using GROUPING SETS
SELECT RecordID, StartDate
FROM @DateRecords
GROUP BY GROUPING SETS (RecordID, StartDate)

--Equivalant to the previous query
SELECT NULL AS RecordID, StartDate
FROM @DateRecords
GROUP BY StartDate
UNION ALL
SELECT RecordID, NULL AS StartDate
FROM @DateRecords
GROUP BY  RecordID, StartDate

--Include all records by using MAX
SELECT MAX(RecordID) MaxRecordID, MAX(StartDate) MaxStartDate
FROM @DateRecords
GROUP BY  GROUPING SETS (RecordID,StartDate)

--Equivalant to the previous query
SELECT MAX(RecordID) MaxRecordID, StartDate
FROM @DateRecords
GROUP BY StartDate
UNION ALL
SELECT RecordID, MAX(StartDate)
FROM @DateRecords
GROUP BY  RecordID, StartDate

--Listing 1-5*********************************************************************
DECLARE @DateRecords TABLE (RecordID int, StartDate Datetime)

INSERT INTO @DateRecords 
VALUES(1,'1/1/2008'),
      (2,'1/2/2008'),
      (3,'1/4/2008'),
      (4,'1/4/2008')

--Old ROLLUP deprecated syntax 
SELECT MAX(RecordID) MaxRecordID, StartDate
FROM @DateRecords
GROUP BY  StartDate WITH ROLLUP

--New Syntax
SELECT MAX(RecordID) MaxRecordID, StartDate
FROM @DateRecords
GROUP BY ROLLUP(StartDate) 

--New GROUPING_ID function
SELECT RecordID, StartDate, GROUPING_ID(RecordID,StartDate) GroupingID 
FROM @DateRecords
GROUP BY CUBE(RecordID, StartDate) 
ORDER BY GROUPING_ID(RecordID,StartDate)
