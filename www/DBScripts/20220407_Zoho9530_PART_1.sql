IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'SystemConfig' and column_name = 'StatusUpdateMailType')
BEGIN
	ALTER TABLE SystemConfig ADD StatusUpdateMailType int not null default 0;
END