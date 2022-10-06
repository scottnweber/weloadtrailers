IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'SystemConfig' and column_name = 'ShowAllOfficeCustomers')
BEGIN
	ALTER TABLE SystemConfig ADD ShowAllOfficeCustomers bit not null default 0;
END