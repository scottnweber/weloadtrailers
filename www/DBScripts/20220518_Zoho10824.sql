IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'CustomerStops' and column_name = 'PhoneExt')
BEGIN
	ALTER TABLE CustomerStops ADD PhoneExt varchar(50);
END
