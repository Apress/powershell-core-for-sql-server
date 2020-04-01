<#-----------------------------------------------------------------------------
  PowerShell Core for SQL Server
  PowerShell Splatting

  Author: Robert C. Cain | @ArcaneCode | arcanecode@gmail.com
          http://arcanecode.com
 
  This module is Copyright (c) 2018, 2019 Robert C. Cain. All rights reserved.

  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
  
  This module may not be reproduced in whole or in part without the express
  written consent of the author. Portions may be be used within your own
  projects.
-----------------------------------------------------------------------------#>

# Load the SqlServer module so we can use its cmdlets
Import-Module SqlServer   

# Invoke-SqlCmd has a lot of parameters. Repeated executions can make 
# your code quite lengthy. We can save a lot of space by using a technique
# called splatting.

# In splatting you create a hash table with the key / value pairs. The
# keys should match the name of the parameters, and the values be the 
# values you wish to pass in

$sqlParams = @{ 'ServerInstance' = 'localhost,1433'
                'Database' = 'master'
                'Username' = 'sa'
                'Password' = 'passW0rd!'
                'QueryTimeout' = 50000
              }

$sql = 'SELECT * FROM master.INFORMATION_SCHEMA.Tables'

# Now we can call Invoke-SqlCmd. To use the splat, add it to the
# end of the cmdlet. Use the same name as the hashtable, only
# (and this is important) replace the $ with an @ symbol. This
# triggers PowerShell to decompose the hashtable into the list of
# parameters. 
Invoke-Sqlcmd -Query $sql @sqlParams

# From here, all we have to update is the one parameter likely
# to change between calls
$sql = 'SELECT * FROM master.INFORMATION_SCHEMA.Views'
Invoke-Sqlcmd -Query $sql @sqlParams

# In these examples we mixed passing in a named parameter
# with using a splat. We could have also included the SQL statement
# in the splat. 

$sqlParamsAll = @{ 'ServerInstance' = 'localhost,1433'
                   'Database' = 'master'
                   'Username' = 'sa'
                   'Password' = 'passW0rd!'
                   'QueryTimeout' = 50000
                   'Query' = 'SELECT * FROM master.INFORMATION_SCHEMA.Tables'
                 }

Invoke-Sqlcmd @sqlParamsAll

# Then to update the query, we update the hash table
$sqlParamsAll.Query = 'SELECT * FROM master.INFORMATION_SCHEMA.Columns'
Invoke-Sqlcmd @sqlParamsAll

