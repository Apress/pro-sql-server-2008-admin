--Listing 11-1*********************************************************************
USE master
GO

--Select the database recovery model
Select DATABASEPROPERTYEX('AdventureWorks2008','RECOVERY');

--Change the database recovery model
ALTER DATABASE AdventureWorks2008 SET RECOVERY FULL;

--Listing 11-2*********************************************************************
USE master
GO
BACKUP DATABASE [AdventureWorks2008] TO 
DISK = 'C:\Backup\AdventureWorks2008_1.bak', 
DISK = 'D:\Backup\AdventureWorks2008_2.bak'
WITH MEDIANAME = 'AdventureWorks2008_MediaSet'
GO

--Listing 11-3*********************************************************************
BACKUP DATABASE AdventureWorks2008 
TO  DISK = 'C:\Backups\AdventureWorks2008.bak' 

--Listing 11-4*********************************************************************
BACKUP DATABASE AdventureWorks2008
TO  DISK = 'C:\Backups\AdventureWorks2008_diff.bak' 
WITH  DIFFERENTIAL 
GO

--Listing 11-5*********************************************************************
BACKUP LOG AdventrueWorks2008
TO DISK = 'C:\Backups\AdventureWorks2008.trn'

--Listing 11-6*********************************************************************
--Partial backup
BACKUP DATABASE AdventureWorks2008 
READ_WRITE_FILEGROUPS -- [ , <optional_filegroups> ] 
TO Disk = 'C:\Backups\AdventureWorks2008_part.bak'

--Differential partial backup
BACKUP DATABASE AdventureWorks2008
READ_WRITE_FILEGROUPS -- [ , < optional_filegroups> ] 
TO Disk = 'C:\Backups\AdventureWorks2008_part_diff.bak'
WITH DIFFERENTIAL

--Listing 11-7*********************************************************************
--Backup the AdventureWorks2008_data file in the PRIMARY filegroup
BACKUP DATABASE AdventureWorks2008
 FILE = 'AdventureWorks2008_Data'
 TO DISK = 'C:\Backups\AdventureWorks2008_Data.bak'
GO

--Backup the PRIMARY filegroup
BACKUP DATABASE AdventureWorks2008
FILEGROUP = 'PRIMARY'
TO DISK = 'C:\Backups\AW2008_PRIMARY.bak'
GO

--Create a differential backup of the PRIMARY filegroup
BACKUP DATABASE AdventureWorks2008
 FILEGROUP = 'PRIMARY'
 TO DISK = 'C:\Backups\AW2008_PRIMARY_diff.bak'
WITH DIFFERENTIAL

--Listing 11-8*********************************************************************
USE master
GO

--Create a copy-only full backup
BACKUP DATABASE AdventureWorks2008 
TO  DISK = 'C:\AdventureWorks2008.bak' 
WITH  COPY_ONLY
GO

--Create a copy-only log backup
BACKUP LOG AdventureWorks2008 
TO  DISK = 'C:\AdventureWorks2008.trn' 
WITH  COPY_ONLY
GO

--Listing 11-9*********************************************************************
USE master
GO

EXEC sp_configure 'backup compression default', '1';
RECONFIGURE WITH OVERRIDE;

--Listing 11-10*********************************************************************
USE master
GO

PRINT '----------AdventureWorks2008 With Compression----------' 

--Create a full backup with compression
BACKUP DATABASE AdventureWorks2008 
TO  DISK = 'C:\Backups\AdventureWorks2008_C.bak' 
WITH  COMPRESSION

GO

PRINT Char(13) + '----------AdventureWorks2008 No Compression----------'

--Create a full backup with no compression
BACKUP DATABASE AdventureWorks2008 
TO  DISK = 'C:\Backups\AdventureWorks2008_NC.bak' 
WITH  NO_COMPRESSION

GO

--Listing 11-11*********************************************************************
SELECT database_name,
       backup_finish_date,
       1 - (compressed_backup_size/backup_size) PercentCompressed
FROM msdb.dbo.backupset
WHERE backup_size > compressed_backup_size

--Listing 11-12*********************************************************************
USE master
GO
--Add logical backup device
EXEC sp_addumpdevice 
        @devtype ='disk',
        @logicalname ='AdventureWorksBackupDevice' ,
        @physicalname ='C:\Backup\AdventureWorks2008.bak'
GO

--Remove logical backup device
EXEC sp_dropdevice 'AdventureWorksBackupDevice'
GO

--Listing 11-13*********************************************************************
--BACKUP STATEMENTS

--Backup database 
BACKUP DATABASE { database_name | @database_name_var } 
 TO <backup_device> [ ,...n ] 
 [ <MIRROR TO clause> ] [ next-mirror-to ]
 [ WITH { DIFFERENTIAL | <general_WITH_options> [ ,...n ] } ]
[;]

--Backup files or filegroups
BACKUP DATABASE { database_name | @database_name_var } 
 <file_or_filegroup> [ ,...n ] 
 TO <backup_device> [ ,...n ] 
 [ <MIRROR TO clause> ] [ next-mirror-to ]
 [ WITH { DIFFERENTIAL | <general_WITH_options> [ ,...n ] } ]
[;]

--Partial backup
BACKUP DATABASE { database_name | @database_name_var } 
 READ_WRITE_FILEGROUPS [ , <read_only_filegroup> [ ,...n ] ]
 TO <backup_device> [ ,...n ] 
 [ <MIRROR TO clause> ] [ next-mirror-to ]
 [ WITH { DIFFERENTIAL | <general_WITH_options> [ ,...n ] } ]
[;]

--Transaction log backup
BACKUP LOG { database_name | @database_name_var } 
 TO <backup_device> [ ,...n ] 
 [ <MIRROR TO clause> ] [ next-mirror-to ]
 [ WITH { <general_WITH_options> | <log-specific_optionspec> } [ ,...n ] ]
[;]
 
--BACKUP DESTINATION OPTIONS

<backup_device>::= 
 {
 { logical_device_name | @logical_device_name_var } 
 | { DISK | TAPE } = 
 { 'physical_device_name' | @physical_device_name_var }
 }

<MIRROR TO clause>::=
 MIRROR TO <backup_device> [ ,...n ]
 
<file_or_filegroup>::=
 {
 FILE = { logical_file_name | @logical_file_name_var } 
 | FILEGROUP = { logical_filegroup_name | @logical_filegroup_name_var }
 }

<read_only_filegroup>::=
FILEGROUP = { logical_filegroup_name | @logical_filegroup_name_var }
 
--WITH OPTIONS

--Backup set options
 COPY_ONLY 
 | { COMPRESSION | NO_COMPRESSION } 
 | DESCRIPTION = { 'text' | @text_variable } 
 | NAME = { backup_set_name | @backup_set_name_var } 
 | PASSWORD = { password | @password_variable } 
 | { EXPIREDATE = { 'date' | @date_var } 
 | RETAINDAYS = { days | @days_var } }

--Media set options
 { NOINIT | INIT } 
 | { NOSKIP | SKIP } 
 | { NOFORMAT | FORMAT } 
 | MEDIADESCRIPTION = { 'text' | @text_variable } 
 | MEDIANAME = { media_name | @media_name_variable } 
 | MEDIAPASSWORD = { mediapassword | @mediapassword_variable } 
 | BLOCKSIZE = { blocksize | @blocksize_variable }

--Data transfer options
 BUFFERCOUNT = { buffercount | @buffercount_variable } 
 | MAXTRANSFERSIZE = { maxtransfersize | @maxtransfersize_variable }

--Error management options
 { NO_CHECKSUM | CHECKSUM }
 | { STOP_ON_ERROR | CONTINUE_AFTER_ERROR }

--Compatibility options
 RESTART

--Monitoring options
 STATS [ = percentage ]

--Tape options
 { REWIND | NOREWIND } 
 | { UNLOAD | NOUNLOAD }

--Log-specific options
 { NORECOVERY | STANDBY = undo_file_name }
 | NO_TRUNCATE

--Listing 11-14*********************************************************************
BACKUP SERVICE MASTER KEY 
TO FILE = 'c:\service_master_key'
ENCRYPTION BY PASSWORD = '3ncrypti0nP@$$w0rd'
GO

--Listing 11-15*********************************************************************
USE master
GO
--Open the master key (This is not required if the master key
-- is encrypted using the service master key.)
OPEN MASTER KEY DECRYPTION BY PASSWORD = 'M@$t3r_K3y_3ncrypti0nP@$$w0rd '

--Back up the database master key
BACKUP MASTER KEY 
TO FILE = 'c:\database_master_key'
ENCRYPTION BY PASSWORD = '3ncrypti0nP@$$w0rd'
GO

--Listing 11-16*********************************************************************
USE master
GO

BACKUP CERTIFICATE TestCert
TO FILE = 'C:\TestCert.cer'
WITH PRIVATE KEY 
         (FILE = 'C:\TestCertKey.pvk',
         ENCRYPTION BY PASSWORD = '3ncrypti0nP@$$w0rd');
GO

--Listing 11-17*********************************************************************
USE msdb
GO

--Keep 6 months of history, but never delete more than 3 months at a time.
Declare @dte Datetime
Set @dte = (select min(backup_start_date) from backupset with (nolock))
Set @dte = (Select dateadd(mm,3,@dte))

IF (dateadd(mm,-6,getdate()) < @dte )
 Set @dte = dateadd(mm,-6,getdate())
  
print @dte

EXEC sp_delete_backuphistory @dte
