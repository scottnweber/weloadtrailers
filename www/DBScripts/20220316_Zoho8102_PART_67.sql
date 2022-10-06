IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'SystemConfigOnboardCarrier' and column_name = 'UseEmail')
BEGIN
	ALTER TABLE SystemConfigOnboardCarrier ADD UseEmail int not null default 0;
END