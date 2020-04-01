<#-----------------------------------------------------------------------------
  PowerShell Core for SQL Server
  Loading data into a database

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
# so we can use splatting. Note, with our database now created, we can update
# our parameter hash table to use MyCoolDatabase instead of the master
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
# Method 1 - Use embedded SQL
#------------------------------------------------------------------------------
$sql = @"
  INSERT INTO dbo.City 
    (City, StateShort, StateFull, County, CityAlias)
  VALUES
    ('Holtsville', 'NY', 'New York', 'SUFFOLK', 'Internal Revenue Service')
"@
Invoke-SqlCmd -Query $sql @sqlParams 

Show-Rows

#------------------------------------------------------------------------------
# Method 2 - Create a insert statement from variables
#------------------------------------------------------------------------------

# Note we can use any names for the variables, but using the same name as
# the column will make it easier to keep track of

$city = 'Holtsville'
$stateShort = 'NY'
$stateFull = 'New York'
$county = 'SUFFOLK'
$cityAlias = 'Holtsville'

$sql = @"
  INSERT INTO dbo.City 
    (City, StateShort, StateFull, County, CityAlias)
  VALUES
    ('$city', '$stateShort', '$stateFull', '$county', '$cityAlias')
"@
Invoke-SqlCmd -Query $sql @sqlParams 

# Verify it is there
Show-Rows

#------------------------------------------------------------------------------
# Method 3 - Load from an array row by row
#------------------------------------------------------------------------------
# Now we'lll create some custom objects into an array
# and load the database from the array
$cities = @( [PSCustomObject]@{ City = 'Adjuntas'; 
                                StateShort = 'PR'; 
                                StateFull = 'Puerto Rico'; 
                                County = 'ADJUNTAS'; 
                                CityAlias = 'URB San Joaquin'
                              }
           , [PSCustomObject]@{ City = 'Adjuntas'; 
                                StateShort = 'PR'; 
                                StateFull = 'Puerto Rico'; 
                                County = 'ADJUNTAS'; 
                                CityAlias = 'Jard De Adjuntas'
                              }
           , [PSCustomObject]@{ City = 'Adjuntas'; 
                                StateShort = 'PR'; 
                                StateFull = 'Puerto Rico'; 
                                County = 'ADJUNTAS'; 
                                CityAlias = 'Colinas Del Gigante'
                              }
           , [PSCustomObject]@{ City = 'Adjuntas'; 
                                StateShort = 'PR'; 
                                StateFull = 'Puerto Rico'; 
                                County = 'ADJUNTAS'; 
                                CityAlias = 'Adjuntas'
                              }
           )

foreach($currentCity in $cities)
{
  $sql = @"
  INSERT INTO dbo.City 
    (City, StateShort, StateFull, County, CityAlias)
  VALUES
    ( '$($currentCity.City)'
    , '$($currentCity.StateShort)'
    , '$($currentCity.StateFull)'
    , '$($currentCity.County)'
    , '$($currentCity.CityAlias)'
    )
"@
  Invoke-SqlCmd -Query $sql @sqlParams 

}


# Verify it is there
Show-Rows

#------------------------------------------------------------------------------
# Method 4 - Load from an array in one SQL statement
#------------------------------------------------------------------------------
# Lets reload the array with a new set of values
$cities = @( [PSCustomObject]@{ City = 'Aguada'; 
                                StateShort = 'PR'; 
                                StateFull = 'Puerto Rico'; 
                                County = 'AGUADA'; 
                                CityAlias = 'Comunidad Las Flores'
                              }
           , [PSCustomObject]@{ City = 'Aguada'; 
                                StateShort = 'PR'; 
                                StateFull = 'Puerto Rico'; 
                                County = 'AGUADA'; 
                                CityAlias = 'URB Isabel La Catolica'
                              }
           , [PSCustomObject]@{ City = 'Aguada'; 
                                StateShort = 'PR'; 
                                StateFull = 'Puerto Rico'; 
                                County = 'AGUADA'; 
                                CityAlias = 'Alts De Aguada'
                              }
           , [PSCustomObject]@{ City = 'Aguada'; 
                                StateShort = 'PR'; 
                                StateFull = 'Puerto Rico'; 
                                County = 'AGUADA'; 
                                CityAlias = 'Bo Guaniquilla'
                              }
           )

# Here we'll setup a string builder so we can build a big string for our sql
$sqlSB = [System.Text.StringBuilder]::new()

$sqlHeader = @"
USE MyCoolDatabase
GO

INSERT INTO dbo.City 
  (City, StateShort, StateFull, County, CityAlias)
VALUES
"@

[void]$sqlSB.AppendLine($sqlHeader)
$originalLen = $sqlSB.Length

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

# Display the query we built (just for demo purposes)
$sqlSB.ToString()

# Now run the query against the server. Note when we use a StringBuilder
# we have to convert using the ToString method before passing it to 
# the Invoke-SqlCmd cmdlet
Invoke-SqlCmd -Query $sqlSB.ToString() @sqlParams 

# Verify it is there
Show-Rows
          
