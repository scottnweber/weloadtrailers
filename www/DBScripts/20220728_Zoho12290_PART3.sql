IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'SystemConfig' and column_name = 'AutomaticCustomerRateChanges')
BEGIN
	ALTER TABLE SystemConfig ADD AutomaticCustomerRateChanges BIT NOT NULL DEFAULT(0);
END
IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'SystemConfig' and column_name = 'AutomaticCarrierRateChanges')
BEGIN
	ALTER TABLE SystemConfig ADD AutomaticCarrierRateChanges BIT NOT NULL DEFAULT(0);
END
