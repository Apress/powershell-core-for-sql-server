CREATE DATABASE MyCoolDatabase;
GO

USE MyCoolDatabase;
GO

CREATE TABLE dbo.Geo
(
  City         NVARCHAR(100)
, StateShort   NCHAR(2)
, StateFull    NVARCHAR(100)
, County       NVARCHAR(100)
, CityAlias    NVARCHAR(100)
)
GO