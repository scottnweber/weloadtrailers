IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'SystemConfig' and column_name = 'UseCondensedReports')
BEGIN
	ALTER TABLE SystemConfig ADD UseCondensedReports bit not null default 1;
END
