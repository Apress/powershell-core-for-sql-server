<#-----------------------------------------------------------------------------
  PowerShell Core for SQL Server
  Executing SQL Statements

  Author: Robert C. Cain | @ArcaneCode | arcanecode@gmail.com
          http://arcanecode.com
 
  This module is Copyright (c) 2018, 2019 Robert C. Cain. All rights reserved.

  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
  
  This module may not be reproduced in whole or in part without the express
  written consent of the author. Portions may be be used within your own
  projects.
-----------------------------------------------------------------------------#>

Invoke-Sqlcmd -Query 'SELECT * FROM master.INFORMATION_SCHEMA.Tables' `
              -ServerInstance 'localhost,1433' `
              -Database 'master' `
              -Username 'sa' `
              -Password 'passW0rd!' `
              -QueryTimeout 50000
              