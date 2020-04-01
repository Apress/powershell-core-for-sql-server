<#-----------------------------------------------------------------------------
  PowerShell Core for SQL Server
  Updating the database

  Author: Robert C. Cain | @ArcaneCode | arcanecode@gmail.com
          http://arcanecode.com
 
  This module is Copyright (c) 2018, 2019 Robert C. Cain. All rights reserved.

  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
  
  This module may not be reproduced in whole or in part without the express
  written consent of the author. Portions may be be used within your own
  projects.
-----------------------------------------------------------------------------#>

# Import our module, and setup a hash table with our values
# so we can use splatting
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
  $sql = 'SELECT * FROM MyCoolDatabase.dbo.City'
  Invoke-SqlCmd -Query $sql @sqlParams | Format-Table  
}

#------------------------------------------------------------------------------
# Updating using Invoke-SqlCmd
#------------------------------------------------------------------------------
# Refresh ourselves on what records are present
Show-Rows
          
# Update a record using SQL
$sql = @"
USE MyCoolDatabase
GO

UPDATE dbo.City 
   SET StateShort = 'AL'
     , StateFull = 'Alabama' 
 WHERE CityAlias = 'Internal Revenue Service'
"@

Invoke-SqlCmd -Query $sql @sqlParams 

# Now show the rows with the new update
Show-Rows


#------------------------------------------------------------------------------
# SQL Server for people who don't like SQL
#------------------------------------------------------------------------------

# There are a couple of cmdlets that make accessing data in SQL Server easier
# for people who are not familiar with the SQL Language. 

# Unlike Invoke-SqlCmd, which uses a plain text user ID/password, these
# require the use of the PSCredential object

$pw = ConvertTo-SecureString "passW0rd!" -AsPlainText -Force
$pscred = New-Object System.Management.Automation.PSCredential('sa', $pw)

# Basic Read command
Read-SqlTableData -Credential $pscred `
                  -ServerInstance 'localhost,1433' `
                  -DatabaseName 'MyCoolDatabase' `
                  -SchemaName 'dbo' `
                  -TableName 'City' `
                  -ColumnName 'City', 'StateShort', 'StateFull', 'County', 'CityAlias' `
                  -TopN 10 |
  Format-Table


# If you omit the column name parameter, all columns are returned
Clear-Host
Read-SqlTableData -Credential $pscred `
                  -ServerInstance 'localhost,1433' `
                  -DatabaseName 'MyCoolDatabase' `
                  -SchemaName 'dbo' `
                  -TableName 'City' `
                  -TopN 10 |
  Format-Table

# You can also pick a subset of columns
Clear-Host
Read-SqlTableData -Credential $pscred `
                  -ServerInstance 'localhost,1433' `
                  -DatabaseName 'MyCoolDatabase' `
                  -SchemaName 'dbo' `
                  -TableName 'City' `
                  -ColumnName 'City', 'StateFull', 'County', 'CityAlias' `
                  -TopN 10 |
  Format-Table

# Sorting the output is also supported
Clear-Host
Read-SqlTableData -Credential $pscred `
                  -ServerInstance 'localhost,1433' `
                  -DatabaseName 'MyCoolDatabase' `
                  -SchemaName 'dbo' `
                  -TableName 'City' `
                  -ColumnName 'StateFull', 'CityAlias', 'City', 'County' `
                  -ColumnOrder 'StateFull', 'CityAlias' `
                  -TopN 10 |
  Format-Table

# Filtering is done after the data is returned
Clear-Host
Read-SqlTableData -Credential $pscred `
  -ServerInstance 'localhost,1433' `
  -DatabaseName 'MyCoolDatabase' `
  -SchemaName 'dbo' `
  -TableName 'City' `
  -ColumnName 'City', 'StateShort', 'StateFull', 'County', 'CityAlias' `
  -TopN 10 |
  Where-Object StateShort -eq 'NY' |
  Format-Table

# There is a cmdlet for working with views, such as the view from the master db
Clear-Host
Read-SqlViewData -Credential $pscred `
                 -ServerInstance 'localhost,1433' `
                 -DatabaseName 'MyCoolDatabase' `
                 -SchemaName 'INFORMATION_SCHEMA' `
                 -ViewName 'Tables' 

# Likewise there's a cmdlet for writing data
# Load up some data into an array
$cities = @( [PSCustomObject]@{ City = 'Campton'; 
                 StateShort = 'NH'; 
                 StateFull = 'New Hampshire'; 
                 County = 'GRAFTON'; 
                 CityAlias = 'Campton'
               }
           , [PSCustomObject]@{ City = 'Canterbury'; 
                 StateShort = 'NH'; 
                 StateFull = 'New Hampshire'; 
                 County = 'MERRIMACK'; 
                 CityAlias = 'Canterbury'
               }
          , [PSCustomObject]@{ City = 'Center Barnstead'; 
                 StateShort = 'NH'; 
                 StateFull = 'New Hampshire'; 
                 County = 'BELKNAP'; 
                 CityAlias = 'Ctr Barnstead'
               }
           , [PSCustomObject]@{ City = 'Franklin'; 
                 StateShort = 'NH'; 
                 StateFull = 'New Hampshire'; 
                 County = 'MERRIMACK'; 
                 CityAlias = 'W Franklin'
               }
)

# Now pipe that into the Write cmdlet
$cities | Write-SqlTableData `
            -Credential $pscred `
            -ServerInstance 'localhost,1433' `
            -DatabaseName 'MyCoolDatabase' `
            -SchemaName 'dbo' `
            -TableName 'City' 

# Read it back
Clear-Host
Read-SqlTableData -Credential $pscred `
                  -ServerInstance 'localhost,1433' `
                  -DatabaseName 'MyCoolDatabase' `
                  -SchemaName 'dbo' `
                  -TableName 'City' `
                  -ColumnName 'StateFull', 'CityAlias', 'City', 'County' `
                  -ColumnOrder 'StateFull', 'CityAlias' |
  Format-Table

# Note we can read rows back using our Show-Rows cmdlet too
Show-Rows


