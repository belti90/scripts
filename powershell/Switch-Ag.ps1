# Script to switch SQL Availability Group
# Requires sqlps module
param (
[string] $aggroup = $null
)

If ($aggroup) #check if null
{
    #Get secondary server and instance name

    #$agcheck=.\Logon-Sql.ps1 -inst $aggroup -qry "SELECT C.name as ag_name, CS.replica_server_name,case when (SELECT @@servicename) = 'MSSQLSERVER' then 'DEFAULT' else (SELECT @@servicename) end as instance_name, RS.role_desc as role ,RS.synchronization_health_desc as health_status  FROM sys.availability_groups_cluster AS C INNER JOIN sys.dm_hadr_availability_replica_cluster_states AS CS ON CS.group_id = C.group_id INNER JOIN sys.dm_hadr_availability_replica_states AS RS ON RS.replica_id = CS.replica_id where rs.role_desc ='SECONDARY' and c.name='$aggroup'"
    $agcheck=.\Logon-Sql.ps1 -inst $aggroup -qry "SELECT C.name as ag_name, CS.replica_server_name,case when (SELECT @@servicename) = 'MSSQLSERVER' then 'DEFAULT' else (SELECT @@servicename) end as instance_name, RS.role_desc as role ,RS.synchronization_health_desc as health_status  FROM sys.availability_groups_cluster AS C INNER JOIN sys.dm_hadr_availability_replica_cluster_states AS CS ON CS.group_id = C.group_id INNER JOIN sys.dm_hadr_availability_replica_states AS RS ON RS.replica_id = CS.replica_id where rs.role_desc ='SECONDARY'"
    
    Write-Output $agcheck

    if ($agcheck.health_status -eq 'HEALTHY') 
    {
        #$SecondaryServer = $agcheck.
        
        Write-Output "$($agcheck.ag_name) is healthy and can be failed over!  Do you want to proceed? (Default is No)"
        $Readhost = Read-Host "(Y/N)"
        Switch ($Readhost)
        {
        # Proceed to switch AG from replica        
        Y {
           Write-Output "Starting $($agcheck.ag_name) failover..."
           #Switch-SqlAvailabilityGroup -Path SQLSERVER:\Sql\$agcheck.replica_server_name\$agcheck.instance_name\AvailabilityGroups\$agcheck.ag_name -WhatIf
           .\Logon-Sql.ps1 -inst $agcheck.replica_server_name -qry "ALTER AVAILABILITY GROUP $($agcheck.ag_name) FAILOVER;"
          }
        N {Write-Output "Skipping $($agcheck.ag_name) failover..."}
        Default {Write-Output "Default, skipping $($agcheck.ag_name) failover..."}
        }

        
    }
    else {Write-Output "$($agcheck.ag_name) is NOT healthy! Do not attempt failover!!  Possible data loss!"}

}
else {Write-Output "No AG name provided.  Exiting!"}
