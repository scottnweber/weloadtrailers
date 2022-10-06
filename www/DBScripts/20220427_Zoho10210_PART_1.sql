GO

/****** Object:  View [dbo].[vwLoadsTranscore]    Script Date: 28-04-2022 11:45:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[vwLoadsTranscore]
AS
SELECT        TOP (100) PERCENT dbo.Loads.ControlNumber AS ImportRef, dbo.vwLoadStopOrigin.City AS OriginCity, dbo.vwLoadStopOrigin.StateCode AS OriginState, 
                         dbo.vwLoadStopOrigin.PickupDate, dbo.vwCarrierConfirmationReportFinalDestination.City AS DestCity, 
                         dbo.vwCarrierConfirmationReportFinalDestination.StateCode AS DestState, dbo.Loads.IsPartial AS FullOrPartial, ISNULL(dbo.Loads.EquipmentLength,dbo.Equipments.Length) AS Length, 
                         dbo.vwLoadWeight.WeightTotal AS Weight, dbo.vwCarrierConfirmationReportFinalDestination.FinalDelivDate, dbo.Equipments.TranscoreCode AS EquipmentName, 
                         dbo.Loads.NewNotes AS Notes, dbo.Loads.LoadNumber, dbo.Loads.LoadID, dbo.Loads.DATPostedLogin, ISNULL(dbo.Loads.TotalCarrierCharges,0) AS TotalCarrierCharges
FROM            dbo.vwCarrierConfirmationReportFinalDestination INNER JOIN

                         dbo.Loads ON dbo.vwCarrierConfirmationReportFinalDestination.LoadID = dbo.Loads.LoadID INNER JOIN
                         dbo.vwLoadStopOrigin ON dbo.Loads.LoadID = dbo.vwLoadStopOrigin.LoadID INNER JOIN
                         dbo.vwLoadWeight ON dbo.Loads.LoadID = dbo.vwLoadWeight.LoadID LEFT OUTER JOIN
                         dbo.Equipments ON dbo.vwLoadStopOrigin.EquipmentID = dbo.Equipments.EquipmentID

GO


