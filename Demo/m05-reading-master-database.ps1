<#-----------------------------------------------------------------------------
  PowerShell Core for SQL Server
  Reading the master database

  Author: Robert C. Cain | @ArcaneCode | arcanecode@gmail.com
          http://arcanecode.com
 
  This module is Copyright (c) 2018, 2019 Robert C. Cain. All rights reserved.

  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
  
  This module may not be reproduced in whole or in part without the express
  written consent of the author. Portions may be be used within your own
  projects.
-----------------------------------------------------------------------------#>
# The basic Invoke-SqlCmd call
Invoke-Sqlcmd -Query "SELECT * FROM master.INFORMATION_SCHEMA.Tables" `
              -ServerInstance 'localhost,1433' `
              -Database 'master' `
              -Username 'sa' `
              -Password 'passW0rd!' `
              -QueryTimeout 50000

# Invoke-SqlCmd becomes easier to read and to transfer to new scripts
# when you use variables
$serverName = 'localhost,1433'
$dbName = 'master'
$userName = 'sa'
$pw = 'passW0rd!'
$queryTimeout = 50000

$sql = "SELECT * FROM master.INFORMATION_SCHEMA.Tables"
Invoke-Sqlcmd -Query $sql `
              -ServerInstance $serverName `
              -Database $dbName `
              -Username $userName `
              -Password $pw `
              -QueryTimeout $queryTimeout


$tables = Invoke-Sqlcmd -Query $sql `
                        -ServerInstance $serverName `
                        -Database $dbName `
                        -Username $userName `
                        -Password $pw `
                        -QueryTimeout $queryTimeout

# Display what is in the variable
$tables

# Show the members, and note how each column becomes
# a property 
$tables | Get-Member

# Loop over it
Clear-Host
foreach ($table in $tables)
{
  Write-Host "The table $($table.TABLE_NAME) is of type $($table.TABLE_TYPE)"
}

