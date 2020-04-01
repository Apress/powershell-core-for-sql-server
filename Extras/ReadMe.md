# Extras

This folder contains additional files and information not part of the main demo.

## Cites Data

The list of cities came from an open source project located at: https://github.com/grammakov/USA-cities-and-states

The raw download can be found in the file us_city_states.txt. I used Excel to convert it to a CSV file.

I then used the script generate-insert-from-csv.ps1 to convert it to a series of insert statements. This was then saved in the file insert-city-data.sql, found in the main demo.

## Docker

For this course, we used Docker to house SQL Server in a container. These techniques would work on any SQL Server, should you wish to use Docker for yourself additional information is provided here.

Install Docker using the instructions found on the Docker website, http://docker.com. Because there are many operating systems, it's best to use their instructions for your particular machine.

Once installed, you'll need to start by pulling a docker image for SQL Server. In this course I used the SQL Server 2017 image.

```bash
sudo docker pull mcr.microsoft.com/mssql/server:2017-latest
```

You can verify it exists by using the image listing command.

```bash
sudo docker image ls
```

With the image downloaded, it's time to run it. This is the basic command.

```bash
docker run -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=passW0rd!' \
  -p 1433:1433 --name arcanesql \
  -d mcr.microsoft.com/mssql/server:2017-latest
```

In the first line we accept the license agreement, then set our system administrator (SA) password. The backslash at the end is the line continuation character in bash, you can also use the command in a single line (see below).

The -p switch is the port number, here we use the standard port number for SQL Server.

Following is the name to give the server. You are free to make up your own name here, if you do be sure to update the name in the demo files.

The final line is the image to launch, in this case the image we just downloaded.

Here is the command all on a single line. (Note )

```bash
sudo docker run -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=passW0rd!' -p 1433:1433 --name arcanesql -d mcr.microsoft.com/mssql/server:2017-latest
```

You can verify the container was installed and is running by listing the containers on your system using the ls command in docker.

```bash
sudo docker container ls
```

At this point the container is up and running. You may wish to stop it, then restart it later. To stop it you can use the appropriately named stop command.

```bash
sudo docker stop arcanesql 
```

To verify it is stopped, you cannot use the ls command as it only displays running containers. Instead you need to use the ps command. This will list all containers, running or not.

```bash
sudo docker ps -a
```

To restart the container, just use the start command.

```bash
sudo docker container start arcanesql 
```

At some point, perhaps when you are done with the course, you will no longer need the container. You can remove it, but it needs to be stopped first. You can use the stop command from above, then use the rm command to remove it.

```bash
sudo docker rm arcanesql
```

If the container is still running, you can add on the --force switch which will stop the container then remove it.

```bash
sudo docker rm --force arcanesql
```

At this point the container is now gone, but the docker image used to create it is still present. It can be useful to keep a docker image for some time in order to generate new containers, however at some point you may no longer need it.

You can delete the image by using the image rm command, and specifying the name of the container to remove.

```bash
sudo docker image rm mcr.microsoft.com/mssql/server:2017-latest
```

You can confirm it has been removed by using the image ls command.

```bash
sudo docker image ls
```

This should provide sufficent information in order to use docker to run the samples in this demo.

## Author Information

### Author

Robert C. Cain | @ArcaneCode | arcanecode@gmail.com 

### Websites

Github: http://arcanerepo.com

Main: http://arcanecode.me 

### Copyright Notice

This document is Copyright (c) 2020 Robert C. Cain. All rights reserved.

The code samples herein is for demonstration purposes. No warranty or guarentee is implied or expressly granted. 

This document may not be reproduced in whole or in part without the express written consent of the author. Information within can be used within your own projects.
