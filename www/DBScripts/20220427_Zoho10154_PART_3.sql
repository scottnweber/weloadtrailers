IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'Systemconfig' and column_name = 'LowVolumePlan')
BEGIN
	ALTER TABLE Systemconfig ADD LowVolumePlan BIT NOT NULL DEFAULT(0);
END