IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'SystemConfigOnboardCarrier' and column_name = 'BIPDMin')
BEGIN
	ALTER TABLE SystemConfigOnboardCarrier ADD BIPDMin Real NOT NULL DEFAULT(750000);
END
IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'SystemConfigOnboardCarrier' and column_name = 'CargoMin')
BEGIN
	ALTER TABLE SystemConfigOnboardCarrier ADD CargoMin Real NOT NULL DEFAULT(100000);
END
IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'SystemConfigOnboardCarrier' and column_name = 'GeneralMin')
BEGIN
	ALTER TABLE SystemConfigOnboardCarrier ADD GeneralMin Real NOT NULL DEFAULT(0);
END