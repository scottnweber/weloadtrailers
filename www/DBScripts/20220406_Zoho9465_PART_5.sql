IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'SystemConfig' and column_name = 'IncludeCarrierRate')
BEGIN
	ALTER TABLE SystemConfig ADD IncludeCarrierRate bit not null default 0;
END