# Simple script to logon to a SQL instance and run a query.
# Daniel Borg 2017-04-19

param (
[string] $inst = $null,
[string] $qry = $null
)

Write-Output $servers
Invoke-Sqlcmd -Query $qry -ServerInstance $inst