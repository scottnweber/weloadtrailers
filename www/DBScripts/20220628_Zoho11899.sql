IF(SELECT COUNT(ID) FROM SecurityParameter WHERE parameter = 'QuickBooks') = 0
BEGIN
INSERT INTO [SecurityParameter] 
([Category],[Parameter],[Description],[CreatedBy],[ModifiedBy],[Type]) 
VALUES ('Edit','QuickBooks','Allow the user to access QuickBooks Export.','Scott','Scott','Load')
END
GO
IF(SELECT COUNT(ID) FROM SecurityParameter WHERE parameter = 'Accounting') = 0
BEGIN
INSERT INTO [SecurityParameter] 
([Category],[Parameter],[Description],[CreatedBy],[ModifiedBy],[Type]) 
VALUES ('Edit','Accounting','Allow the user to access Accounting.','Scott','Scott','Load')
END
GO
IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'SystemConfig' and column_name = 'QuickBooksIntegration')
BEGIN
	ALTER TABLE SystemConfig ADD QuickBooksIntegration bit not null default 0;
END
GO
IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'SystemConfig' and column_name = 'AccountingIntegration')
BEGIN
	ALTER TABLE SystemConfig ADD AccountingIntegration bit not null default 0;
END
GO

UPDATE S SET 
S.QuickBooksIntegration = (CASE WHEN (SELECT COUNT(R.RoleID) FROM Roles R WHERE R.CompanyID = S.CompanyID AND R.userRights like '%QuickBooks%') <> 0 THEN 1 ELSE 0 END),
S.AccountingIntegration = (CASE WHEN (SELECT COUNT(R.RoleID) FROM Roles R WHERE R.CompanyID = S.CompanyID AND R.userRights like '%Accounting%') <> 0 THEN 1 ELSE 0 END)
FROM SystemConfig S 