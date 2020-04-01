<#-----------------------------------------------------------------------------
  PowerShell Core for SQL Server
  Executing SQL from a file

  Author: Robert C. Cain | @ArcaneCode | arcanecode@gmail.com
          http://arcanecode.com
 
  This module is Copyright (c) 2018, 2019 Robert C. Cain. All rights reserved.

  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
  
  This module may not be reproduced in whole or in part without the express
  written consent of the author. Portions may be be used within your own
  projects.
-----------------------------------------------------------------------------#>

#------------------------------------------------------------------------------
# Import our module, and setup a hash table with our values
# so we can use splatting
#------------------------------------------------------------------------------
Import-Module SqlServer   

$sqlParams = @{ 'ServerInstance' = 'localhost,1433'
                'Database' = 'MyCoolDatabase'
                'Username' = 'sa'
                'Password' = 'passW0rd!'
                'QueryTimeout' = 50000
              }

#------------------------------------------------------------------------------
# Before we begin, let's create a small function to display the present rows
#------------------------------------------------------------------------------
function Show-Rows()
{
  Clear-Host
  $sql = 'SELECT * FROM dbo.City'
  Invoke-SqlCmd -Query $sql @sqlParams | Format-Table  
}


#------------------------------------------------------------------------------
# Begin by emptying the table, to make it ready for new rows
#------------------------------------------------------------------------------
# Refresh ourselves on what records are present
Show-Rows 

# Before we execute a sql statement stored a file, 
# we need to reset the target table. First a delete
$sql = @"
DELETE FROM MyCoolDatabase.dbo.City
 WHERE StateShort = 'PR'
"@
Invoke-SqlCmd -Query $sql @sqlParams

Show-Rows

# Next we could do a truncate
$sql = 'TRUNCATE TABLE MyCoolDatabase.dbo.City'
Invoke-SqlCmd -Query $sql @sqlParams

Show-Rows

#------------------------------------------------------------------------------
# Now we'll execute the SQL command stored in a file
#------------------------------------------------------------------------------
# Method 1 - Load the data into a variable, and execute the variable
$sql = Get-Content -Path './Demo/insert-city-data.sql' -Raw 
Invoke-SqlCmd -Query $sql @sqlParams

Show-Rows

# Method 2  Directly call the file
# Reset the table
$sql = 'TRUNCATE TABLE MyCoolDatabase.dbo.City'
Invoke-SqlCmd -Query $sql @sqlParams

# Now use the InputFile parameter to execute the SQL file
Invoke-SqlCmd -InputFile './Demo/insert-city-data.sql' @sqlParams
Show-Rows
