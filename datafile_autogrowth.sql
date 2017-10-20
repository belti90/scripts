#List all datafiles size and growth parameters

SELECT DB_NAME([database_id]) AS [Database Name],
[file_id], name, physical_name, type_desc, state_desc,
is_percent_growth, growth,
CONVERT(bigint, growth/128.0) AS [Growth in MB],
CONVERT(bigint, size/128.0) AS [Total Size in MB]
FROM sys.master_files WITH (NOLOCK)
WHERE [database_id] > 4
ORDER BY DB_NAME([database_id]) OPTION (RECOMPILE);