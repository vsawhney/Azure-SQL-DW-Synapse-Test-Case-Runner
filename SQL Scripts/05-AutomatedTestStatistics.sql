/****** Object:  StoredProcedure [telemetry].[AutomatedTestStatistics]    Script Date: 4/23/2020 8:55:27 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [telemetry].[AutomatedTestStatistics] AS 
BEGIN

DECLARE @AutomatedTestId INT
SET @AutomatedTestId = (SELECT MAX(AutomatedTestId) FROM [telemetry].[AutomatedTest])

SELECT *, DATEDIFF(second,StartTime,EndTime) AS cSharpTimeInSeconds 
 FROM [telemetry].[AutomatedTest] 
WHERE AutomatedTestId = @AutomatedTestId

SELECT * 
  FROM [telemetry].AutomatedTestSession 
 WHERE AutomatedTestId = @AutomatedTestId

SELECT CONVERT(FLOAT,DATEDIFF(millisecond, MIN(submit_time),MAX(end_time))) / CONVERT(FLOAT,1000) AS Total_TimeInSeconds
  FROM [telemetry].[AutomatedTest_exec_requests]
 WHERE session_id IN (SELECT session_id FROM [telemetry].AutomatedTestSession WHERE AutomatedTestId = @AutomatedTestId)

SELECT [telemetry].[AutomatedTest].*,
       [Label] AS QueryName,
       [telemetry].[AutomatedTest_exec_requests].start_time AS QueryStartTime,
       [telemetry].[AutomatedTest_exec_requests].end_time AS QueryEndTime,
	    [telemetry].[AutomatedTest_exec_requests].[resource_class] AS ResourceClass,
	    [telemetry].[AutomatedTest_exec_requests].[result_cache_hit] AS ResultCacheHit,
       CONVERT(FLOAT,DATEDIFF(millisecond,  [telemetry].[AutomatedTest_exec_requests].start_time, [telemetry].[AutomatedTest_exec_requests].end_time)) / 
          CONVERT(FLOAT,1000) AS QueryExecutionTimeInSeconds,
       CONVERT(FLOAT,DATEDIFF(millisecond,  [telemetry].[AutomatedTest_exec_requests].submit_time,[telemetry].[AutomatedTest_exec_requests].end_compile_time)) / 
          CONVERT(FLOAT,1000)  AS QueryCompileTimeInSeconds,
       (CONVERT(FLOAT,DATEDIFF(millisecond, [telemetry].[AutomatedTest_exec_requests].submit_time,[telemetry].[AutomatedTest_exec_requests].start_time)) - 
          CONVERT(FLOAT,DATEDIFF(millisecond, submit_time,end_compile_time))) / CONVERT(FLOAT,1000) AS QueryQueueTimeInSeconds,
       CONVERT(FLOAT,DATEDIFF(millisecond,  [telemetry].[AutomatedTest_exec_requests].submit_time,[telemetry].[AutomatedTest_exec_requests].end_time)) / 
          CONVERT(FLOAT,1000) AS QueryElaspedTimeInSeconds
 FROM [telemetry].[AutomatedTest]
      INNER JOIN [telemetry].[AutomatedTestSession]
              ON [telemetry].[AutomatedTest].[AutomatedTestId] = [telemetry].[AutomatedTestSession].[AutomatedTestId]
             AND [telemetry].[AutomatedTest].[AutomatedTestId]  = @AutomatedTestId
      INNER JOIN [telemetry].[AutomatedTest_exec_requests]
              ON [telemetry].[AutomatedTest_exec_requests].session_id = [telemetry].[AutomatedTestSession].session_id
             AND [telemetry].[AutomatedTest_exec_requests].[label] IS NOT NULL
ORDER BY [telemetry].[AutomatedTest].[AutomatedTestId], [telemetry].[AutomatedTest_exec_requests].[label]


END
GO

