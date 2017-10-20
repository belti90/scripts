# Run a query or sql file against a list of SQL instances in a text file.
# Requires sqlps module

param (
    [Parameter(Mandatory = $false)]
    [string] $inst,
    [Parameter(Mandatory = $false)]
    [string] $qry = '',
    [Parameter(Mandatory = $false)]
    [string] $qryfile = ''
    )

function DispMessage ([string] $Message, [boolean] $ErrorFlag=$False)
{
[string] $DateStamp = get-date -format "yyyy-MM-dd HH:mm.ss"
if ($ErrorFlag)
   {
     Write-Host "[$DateStamp] $Message" -foreground yellow
   }
else
   {
     Write-Host "[$DateStamp] $Message"
   }
   
#Add-Content $logfile "[$DateStamp] $Message"
}


$logfile = "exec-sql.log"
Clear-Content $logfile

foreach ($server in GC "servers.txt")
    {
     if ($qry -ne '')
      {
        #DispMessage "Running query on $($server)"
        try
        {
         Invoke-Sqlcmd -Query $qry -ServerInstance $server -IncludeSqlUserErrors #| Out-File -Append -FilePath $logfile 
        }
        catch
        {
         DispMessage "Error connecting to $($server)"
        }
      }
     Elseif ($qryfile -ne '')
      {
        $Error.Clear()
        #DispMessage "Applying script to $($server)"
        "******************************" | Out-File $logfile -Append
        "Applying script to $($server)" | Out-File $logfile -Append
        try
        {
         Invoke-Sqlcmd -InputFile $qryfile -ServerInstance $server | Out-File $logfile -Append
        }
        catch
        {
         $Error| Out-File $logfile -Append
         "Error connecting to $($server)" | Out-File $logfile -Append
         "******************************" | Out-File $logfile -Append
        }

      }
     Else
      {
       DispMessage "No parameters set....exiting."
       Exit
      }
}

