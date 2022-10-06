IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'LMA Accounts Receivable Payment Detail' and column_name = 'VoidedBy')
BEGIN
	ALTER TABLE [LMA Accounts Receivable Payment Detail] ADD VoidedBy varchar(150);
END

IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'LMA Accounts Receivable Payment Detail' and column_name = 'VoidedOn')
BEGIN
	ALTER TABLE [LMA Accounts Receivable Payment Detail] ADD VoidedOn datetime;
END