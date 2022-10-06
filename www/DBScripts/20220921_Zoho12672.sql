IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'SystemConfigOnboardCarrier' and column_name = 'AllowDownloadAndSubmitManually')
BEGIN
	ALTER TABLE SystemConfigOnboardCarrier ADD AllowDownloadAndSubmitManually BIT NOT NULL DEFAULT(0);
END