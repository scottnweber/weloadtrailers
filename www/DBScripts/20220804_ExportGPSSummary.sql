GO

/****** Object:  View [dbo].[ExportGPSSummary]    Script Date: 04-08-2022 11:13:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER         VIEW [dbo].[ExportGPSSummary]
AS
SELECT 
[dbo].[Companies].[CompanyCode] AS [Company Code],
[dbo].[Companies].[CompanyName] AS [Company Name],
[dbo].[Loads].[LoadNumber] AS [Load #],
MIN([ZGPSTrackingMPWeb].[dbo].[Positions].[ServerTime]) AS [Date Of 1st GPS Record],
MAX([ZGPSTrackingMPWeb].[dbo].[Positions].[ServerTime]) AS [Date Of Last GPS Record],
COUNT(DISTINCT [ZGPSTrackingMPWeb].[dbo].[Positions].[ID]) AS [Number Of GPS Records],
(SELECT TOP 1 [dbo].[LoadStops].[NewDriverCell] FROM [dbo].[LoadStops] WHERE [dbo].[LoadStops].[LoadID] = [dbo].[Loads].[LoadID]) AS [Driver Cell],
ISNULL((SELECT TOP 1 [ZGPSTrackingMPWeb].[dbo].[Positions].[UpdatedByUser] FROM [ZGPSTrackingMPWeb].[dbo].[Positions] WHERE [ZGPSTrackingMPWeb].[dbo].[Positions].[DeviceID]  = [ZGPSTrackingMPWeb].[dbo].[Devices].[ID] AND [ZGPSTrackingMPWeb].[dbo].[Positions].[UpdatedByUser] IS NOT NULL),(SELECT TOP 1 [dbo].[LoadStops].[NewDriverName] FROM [dbo].[LoadStops] WHERE [dbo].[LoadStops].[LoadID] = [dbo].[Loads].[LoadID])) AS [User That Sent GPS Record],
[dbo].[LoadStatusTypes].[StatusDescription] AS [Load Status],
[dbo].[Customers].[CustomerName] AS [Customer Name],
[dbo].[Loads].[CarrierName] AS [Carrier/Driver name],
(SELECT TOP 1 [dbo].[LoadStops].[NewDriverName] FROM [dbo].[LoadStops] WHERE [dbo].[LoadStops].[LoadID] = [dbo].[Loads].[LoadID]) AS [Driver Name]
FROM [dbo].[Companies]
INNER JOIN [dbo].[Offices] ON [dbo].[Offices].[CompanyID] = [dbo].[Companies].[CompanyID]
INNER JOIN [dbo].[CustomerOffices] ON [dbo].[CustomerOffices].[OfficeID] = [dbo].[Offices].[OfficeID]
INNER JOIN [dbo].[Customers] ON [dbo].[Customers].[CustomerID] = [dbo].[CustomerOffices].[CustomerID]
INNER JOIN [dbo].[Loads] ON [dbo].[Loads].[CustomerID] = [dbo].[Customers].[CustomerID]
INNER JOIN [dbo].[LoadStatusTypes] ON [dbo].[LoadStatusTypes].[StatusTypeID] = [dbo].[Loads].[StatusTypeID]
INNER JOIN  [ZGPSTrackingMPWeb].[dbo].[Devices] ON [ZGPSTrackingMPWeb].[dbo].[Devices].[UniqueID] = [dbo].[Loads].[GPSDeviceID] 
INNER JOIN  [ZGPSTrackingMPWeb].[dbo].[Positions] ON [ZGPSTrackingMPWeb].[dbo].[Positions].[DeviceID] = [ZGPSTrackingMPWeb].[dbo].[Devices].[ID] 
WHERE [ZGPSTrackingMPWeb].[dbo].[Positions].[GPSSource] = 'Mobile'
GROUP BY [dbo].[Companies].[CompanyCode],[dbo].[Loads].[LoadID],[dbo].[Loads].[LoadNumber],[dbo].[LoadStatusTypes].[StatusDescription],[dbo].[Customers].[CustomerName],[dbo].[Loads].[CarrierName],[ZGPSTrackingMPWeb].[dbo].[Devices].[ID],[dbo].[Companies].[CompanyName] 

GO


