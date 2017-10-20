# Simple script to logon to a SQL instance and run a query.

param (
[string] $inst = $null,
[string] $qry = $null
)

Write-Output $servers
Invoke-Sqlcmd -Query $qry -ServerInstance $inst
