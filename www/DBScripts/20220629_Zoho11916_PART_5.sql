IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'UserCountCheck' and column_name = 'CompanyID')
BEGIN
	ALTER TABLE UserCountCheck ADD CompanyID uniqueidentifier;
END
GO

UPDATE U SET
U.CompanyID=O.CompanyID 
FROM UserCountCheck U
LEFT JOIN Employees E ON CAST(E.EmployeeID AS varchar(36)) = U.CUTOMERID
LEFT JOIN Offices O ON O.OfficeID = E.OfficeID

DELETE FROM UserCountCheck WHERE LOGINNAME ='global'