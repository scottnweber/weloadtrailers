GO

/****** Object:  StoredProcedure [dbo].[USP_GetCarrierDetails]    Script Date: 12-05-2022 12:57:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER             PROC [dbo].[USP_GetCarrierDetails]
(
@carrierID varchar(200),
@CompanyID varchar(50)
)
AS
BEGIN
 	 if @carrierID =  ''
 		SELECT  0 AS RatePrMile, NULL as carrierID, NULL as CarrierName, NULL as Address, NULL as City, NULL as stateCode,
 				NULL as ZipCode,NULL as phone,NULL as cel,NULL as fax,NULL as TollFree,NULL as emailID,0 as MCNumber,0 as DOTNumber, 0 as isShowDollar,0 as IsCarrier, NULL as DefaultCurrency,null as scac, '' as RiskAssessment,0 as loadlimit,1 as CalculateDHMiles  
				,NULL as PhoneExt,NULL as FaxExt,NULL as TollFreeExt,NULL as CellPhoneExt,NULL AS ContactPerson
	 
	 else 
		BEGIN
			SELECT  0 AS RatePrMile,Carriers.*
			
			FROM Carriers WITH (NOLOCK)
			where CarrierID=@carrierID 
		END
END



GO


