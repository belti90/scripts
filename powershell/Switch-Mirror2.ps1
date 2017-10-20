# Script to failover an individual mirrored database or all
# Requires sqlps module

# Accept Instance Name and/or database name or all as parameters

param (
    [Parameter(Mandatory = $true)]
    [string] $inst,
    [Parameter(Mandatory = $false)]
    [string] $database = ''
    )


#Check if we're failing all the mirrored databases or just a specific one
#We're failing over all mirrored DBs
If ($database.Equals('All') -or $database -eq '')
{
   #Write-Output("In not all here...$($database)")
   $mirrordb = .\Logon-Sql.ps1 -inst $inst -qry "select db_name(database_id) as dbname, mirroring_state_desc as status, mirroring_role_desc as mirror_role,mirroring_partner_instance as mirror_instance, mirroring_safety_level as safety_level from sys.database_mirroring where mirroring_state is not null"
   
}

Else #Specific database 
#If ($database -eq 'All' -or $database -eq '') 
{
   #Write-Output("In here")
   $mirrordb = .\Logon-Sql.ps1 -inst $inst -qry "select db_name(database_id) as dbname, mirroring_state_desc as status, mirroring_role_desc as mirror_role,mirroring_partner_instance as mirror_instance, mirroring_safety_level as safety_level from sys.database_mirroring where mirroring_state is not null and db_name(database_id) = '$($database)'" 
}

If ($mirrordb.count -ne 0) {

foreach ($db in $mirrordb)
      {
       #Check for blank row in array and skip
       if ($db -ne $null) {
        Write-Output("Looping through...$($db.dbname) database")

        #Check if DB is in synch else skip
        if ($db.status -eq 'SYNCHRONIZED')
        {
            #Check if server is Principal or mirror
            If ($db.mirror_role -eq 'PRINCIPAL')
            {
              $server = $inst       
            }
            Elseif ($db.mirror_role -eq 'MIRROR')
            {
              $server = $db.mirror_instance
              $db.mirror_instance = $inst
            }
                        
            #Write-Output("Failing over $($db.dbname)...")
            #Write-Output($db.safety_level)
            #Write-Output("Principal is $($server)")
            #Write-Output("Mirror is $($db.mirror_instance)")

            #Check if the database is in sync or async mode
            If ($db.safety_level -eq 1) #Database is in async mode and needs to be changed to sync mode
            {
                Write-Output("Safe mode off, changing to on.")
                .\Logon-Sql.ps1 -inst $server -qry "ALTER DATABASE $($db.dbname) SET PARTNER SAFETY FULL"
                sleep 2
                Write-Output("Actual Failover")
                .\Logon-Sql.ps1 -inst $server -qry "ALTER DATABASE $($db.dbname) SET PARTNER FAILOVER"
                Sleep 2
                Write-Output("Change back to off.")
                .\Logon-Sql.ps1 -inst $db.mirror_instance -qry "ALTER DATABASE $($db.dbname) SET PARTNER SAFETY OFF"
            }
            
            ElseIf ($db.safety_level -eq 2) #Mirror database can be safely failed over
            {
                Write-Output("Safe mode on...proceeding to failover.")
                .\Logon-Sql.ps1 -inst $server -qry "ALTER DATABASE $($db.dbname) SET PARTNER FAILOVER"
            }

        }
        Else {Write-Output("$($db.dbname) is not in sync and will not be failed over!")}
       }
      }
  }
Else {Write-Output("$($database) not found or is not mirrored! Exiting!")}
