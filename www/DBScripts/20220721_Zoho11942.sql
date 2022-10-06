IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'LoadStops' and column_name = 'DriverTimeIn')
BEGIN
	ALTER TABLE LoadStops ADD DriverTimeIn varchar(10);
END

IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'LoadStops' and column_name = 'DriverTimeOut')
BEGIN
	ALTER TABLE LoadStops ADD DriverTimeOut varchar(10);
END

