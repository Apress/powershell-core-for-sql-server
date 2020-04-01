<#-----------------------------------------------------------------------------
  PowerShell Core for SQL Server
  Exporting data to a file

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


# Retrieve a small set of data to work with
$sql = 'SELECT TOP 10 * FROM MyCoolDatabase.dbo.City'
$data = Invoke-SqlCmd -Query $sql @sqlParams 

# Once we have the data we can export it to a variety of formats

# Export as a list
$data | Out-File './Demo/CityDataList.txt'

# Export as a table
$data | Format-Table | Out-File './Demo/CityDataTable.txt' 

# By default Out-file will overwrite an existing file. You can add
# to an existing file using the Append switch
$data | Format-Table | Out-File './Demo/CityDataTable.txt' -Append

# Of course you see we now have the issue of duplicate headers.
# We can fix by suppressing them in Format-Table
$data |
  Format-Table -HideTableHeaders |
  Out-File './Demo/CityDataTable.txt' -Append

# Export to a CSV file
$data | Export-Csv './Demo/CityData.csv' 

# Like Out-File, by default Export-CSV will always overwrite. It too has
# an -Append switch
$data | Export-Csv './Demo/CityData.csv' -Append

# Export as XML
$data | ConvertTo-Xml -As String | Out-File './Demo/CityData.xml'

# Export to JSON
$data | ConvertTo-Json | Out-File './Demo/CityData.json'

