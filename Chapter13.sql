--Listing 13-1*********************************************************************
--MAKE SURE TO STOP SQL SERVER AGENT BEFORE RUNNING THIS SCRIPT!
USE msdb
GO

--Enable Database Mail
sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
sp_configure 'Database Mail XPs', 1;
GO
RECONFIGURE
GO

--Enable Service Broker
ALTER DATABASE msdb SET ENABLE_BROKER

--Add the profile
EXECUTE msdb.dbo.sysmail_add_profile_sp
@profile_name = 'DBA Mail Profile',
@description = 'Profile used by the database administrator to send email.'

--Add the account
EXECUTE msdb.dbo.sysmail_add_account_sp
@account_name = 'DBA Mail Account',
@description = 'Profile used by the database administrator to send email.',
@email_address = 'DBA@somecompany.com',
@display_name =  (Select @@ServerName),
@mailserver_name =  'KEN-PC'

--Associate the account with the profile
EXECUTE msdb.dbo.sysmail_add_profileaccount_sp
@profile_name = 'DBA Mail Profile',
@account_name = 'DBA Mail Account',
@sequence_number = 1 

Print 'Don’t Forget To Restart SQL Server Agent!'

--Listing 13-2*********************************************************************
USE msdb
GO
EXEC msdb.dbo.sp_add_alert 
    @name=N'Fatal Error in Resource', 
    @message_id=0, 
    @severity=19, 
    @enabled=1, 
    @delay_between_responses=0, 
    @include_event_description_in=1, 
    @notification_message=N'This is a Fatal Alert.  Please review immediately.'
GO

EXEC msdb.dbo.sp_add_notification 
    @alert_name=N'Fatal Error in Resource', 
    @operator_name=N'DBA Support', 
    @notification_method = 1
GO
