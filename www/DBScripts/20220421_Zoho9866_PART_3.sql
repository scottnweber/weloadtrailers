IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'SecurityParameter' and column_name = 'Type')
BEGIN
	ALTER TABLE SecurityParameter ADD Type varchar(150);
END


UPDATE SecurityParameter SET Type = 'Carrier' WHERE Parameter IN ('addCarrier','UnlockCarrier','CarrierOnboardingVerifier')
UPDATE SecurityParameter SET Type = 'Load' WHERE Parameter IN ('DeleteLoad','Editable Status','editLoad','HideCustomerPricing','HideFinancialRates','EditLockedLoad','UnlockLoad')
UPDATE SecurityParameter SET Type = 'Driver' WHERE Parameter IN ('editDrivers','UnlockDriver')
UPDATE SecurityParameter SET Type = 'Customer' WHERE Parameter IN ('changeCustomerActiveStatus','UnlockCustomer')
UPDATE SecurityParameter SET Type = 'User' WHERE Parameter IN ('UnlockAgent')
UPDATE SecurityParameter SET Type = 'Equipment' WHERE Parameter IN ('UnlockEquipment')
UPDATE SecurityParameter SET Type = 'Reports' WHERE Parameter IN ('runReports','runExport','SalesRepReport')
UPDATE SecurityParameter SET Type = 'Settings' WHERE Parameter IN ('EditSystemLoadStatus','modifySystemSetup')