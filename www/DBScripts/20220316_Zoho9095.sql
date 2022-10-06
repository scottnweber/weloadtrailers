DECLARE @Command varchar(150);
SELECT @Command = 'ALTER TABLE dbo.Loads DROP CONSTRAINT '+default_constraints.name+'' FROM sys.all_columns
INNER JOIN sys.tables ON all_columns.object_id = tables.object_id
INNER JOIN sys.schemas ON tables.schema_id = schemas.schema_id
INNER JOIN sys.default_constraints ON all_columns.default_object_id = default_constraints.object_id
WHERE schemas.name = 'dbo' AND tables.name = 'loads'AND all_columns.name = 'SalesRep1Percentage'
exec (@Command);
ALTER TABLE Loads ALTER COLUMN SalesRep1Percentage decimal(7,2) not null;
ALTER TABLE Loads ADD  CONSTRAINT [DF_Loads_SalesRep1Percentage]  DEFAULT ((0)) FOR [SalesRep1Percentage]

SELECT @Command = 'ALTER TABLE dbo.Loads DROP CONSTRAINT '+default_constraints.name+'' FROM sys.all_columns
INNER JOIN sys.tables ON all_columns.object_id = tables.object_id
INNER JOIN sys.schemas ON tables.schema_id = schemas.schema_id
INNER JOIN sys.default_constraints ON all_columns.default_object_id = default_constraints.object_id
WHERE schemas.name = 'dbo' AND tables.name = 'loads'AND all_columns.name = 'SalesRep2Percentage'
exec (@Command);
ALTER TABLE Loads ALTER COLUMN SalesRep2Percentage decimal(7,2) not null;
ALTER TABLE Loads ADD  CONSTRAINT [DF_Loads_SalesRep2Percentage]  DEFAULT ((0)) FOR [SalesRep2Percentage]

SELECT @Command = 'ALTER TABLE dbo.Loads DROP CONSTRAINT '+default_constraints.name+'' FROM sys.all_columns
INNER JOIN sys.tables ON all_columns.object_id = tables.object_id
INNER JOIN sys.schemas ON tables.schema_id = schemas.schema_id
INNER JOIN sys.default_constraints ON all_columns.default_object_id = default_constraints.object_id
WHERE schemas.name = 'dbo' AND tables.name = 'loads'AND all_columns.name = 'SalesRep3Percentage'
exec (@Command);
ALTER TABLE Loads ALTER COLUMN SalesRep3Percentage decimal(7,2) not null;
ALTER TABLE Loads ADD  CONSTRAINT [DF_Loads_SalesRep3Percentage]  DEFAULT ((0)) FOR [SalesRep3Percentage]

SELECT @Command = 'ALTER TABLE dbo.Loads DROP CONSTRAINT '+default_constraints.name+'' FROM sys.all_columns
INNER JOIN sys.tables ON all_columns.object_id = tables.object_id
INNER JOIN sys.schemas ON tables.schema_id = schemas.schema_id
INNER JOIN sys.default_constraints ON all_columns.default_object_id = default_constraints.object_id
WHERE schemas.name = 'dbo' AND tables.name = 'loads'AND all_columns.name = 'Dispatcher1Percentage'
exec (@Command);
ALTER TABLE Loads ALTER COLUMN Dispatcher1Percentage decimal(7,2) not null;
ALTER TABLE Loads ADD  CONSTRAINT [DF_Loads_Dispatcher1Percentage]  DEFAULT ((0)) FOR [Dispatcher1Percentage]

SELECT @Command = 'ALTER TABLE dbo.Loads DROP CONSTRAINT '+default_constraints.name+'' FROM sys.all_columns
INNER JOIN sys.tables ON all_columns.object_id = tables.object_id
INNER JOIN sys.schemas ON tables.schema_id = schemas.schema_id
INNER JOIN sys.default_constraints ON all_columns.default_object_id = default_constraints.object_id
WHERE schemas.name = 'dbo' AND tables.name = 'loads'AND all_columns.name = 'Dispatcher2Percentage'
exec (@Command);
ALTER TABLE Loads ALTER COLUMN Dispatcher2Percentage decimal(7,2) not null;
ALTER TABLE Loads ADD  CONSTRAINT [DF_Loads_Dispatcher2Percentage]  DEFAULT ((0)) FOR [Dispatcher2Percentage]

SELECT @Command = 'ALTER TABLE dbo.Loads DROP CONSTRAINT '+default_constraints.name+'' FROM sys.all_columns
INNER JOIN sys.tables ON all_columns.object_id = tables.object_id
INNER JOIN sys.schemas ON tables.schema_id = schemas.schema_id
INNER JOIN sys.default_constraints ON all_columns.default_object_id = default_constraints.object_id
WHERE schemas.name = 'dbo' AND tables.name = 'loads'AND all_columns.name = 'Dispatcher3Percentage'
exec (@Command);
ALTER TABLE Loads ALTER COLUMN Dispatcher3Percentage decimal(7,2) not null;
ALTER TABLE Loads ADD  CONSTRAINT [DF_Loads_Dispatcher3Percentage]  DEFAULT ((0)) FOR [Dispatcher3Percentage]