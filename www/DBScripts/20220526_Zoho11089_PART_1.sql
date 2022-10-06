GO

/****** Object:  View [dbo].[vwCompanyLoads]    Script Date: 26-05-2022 13:26:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [dbo].[vwCompanyLoads]  AS  

SELECT O.CompanyID,L.LoadID,L.TotalCustomerCharges,L.TotalCarrierCharges,(L.TotalCustomerCharges-L.TotalCarrierCharges) AS Profit
FROM Loads L
INNER JOIN CustomerOffices CO ON CO.CustomerID = L.CustomerID
INNER JOIN Offices O ON O.OfficeID = CO.OfficeID
WHERE DATEDIFF(day, L.CreatedDateTime, getdate()) <=30
GROUP BY O.CompanyID,L.LoadID,L.TotalCarrierCharges,L.TotalCustomerCharges

GO
IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'Companies' and column_name = 'Contact')
BEGIN
	ALTER TABLE Companies ADD Contact varchar(150);
END
GO
IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'Companies' and column_name = 'LastLoginDate')
BEGIN
	ALTER TABLE Companies ADD LastLoginDate datetime;
END
GO
IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'Companies' and column_name = 'LastLoginName')
BEGIN
	ALTER TABLE Companies ADD LastLoginName varchar(150);
END
GO


GO

/****** Object:  View [dbo].[vwCompanyEmployees]    Script Date: 26-05-2022 13:26:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [dbo].[vwCompanyEmployeeCount]  AS  

SELECT O.CompanyID,COUNT(E.EmployeeID) AS EmployeeCount
FROM Offices O
INNER JOIN Employees E ON E.OfficeID = O.OfficeID
WHERE E.IsActive =1
GROUP BY O.CompanyID

GO

GO

/****** Object:  StoredProcedure [dbo].[SP_GetCompanyActivity]    Script Date: 26-05-2022 15:05:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROC [dbo].[SP_GetCompanyActivity]
AS
BEGIN
	SELECT 
	C.CompanyID,
	C.CompanyCode,
	C.CompanyName,
	SUM(CL.TotalCarrierCharges) AS Cost,
	SUM(CL.TotalCustomerCharges) AS Sales,
	(SUM(CL.TotalCustomerCharges)-SUM(CL.TotalCarrierCharges)) AS GrossProfit,
	CASE WHEN SUM(CL.TotalCustomerCharges) <>0 THEN (SUM(CL.TotalCustomerCharges)-SUM(CL.TotalCarrierCharges))*100 / SUM(CL.TotalCustomerCharges) ELSE 0 END AS Margin,
	COUNT(CL.LoadID) AS LoadCount,
	C.IsActive,
	C.Address,
	C.City,
	C.State,
	C.ZipCode,
	C.Email,
	C.CreatedDateTime,
	C.Phone,
	C.Fax,
	C.LastLoginDate,
	C.LastLoginName,
	CE.EmployeeCount AS Users,
	S.PaymentFailDate,
	S.PaymentGracePeriodDays,
	S.PaymentStatus,
	C.Contact,
	DATEDIFF(hour, C.LastLoginDate, getdate()) AS DaysSinceLastLogin,
	COUNT(TL.TextLogID) AS TextSent
	FROM Companies C
	LEFT JOIN [vwCompanyLoads]  CL ON CL.CompanyID = C.CompanyID
	LEFT JOIN [vwCompanyEmployeeCount] CE ON CE.CompanyID = C.CompanyID
	LEFT JOIN SystemConfig S On S.CompanyID = C.CompanyID
	LEFT JOIN TextLogs TL ON TL.LoadID = CL.LoadID
	GROUP BY
	C.CompanyID,
	C.CompanyCode,
	C.CompanyName,
	C.IsActive,
	C.Address,
	C.City,
	C.State,
	C.ZipCode,
	C.Email,
	C.CreatedDateTime,
	C.Phone,
	C.Fax,
	C.LastLoginDate,
	C.LastLoginName,
	CE.EmployeeCount,
	S.PaymentFailDate,
	S.PaymentGracePeriodDays,
	S.PaymentStatus,
	C.Contact
	ORDER BY LoadCount DESC, CompanyName ASC
END

GO


