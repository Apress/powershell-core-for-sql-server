<#-----------------------------------------------------------------------------
  PowerShell Core for SQL Server
  Importing data from a file

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
# Before we begin, let's create some helper functions
#------------------------------------------------------------------------------
function Show-Rows()
{
  Clear-Host
  $sql = 'SELECT * FROM dbo.City'
  Invoke-SqlCmd -Query $sql @sqlParams | Format-Table  
}

function Reset-Table ()
{  
  $sql = 'TRUNCATE TABLE MyCoolDatabase.dbo.City'
  Invoke-SqlCmd -Query $sql @sqlParams
      
}

#------------------------------------------------------------------------------
# Importing Data from Files
#------------------------------------------------------------------------------

# Importing CSV
$csvData = Import-Csv './Demo/CityData.csv'
$csvData | Select-Object -First 10 | Format-Table

# Importing XML
$xmlData = (Select-Xml -XPath /Objects/Object/Property -Path './Demo/CityData.xml').Node
$xmlData

# Importing JSON
$jsonData = Get-Content -Path './Demo/CityData.json' -Raw  
$jsonData
$jsonData | 
  ConvertFrom-Json |
  Select-Object City, StateShort, StateFull, County, CityAlias

#------------------------------------------------------------------------------
# Upload to SQL Server reusing a technqiue from Module 8
#------------------------------------------------------------------------------

# First limit the number of rows for demo purposes
$cities = $csvData | Select-Object -First 10

# Reset the table and show it's now empty
Reset-Table
Show-Rows

# Here we'll setup a string builder so we can build a big string for our sql
$sqlSB = [System.Text.StringBuilder]::new()

# Define the header for the SQL
$sqlHeader = @"
INSERT INTO dbo.City 
  (City, StateShort, StateFull, County, CityAlias)
VALUES
"@

[void]$sqlSB.AppendLine($sqlHeader)
$originalLen = $sqlSB.Length

# Now start adding the values
foreach($currentCity in $cities)
{
  # Append a comma if it's after the first append
  if ($sqlSB.Length -eq $originalLen)
  {
    [void]$sqlSB.Append('    ')
  }
  else 
  {
    [void]$sqlSB.Append('  , ')
  }

  $sql = @"
( '$($currentCity.City)'
    , '$($currentCity.StateShort)'
    , '$($currentCity.StateFull)'
    , '$($currentCity.County)'
    , '$($currentCity.CityAlias)'
    )
"@
  [void]$sqlSB.AppendLine($sql)
}

# Note, the SQL Insert has a limit of 1000 rows,
# if your input data has more than 1000 you'll need to add logic
# to end the input and reinsert the header

# Display the query we built (just for demo purposes)
$sqlSB.ToString()

# Now run the query against the server. Note when we use a StringBuilder
# we have to convert using the ToString method before passing it to 
# the Invoke-SqlCmd cmdlet
Invoke-SqlCmd -Query $sqlSB.ToString() @sqlParams 
Show-Rows

#------------------------------------------------------------------------------
# Now a second method
#------------------------------------------------------------------------------

# We saw using Write-SqlTableData earlier to update an existing table.
# A handy thing if the table does not exist it will create it
$sql = 'DROP TABLE MyCoolDatabase.dbo.City'
Invoke-SqlCmd -Query $sql @sqlParams 

# Now confirm it's gone
$sql = 'SELECT * FROM MyCoolDatabase.INFORMATION_SCHEMA.Tables'
Invoke-Sqlcmd -Query $sql @sqlParams

# Convert the user id/password to a PS Credential
$pw = ConvertTo-SecureString "passW0rd!" -AsPlainText -Force
$pscred = New-Object System.Management.Automation.PSCredential('sa', $pw)

# Now pipe our data into the Write cmdlet. Note that you have to use the 
# -Force to make it create the table
$cities | Write-SqlTableData `
            -Credential $pscred `
            -ServerInstance 'localhost,1433' `
            -DatabaseName 'MyCoolDatabase' `
            -SchemaName 'dbo' `
            -TableName 'City' `
            -Force

# Confirm it worked
Show-Rows
