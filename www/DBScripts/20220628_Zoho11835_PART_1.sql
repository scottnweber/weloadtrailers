IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'Carriers' and column_name = 'ApplyInsuranceToAll')
BEGIN
	ALTER TABLE Carriers ADD ApplyInsuranceToAll bit not null default 0;
END

IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'SystemConfigOnboardCarrier' and column_name = 'RequireVoidedCheck')
BEGIN
	ALTER TABLE SystemConfigOnboardCarrier ADD RequireVoidedCheck bit not null default 0;
END