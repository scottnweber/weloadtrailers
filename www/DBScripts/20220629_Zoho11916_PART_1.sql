IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'SecurityParameter' and column_name = 'ParameterID')
BEGIN
	ALTER TABLE SecurityParameter ADD ParameterID int;
END
GO