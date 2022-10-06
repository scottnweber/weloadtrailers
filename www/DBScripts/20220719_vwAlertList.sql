GO

/****** Object:  View [dbo].[vwAlertList]    Script Date: 19-07-2022 10:44:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER    VIEW [dbo].[vwAlertList]
AS
SELECT 
				A.AlertID,
				Claim.Name AS ClaimedBy,
				A.Type,
				A.Reference,
				Description,
				A.CreatedDateTime,
				Created.Name AS CreatedBy,
				E.Name AS OpenTo,
				E.EmployeeID,
				A.CompanyID,
				A.Approved,
				C.CarrierName
				FROM Employees E 
				INNER JOIN Alerts A ON A.AssignedTo = E.EmployeeID AND A.AssignedType='User'
				LEFT JOIN Employees Claim ON Claim.EmployeeID = A.ClaimedByUserID
				LEFT JOIN Employees Created ON Created.EmployeeID = A.CreatedBy
				LEFT JOIN Carriers C ON C.CarrierID = A.TypeID
			UNION
			SELECT 
				A.AlertID,
				Claim.Name AS ClaimedBy,
				A.Type,
				A.Reference,
				Description,
				A.CreatedDateTime,
				Created.Name AS CreatedBy,
				R.RoleValue AS OpenTo,
				E.EmployeeID,
				A.CompanyID,
				A.Approved,
				C.CarrierName
				FROM Employees E 
				INNER JOIN Alerts A ON A.AssignedTo = E.RoleID AND A.AssignedType='Role'
				INNER JOIN Roles R ON R.RoleID = A.AssignedTo
				LEFT JOIN Employees Claim ON Claim.EmployeeID = A.ClaimedByUserID
				LEFT JOIN Employees Created ON Created.EmployeeID = A.CreatedBy
				LEFT JOIN Carriers C ON C.CarrierID = A.TypeID
			UNION
			SELECT 
				A.AlertID,
				Claim.Name AS ClaimedBy,
				A.Type,
				A.Reference,
				Description,
				A.CreatedDateTime,
				Created.Name AS CreatedBy,
				R.RoleValue AS OpenTo,
				E.EmployeeID,
				A.CompanyID,
				A.Approved,
				C.CarrierName
				FROM Employees E 
				INNER JOIN Roles R ON R.RoleID = E.RoleID 
				INNER JOIN Alerts A ON A.AssignedType='Parameter' AND R.userRights LIKE '%'+AssignedTo+'%'
				LEFT JOIN Employees Claim ON Claim.EmployeeID = A.ClaimedByUserID
				LEFT JOIN Employees Created ON Created.EmployeeID = A.CreatedBy
				LEFT JOIN Carriers C ON C.CarrierID = A.TypeID
GO


