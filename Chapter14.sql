--Listing 14-1*********************************************************************
SELECT t1.session_id,t1.status,t1.command AS command,t2.state AS worker_state,
w_suspended = CASE t2.wait_started_ms_ticks
WHEN 0 THEN 0 ELSE t3.ms_ticks - t2.wait_started_ms_ticks
END,
w_runnable = CASE t2.wait_resumed_ms_ticks
WHEN 0 THEN 0 ELSE t3.ms_ticks - t2.wait_resumed_ms_ticks
END
FROM sys.dm_exec_requests AS t1 INNER JOIN sys.dm_os_workers AS t2
ON t2.task_address = t1.task_address
CROSS JOIN sys.dm_os_sys_info AS t3
WHERE t1.scheduler_id IS NOT NULL and session_id> 50

--Listing 14-2*********************************************************************
SELECT scheduler_id,parent_node_id,current_tasks_count,
runnable_tasks_count, current_workers_count, active_workers_count,
work_queue_count, load_factor
FROM sys.dm_os_schedulers
WHERE scheduler_id < 255

--Listing 14-3*********************************************************************
SELECT r.session_id,task_state,pending_io_count,
r.scheduler_id,command,cpu_time,
total_elapsed_time,sql_handle
FROM sys.dm_os_tasks t
join sys.dm_exec_requests r on t.request_id =
r.request_id and t.session_id = r.session_id
WHERE r.session_id > 50

--Listing 14-4*********************************************************************
/****************************************************/
/* Created by: SQL Server 2008 Profiler */
/* Date: 03/25/2009 11:43:51 PM */
/****************************************************/
-- Create a queue
DECLARE @rc int
DECLARE @TraceID int
DECLARE @maxfilesize bigint
SET @maxfilesize = 5
-- Please replace the text InsertFileNameHere, with an appropriate
-- file name prefixed by a path, e.g., c:\MyFolder\MyTrace. The .trc extension
-- will be appended to the file name automatically. If you are writing from
-- remote server to local drive, please use UNC path and make sure server has
-- write access to your network share.
EXEC @rc = sp_trace_create @TraceID output, 0,
N'InsertFileNameHere', @maxfilesize, NULL
if (@rc != 0) goto error
-- Client-side file and table cannot be scripted
-- Set the events
DECLARE @on bit
SET @on = 1
EXEC sp_trace_setevent @TraceID, 10, 15, @on
exec sp_trace_setevent @TraceID, 10, 16, @on
EXEC sp_trace_setevent @TraceID, 10, 9, @on
EXEC sp_trace_setevent @TraceID, 10, 17, @on
EXEC sp_trace_setevent @TraceID, 10, 2, @on
EXEC sp_trace_setevent @TraceID, 10, 10, @on
EXEC sp_trace_setevent @TraceID, 10, 18, @on
EXEC sp_trace_setevent @TraceID, 10, 11, @on
EXEC sp_trace_setevent @TraceID, 10, 12, @on
EXEC sp_trace_setevent @TraceID, 10, 13, @on
EXEC sp_trace_setevent @TraceID, 10, 6, @on
EXEC sp_trace_setevent @TraceID, 10, 14, @on
EXEC sp_trace_setevent @TraceID, 12, 15, @on

EXEC sp_trace_setevent @TraceID, 12, 16, @on
EXEC sp_trace_setevent @TraceID, 12, 1, @on
EXEC sp_trace_setevent @TraceID, 12, 9, @on
EXEC sp_trace_setevent @TraceID, 12, 17, @on
EXEC sp_trace_setevent @TraceID, 12, 6, @on
EXEC sp_trace_setevent @TraceID, 12, 10, @on
EXEC sp_trace_setevent @TraceID, 12, 14, @on
EXEC sp_trace_setevent @TraceID, 12, 18, @on
EXEC sp_trace_setevent @TraceID, 12, 11, @on
EXEC sp_trace_setevent @TraceID, 12, 12, @on
EXEC sp_trace_setevent @TraceID, 12, 13, @on
-- Set the filters
DECLARE @intfilter int
DECLARE @bigintfilter bigint
EXEC sp_trace_setfilter @TraceID, 10, 0, 7,
N'SQL Server Profiler - c97955a1-dbf3-4cc8-acc0-4606f7800ab7'
-- Set the trace status to start
EXEC sp_trace_setstatus @TraceID, 1
-- display trace ID for future references
SELECT TraceID=@TraceID
GOTO finish
error:
SELECT ErrorCode=@rc
finish:
GO

