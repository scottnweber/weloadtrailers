IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'FileAttachments' and column_name = 'Recurring')
BEGIN
	ALTER TABLE FileAttachments ADD Recurring BIT NOT NULL DEFAULT(0);
END

IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'FileAttachments' and column_name = 'RenewalDate')
BEGIN
	ALTER TABLE FileAttachments ADD RenewalDate datetime;
END

IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'FileAttachments' and column_name = 'Interval')
BEGIN
	ALTER TABLE FileAttachments ADD Interval INT;
END

IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'SystemConfigOnboardCarrier' and column_name = 'RequireBIPDInsurance')
BEGIN
	ALTER TABLE SystemConfigOnboardCarrier ADD RequireBIPDInsurance BIT NOT NULL DEFAULT(0);
END

IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'SystemConfigOnboardCarrier' and column_name = 'RequireCargoInsurance')
BEGIN
	ALTER TABLE SystemConfigOnboardCarrier ADD RequireCargoInsurance BIT NOT NULL DEFAULT(0);
END

IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'SystemConfigOnboardCarrier' and column_name = 'RequireGeneralInsurance')
BEGIN
	ALTER TABLE SystemConfigOnboardCarrier ADD RequireGeneralInsurance BIT NOT NULL DEFAULT(0);
END