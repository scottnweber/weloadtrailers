IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'Carriers' and column_name = 'OBCarrierEmail')
BEGIN
	ALTER TABLE Carriers ADD OBCarrierEmail varchar(150);
END
GO
IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'Carriers' and column_name = 'OBLMEmail')
BEGIN
	ALTER TABLE Carriers ADD OBLMEmail varchar(150);
END
GO
IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'Carriers' and column_name = 'OBLMUserName')
BEGIN
	ALTER TABLE Carriers ADD OBLMUserName varchar(150);
END
GO
IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'Carriers' and column_name = 'OBLMUserID')
BEGIN
	ALTER TABLE Carriers ADD OBLMUserID uniqueidentifier;
END
GO