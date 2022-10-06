GO

/****** Object:  StoredProcedure [dbo].[USP_GetCarrierList]    Script Date: 27-04-2022 19:35:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE OR ALTER   PROC [dbo].[USP_GetCarrierList]
(
@CompanyID varchar(36),
@PageNo varchar(10),
@SortBy varchar(150),
@SortOrder varchar(10),
@SearchText varchar(150),
@SearchPickUpState varchar(150),
@SearchEquipmentID varchar(150),
@IsCarrier varchar(10),
@Pending bit
)
AS
BEGIN
	DECLARE @sql AS varchar(max);
	SET @sql = 'WITH page AS (';
	
	SET @sql = @sql + 'SELECT 
					   C.CarrierID,
					   C.CarrierName,
					   C.MCNumber,
					   C.City,
					   C.Phone,
					   C.EmailID,
					   C.RiskAssessment,
					   C.DotNumber,
					   C.StateCode,
					   C.Phone AS PhoneNo,
					   C.InsExpDate,
					   C.CDLEXPIRES,
					   C.CRMNextCallDate,
					   C.Status,
					   CAST(C.Notes AS VARCHAR(MAX)) AS Notes,
					   ROW_NUMBER() OVER (ORDER BY UPPER('+@SortBy+') '+@SortOrder+') AS Row
					   FROM Carriers C WITH (NOLOCK)'
	IF(LEN(TRIM(@SearchPickUpState)) <> 0 OR LEN(TRIM(@SearchEquipmentID)) <> 0)
	BEGIN
		SET @sql = @sql + ' LEFT JOIN CarrierLanes CL ON CL.CarrierID = C.CarrierID'
	END

	IF(LEN(TRIM(@SearchEquipmentID)) <> 0)
	BEGIN
		SET @sql = @sql + ' LEFT JOIN CarrierEquipments CE ON CE.CarrierID = C.CarrierID'
	END

	SET @sql = @sql + ' WHERE CompanyID = '''+@CompanyID+''''

	IF(LEN(TRIM(@IsCarrier)) <> 0)
	BEGIN
		SET @sql = @sql + ' AND IsCarrier='+@IsCarrier
	END

	IF(LEN(TRIM(@SearchText)) <> 0)
	BEGIN
		SET @searchText = '%'+@searchText+'%'
		SET @sql = @sql + ' AND
				(C.CarrierName like '''+@SearchText+'''
				or C.MCNumber like '''+@SearchText+'''
				or C.Address like '''+@SearchText+'''
				or C.City like '''+@SearchText+'''
				or C.Zipcode like '''+@SearchText+'''
				or C.Phone like '''+@SearchText+'''
				or C.EmailID like '''+@SearchText+'''
				or C.Website like '''+@SearchText+'''
				or C.StateCode like '''+@SearchText+'''
				or C.DOTNumber like '''+@SearchText+''')'
	END

	IF(LEN(TRIM(@SearchPickUpState)) <> 0)
	BEGIN
		SET @sql = @sql + ' AND (C.StateCode='''+@SearchPickUpState+'''
          OR CL.PickUpState='''+@SearchPickUpState+'''
          OR CL.DeliveryState='''+@SearchPickUpState+''')'
	END

	IF(LEN(TRIM(@SearchEquipmentID)) <> 0)
	BEGIN
		SET @sql = @sql + ' AND (CL.EquipmentID IN ('''+@SearchEquipmentID+''')
          OR CE.EquipmentID IN ('''+@SearchEquipmentID+''')
          )'
	END

	IF(@Pending=1)
	BEGIN
		SET @sql = @sql + 'AND (select count(Att.AttachmentTypeID) from FileAttachmentTypes Att where Att.AttachmentType = '
		
		IF(@IsCarrier=1)
		BEGIN
			SET @sql = @sql + '''Carrier'''
		END
		ELSE
		BEGIN
			SET @sql = @sql + '''Driver'''
		END
		
		
		SET @sql = @sql + 'and Att.CompanyID =  '''+@CompanyID+''' AND Att.Required = 1 and  Att.AttachmentTypeID     
            not in (select MFA.AttachmentTypeID from FileAttachments FA
            inner join MultipleFileAttachmentsTypes MFA ON FA.attachment_Id = MFA.AttachmentID
            where FA.linked_Id=CAST(C.carrierid as varchar(36))) 
            ) > 0'
	END

	SET @sql = @sql + 'GROUP BY
					  C.CarrierID,
					  C.CarrierName,
					  C.MCNumber,
					  C.City,
					  C.Phone,
					  C.EmailID,
					  C.RiskAssessment,
					  C.DotNumber,
					  C.StateCode,
					  C.Phone,
					  C.InsExpDate,
					  C.CDLEXPIRES,
					  C.CRMNextCallDate,
					  C.Status,
					  CAST(C.Notes AS VARCHAR(MAX))'

	SET @sql = @sql + ')'

	SET @sql = @sql + 'SELECT *,(select (max(row)/30) + (CASE WHEN max(row)%30 <> 0 THEN 1 ELSE 0 END)  FROM page) AS TotalPages FROM page WHERE Row between ('+@PageNo+' - 1) * 30 + 1 and '+@PageNo+'*30 ORDER BY Row'

	EXEC(@sql);
END

GO


