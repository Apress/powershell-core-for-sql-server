<#-----------------------------------------------------------------------------
  PowerShell Core for SQL Server
  Creating a Database

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
                'Database' = 'master'
                'Username' = 'sa'
                'Password' = 'passW0rd!'
                'QueryTimeout' = 50000
              }

# Now create a simple query to create our database
$sql = @'
  CREATE DATABASE MyCoolDatabase;
  GO
'@

Invoke-Sqlcmd -Query $sql @sqlParams

# We can confirm it is there by querying the databases system view
$sql = 'SELECT [name], [database_id] FROM sys.databases'
Invoke-Sqlcmd -Query $sql @sqlParams

# With the database created, we can now create a table in it
$sql = @'
USE MyCoolDatabase;
GO

CREATE TABLE dbo.City
(
  City         NVARCHAR(100)
, StateShort   NCHAR(2)
, StateFull    NVARCHAR(100)
, County       NVARCHAR(100)
, CityAlias    NVARCHAR(100)
)
GO
'@
Invoke-Sqlcmd -Query $sql @sqlParams

# We'll confirm it is there by querying the built in tables view
$sql = 'SELECT * FROM MyCoolDatabase.INFORMATION_SCHEMA.TABLES'
Invoke-Sqlcmd -Query $sql @sqlParams

#------------------------------------------------------------------------------
# Advanced database creation
#------------------------------------------------------------------------------

# In the previous example we used a very simple query to create our database. 
# You can use a much more advanced query if you wish

$sql = @'
USE master;
GO

CREATE DATABASE AnotherCoolDB
ON
(
    NAME = AnotherCoolDB_dat
  , FILENAME = '/tmp/AnotherCoolDB.mdf'
  , SIZE = 10
  , MAXSIZE = 50
  , FILEGROWTH = 5
)
LOG ON
(
    NAME = AnotherCoolDB_log
  , FILENAME = '/tmp/AnotherCoolDB.ldf'
  , SIZE = 5
  , MAXSIZE = 25
  , FILEGROWTH = 5
);
GO
'@

Invoke-Sqlcmd -Query $sql @sqlParams

# Confirm it is there by querying the databases system view
$sql = 'SELECT [name], [database_id] FROM master.sys.databases'
Invoke-Sqlcmd -Query $sql @sqlParams

# We can also remove a database as easily. We'll be using MyCoolDB later, 
# but we can drop AnotherCoolDB as it won't be used again
$sql = 'DROP DATABASE AnotherCoolDB'
Invoke-Sqlcmd -Query $sql @sqlParams

# Confirm it is there by querying the databases system view
$sql = 'SELECT [name], [database_id] FROM master.sys.databases'
Invoke-Sqlcmd -Query $sql @sqlParams
