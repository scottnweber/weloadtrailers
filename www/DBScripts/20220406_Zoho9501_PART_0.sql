UPDATE SystemConfig SET DefaultLoadEmailtext = 'Hi,
New Update for Load# {LoadNumber}:
{Map}

Status: {LoadStatus}
PO#: {PONumber}

{StopDetails}

{EmailSignature}'

WHERE DefaultLoadEmailtext LIKE 'Hi,
New Update for Load# {LoadNumber}:
{Map}

Status: {LoadStatus}

{StopDetails}

{EmailSignature}' OR DefaultLoadEmailtext IS NULL


UPDATE SystemConfig SET DefaultLoadEmailSubject = 'Status Update' WHERE DefaultLoadEmailSubject IS NULL


GO

/****** Object:  StoredProcedure [dbo].[SchTask_LocationUpdates]    Script Date: 06-04-2022 13:02:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER   PROC [dbo].[SchTask_LocationUpdates]
AS
BEGIN
	SELECT 
	L.LoadID
	,L.LoadNumber
	,L.ContactEmail
	,E.EmailID AS SalesRepEmail
	,E1.EmailID AS DispatcherEmail
	,L.EmailList
	,'https://loadmanager.biz/loadmanagerlive/www/webroot/index.cfm?event=Googlemap&LoadID='+CAST(L.LoadID AS VARCHAR(36)) AS MapLink
	,LS.StopNo
	,LS.LoadType
	,L.StatusTypeID
	,LST.StatusText
	,LST.StatusDescription
	,L.LoadStatusStopNo
	,LS.CustName
	,LS.Address
	,LS.City
	,LS.StateCode
	,LS.PostalCode
	,LS.ContactPerson
	,LS.Phone
	,S.DefaultLoadEmailSubject
	,S.DefaultLoadEmailtext
	,C.ccOnEmails
	,C.email AS CCMail
	,S.DefaultLoadEmails
	,L.CustomerPONo
	FROM Loads L
	INNER JOIN LoadStatusTypes LST ON LST.StatusTypeID = L.StatusTypeID AND LST.SendEmailForLoads = 1
	INNER JOIN LoadStops LS ON LS.LoadID = L.LoadID
	LEFT JOIN Employees E ON E.EmployeeID = L.SalesRepID
	LEFT JOIN Employees E1 ON E1.EmployeeID = L.DispatcherID
	INNER JOIN SystemConfig S ON S.CompanyID = LST.CompanyID
	INNER JOIN Companies C ON C.CompanyID = S.CompanyID
	WHERE 
	(SELECT COUNT(P.ID) FROM [ZGPSTrackingMPWeb].[dbo].[Positions] P WHERE P.LoadID = L.LoadID AND P.GPSSource = 'Mobile') <> 0
	AND ((LST.SendUpdateOneTime = 0)  OR 
		(LST.SendUpdateOneTime = 1   
			AND ((L.StatusTypeID <> L.LastLocationUpdateStatus)  OR (L.StatusTypeID = L.LastLocationUpdateStatus AND L.LoadStatusStopNo <> ISNULL(L.LastLocationUpdateStopType,'')))))

	ORDER BY L.LoadID,LS.StopNo,LS.LoadType
END
GO


