<#-----------------------------------------------------------------------------
  PowerShell Core for SQL Server
  Getting the SQL Server Module

  Author: Robert C. Cain | @ArcaneCode | arcanecode@gmail.com
          http://arcanecode.com
 
  This module is Copyright (c) 2018, 2019 Robert C. Cain. All rights reserved.

  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
  
  This module may not be reproduced in whole or in part without the express
  written consent of the author. Portions may be be used within your own
  projects.
-----------------------------------------------------------------------------#>

# Before you can work with SQL Server, you need to have the SQL Server module
# installed. You can check to see if it is already installed by using the 
# Get-Module cmdlet. 
Get-Module -ListAvailable SqlServer

# If the SQL Server module isn't installed, you can easily download and install
# it from the global PowerShell Repository known as the PowerShell Gallery
Find-Module SqlServer 

# It should output the current version, what repository (PSGallery) and a 
# description. 

# To install, we simply run Install-Module
Install-Module SqlServer

# Running Get-Module again should show the new version installed
Get-Module -ListAvailable SqlServer

# If you have the module installed, you can update it to the current version
# by using Update-Module
Update-Module SqlServer

# If for whatever reason you no longer need the module, you can also 
# uninstall it
Uninstall-Module SqlServer
Get-Module -ListAvailable SqlServer


<#-----------------------------------------------------------------------------
  Only install/update if needed

  You can also make this a bit more programmatic. Here we test to see if
  the module is installed by counting the number of modules with the name
  SqlServer. It will be 0 if it's not installed, or 1 if it is. 
  
  Additionally, we'll add the -Force switch to suppress answering any 
  prompts and forcing it to install All components
-----------------------------------------------------------------------------#>

# In the else branch, we can then compare version numbers to see 
# if it needs updating

if ($(Get-Module -ListAvailable SqlServer).Count -eq 0)
{
  Install-Module SqlServer -Force
}
else 
{
  # Get the version number currently installed
  $installed = Get-Module -ListAvailable SqlServer
  $installedVersion = $installed.Version.ToString()

  # Get the version number for the one in the Gallery
  $gallery = Find-Module SqlServer
  $galleryVersion = $gallery.Version.ToString()

  if ($galleryVersion -ne $installedVersion)
  {
    Update-Module SqlServer -Force
  }
}

# See what version is now installed
Get-Module -ListAvailable SqlServer


<#-----------------------------------------------------------------------------
   Installing a previous version

   It is possible you may want to install a previous vesion of the module.
   For example, as of the creation of this demo the most current version of
   the SqlServer module is 21.1.18209. Let's say you have only tested your
   code under version the previous version, 21.1.18206 and want to install
   that version. You can specify a version number when installing the 
   module. 
-----------------------------------------------------------------------------#>
# First, for this demo we'll uninstall the version we've installed
Uninstall-Module SqlServer

# Next, you can add the -AllVersions switch to get a list of all available
# versions of a module
Find-Module SqlServer -AllVersions

# Now we'll install the version we want using the -RequiredVersion switch and
# pass in the version number we want
Install-Module SqlServer -RequiredVersion '21.1.18206' -Force

# Now we can verify the correct version was installed
Get-Module -ListAvailable SqlServer

# When ready, you can later use Update-Module to update to the latest version


<#-----------------------------------------------------------------------------
   Installing multiple versions of the same module

   You can have multiple versions of a module installed on the same machine.
   You can then load a specific version. 

   Note if you install a module or version of a module already installed it
   doesn't do anything, so no harm will come to your system
-----------------------------------------------------------------------------#>

# First, let's install multiple versions
Install-Module SqlServer -RequiredVersion '21.1.18206' -Force
Install-Module SqlServer -RequiredVersion '21.1.18179' -Force
Install-Module SqlServer -RequiredVersion '21.1.18147' -Force

# Now list what is installed on the system
Get-Module -ListAvailable SqlServer

# If we have a version loaded in memory, let's remove it from memory
# (note this won't uninstall it, just unload it from memory)
if ($(Get-Module SqlServer).Count -gt 0)
{ 
  Remove-Module SqlServer
}

# Now load the specific version we want
Import-Module SqlServer -RequiredVersion '21.1.18179'

# Using Get-Module with the name of the module will show what is loaded
# in memory
Get-Module SqlServer 

# When done you can uninstall a no longer needed version by using the
# same -RequiredVersion parameter. Note if you don't pass in a version,
# it will uninstall the most recent version
Uninstall-Module SqlServer -RequiredVersion '21.1.18179'

# Show it's gone from disk
Get-Module SqlServer -ListAvailable

# An odd quirk, even though 18179 has been removed from disk, because we
# had it loaded in memory, it is still loaded in memory...
Get-Module SqlServer 

# Thus after Uninstalling a module, it is recommended you then do
# a remove-module to be sure it is completely gone...
if ($(Get-Module SqlServer).Count -gt 0)
  { Remove-Module SqlServer }

# You can remove all installed versions by using ListAvailable and piping it
# to Uninstall
Get-Module SqlServer -ListAvailable | Uninstall-Module
Get-Module SqlServer -ListAvailable

# If you want to continue with the examples in this video, don't forget
# to install the most current version of the SqlServer module.
Install-Module SqlServer -Force 

<#-----------------------------------------------------------------------------
   A Note on Testing and Versions

   In general you should avoid placing the install / update cmdlets as part
   of your main scripts. Instead, keep them separate and execute the install
   or updates seperately. 

   You will always want to test your scripts against a specific version of
   any module, including SqlServer, to ensure no breaking changes were 
   introduced as part of an upgrade to a required module. 

   This is especially critical in production systems. Anytime a module
   is updated always test your scripts in a dev/test environment prior 
   to upgrading your production systems. 

-----------------------------------------------------------------------------#>
