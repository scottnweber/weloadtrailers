IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'LoadsConsolidated' and column_name = 'InvoiceDate')
BEGIN
	ALTER TABLE LoadsConsolidated ADD InvoiceDate DateTime;
END
