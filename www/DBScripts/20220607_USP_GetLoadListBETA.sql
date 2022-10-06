GO

/****** Object:  StoredProcedure [dbo].[USP_GetLoadListBETA]    Script Date: 07-06-2022 10:22:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROC [dbo].[USP_GetLoadListBETA]
(
@CompanyID varchar(36),
@pageNo varchar(10),
@sortBy varchar(150),
@sortOrder varchar(10),
@pageSize varchar(10),
@currentusertype varchar(50),
@empID varchar(50),
@showAllOfficeLoads bit,
@officeID varchar(36),
@CustomerID varchar(36),
@LoadStatus varchar(150),
@LoadNumber varchar(150),
@CustomerPO varchar(150),
@shipperCity varchar(150),
@consigneeCity varchar(150),
@ShipperState varchar(max),
@ConsigneeState varchar(max),
@CustomerName varchar(150),
@StartDate date,
@EndDate date,
@BillDate date,
@CarrierName varchar(150),
@bol varchar(150),
@dispatcher varchar(150),
@agent varchar(150),
@searchText varchar(150),
@exactMatchSearch bit,
@agentUsername varchar(150),
@Office varchar(50),
@orderdateAdv date,
@invoicedateAdv date,
@internalRefAdv varchar(150),
@userDefinedForTruckingAdv varchar(255),
@EquipmentAdv varchar(max),
@pending bit = 0,
@UserLoadStatusTypeID varchar(max) = NULL,
@showloadtypestatusonloadsscreen bit,
@LoadsDaysFilter int
)
AS
BEGIN
	DECLARE @sql AS varchar(max);
	SET @sql = '';
	IF(SELECT LoadsColumnsSetting from SystemConfig WHERE CompanyID = @CompanyID) = 1
		BEGIN
			IF(@pageNo <> - 1)
			BEGIN
				SET @sql=@sql+'WITH page AS ('
			END
			SET @sql=@sql+'SELECT
					l.LoadNumber,
					l.LoadID,
					l.TruckNo As c,
					l.TrailorNo As vv,
					l.CarrierInvoiceNumber,
					STUFF(
						(SELECT '','' + NewTrailorNo FROM loadstops where loadid=l.loadid AND  LoadType=1  AND NewTrailorNo != ''''   FOR XML PATH ('''')), 1, 1, ''''
					) AS TrailorNo,
					STUFF(
						(SELECT '','' + NewTruckNo FROM loadstops where loadid=l.loadid AND  LoadType=1  AND NewTruckNo != ''''  FOR XML PATH ('''')), 1, 1, ''''
					) AS TruckNo,
					L.CarrierName AS DriverName,
					l.NewDispatchNotes AS  DispatchNotes,
					l.NewDeliveryTime AS DelTime,
					l.NewDeliveryDate,
					l.BillDate,
					l.CustName AS Customer,
					DriverName AS Driver,
					(SELECT TOP 1 LS.custName FROM LoadStops LS WHERE LS.LoadID = L.LoadID ORDER BY LS.StopNo,LS.LoadType)  AS Shipper, 
					statusTypeID,
					statustext,
					case when Isnull(ForceNextStatus,0) = 0 then (select top 1 count(ForceNextStatus) from LoadStatusTypes LS
					where ForceNextStatus =1 and loadStatus.StatusText > LS.StatusText ) else IsNull(ForceNextStatus,0) end as ForceNextStatus,
					CustCurrency.CurrencyNameISO as CustomerCurrencyISO,
					CarrCurrency.CurrencyNameISO as CarrierCurrencyISO,
					L.CustName,
					(SELECT  TOP 1 DESCRIPTION
						FROM LoadStopCommodities
						WHERE LoadStopID IN (SELECT
						LoadStopID
						FROM loADSTOPS
						WHERE LoadID = l.LoadID
						)
						AND DESCRIPTION != ''''
						ORDER BY SrNo)  AS COMMODITY,

					(SELECT TOP 1 custName

					FROM loadstops
					WHERE LoadID = l.LoadID

					AND LoadStopID IN (SELECT
						TOP 1 LoadStopID
						FROM loadstops
						WHERE LoadID = l.LoadID
						AND LoadType = 2 AND ISNULL(custName,'''') != ''''
						ORDER BY stopNo DESC)  ) 		AS CONSIGNEE,
					ROW_NUMBER() OVER (ORDER BY
				' + @sortby + ' ' + @sortOrder + '  ,l.LoadNumber ) AS Row
				FROM LOADS l  WITH (NOLOCK)
				INNER JOIN (SELECT
						    customerid
							FROM CustomerOffices c1 INNER JOIN offices o1 ON o1.officeid = c1.OfficeID
							WHERE o1.CompanyID = '''+@CompanyID+''''

				IF((@currentusertype = 'sales representative' OR @currentusertype = 'dispatcher' OR @currentusertype = 'manager') AND  ISNULL(LEN(@officeID),0) <> 0 )
				BEGIN
					SET @sql=@sql+' AND o1.officeid = '''+@officeID+''''
				END

				IF(ISNULL(LEN(@Office),0) <> 0 )
				BEGIN
					SET @sql=@sql+' AND o1.officeid = '''+@Office+''''
				END

				SET @sql=@sql+'	group by customerid) Offices ON Offices.CustomerID = l.CustomerID
								LEFT OUTER JOIN (SELECT
										[StatusTypeID] AS stTypeId,
										[statusText],
										colorCode
										FROM [loadStatusTypes]) AS loadStatus    ON loadStatus.stTypeId = l.StatusTypeID
								LEFT OUTER JOIN (SELECT
										[StatusTypeID] AS lststType,
										[StatusText] AS lStatusText,
										[ForceNextStatus] AS ForceNextStatus
										FROM [LoadStatusTypes]) AS LStatusTypes    ON LStatusTypes.lststType = l.StatusTypeID
								LEFT OUTER JOIN (SELECT
										[Name] AS empDispatch,
										[EmployeeID]
										FROM [Employees]) AS Employees    ON Employees.EmployeeID = l.DispatcherID
								LEFT OUTER JOIN Currencies CustCurrency on CustCurrency.CurrencyID = CustomerCurrency
								LEFT OUTER JOIN Currencies CarrCurrency on CarrCurrency.CurrencyID = CarrierCurrency
								where l.LoadID = l.LoadID'
				IF(ISNULL(LEN(@CustomerID),0) <> 0)
				BEGIN
					SET @sql=@sql+' AND L.CustomerID = '''+@CustomerID+''''
				END

				IF(ISNULL(LEN(@LoadStatus),0) <> 0)
				BEGIN
					SET @sql=@sql+' AND L.StatusTypeID = '''+@LoadStatus+''''
				END

				IF(ISNULL(LEN(@LoadNumber),0) <> 0)
				BEGIN
					SET @sql=@sql+' AND L.LoadNumber = '''+@LoadNumber+''''
				END

				IF(ISNULL(LEN(@CustomerPO),0) <> 0)
				BEGIN
					SET @sql=@sql+' AND L.CustomerPONo LIKE ''%'+@CustomerPO+'%'''
				END

				IF(ISNULL(LEN(@shipperCity),0) <> 0)
				BEGIN
					SET @sql=@sql+' AND L.shipperCity LIKE ''%'+@shipperCity+'%'''
				END

				IF(ISNULL(LEN(@consigneeCity),0) <> 0)
				BEGIN
					SET @sql=@sql+' AND L.consigneeCity LIKE ''%'+@consigneeCity+'%'''
				END

				IF(ISNULL(LEN(@ShipperState),0) <> 0)
				BEGIN
					SET @sql=@sql+' AND L.shipperState = '''+@ShipperState+''''
				END

				IF(ISNULL(LEN(@ConsigneeState),0) <> 0)
				BEGIN
					SET @sql=@sql+' AND L.ConsigneeState = '''+@ConsigneeState+''''
				END

				IF(ISNULL(LEN(@CustomerName),0) <> 0)
				BEGIN
					SET @sql=@sql+' AND L.custname LIKE ''%'+@CustomerName+'%'''
				END

				IF(ISNULL(LEN(@StartDate),0) <> 0)
				BEGIN
					SET @sql=@sql+' AND L.NewPickupDate >= '''+CAST(@StartDate AS VARCHAR(30))+''''
				END

				IF(ISNULL(LEN(@EndDate),0) <> 0)
				BEGIN
					SET @sql=@sql+' AND L.NewPickupDate <= '''+CAST(@EndDate AS VARCHAR(30))+''''
				END
				IF(ISNULL(LEN(@BillDate),0) <> 0)
				BEGIN
					SET @sql=@sql+' AND L.BillDate = '''+CAST(@BillDate AS VARCHAR(30))+''''
				END
				IF(ISNULL(LEN(@CarrierName),0) <> 0)
				BEGIN
					SET @sql=@sql+' AND L.CarrierName LIKE ''%'+@CarrierName+'%'''
				END

				IF(ISNULL(LEN(@bol),0) <> 0)
				BEGIN
					SET @sql=@sql+' AND L.BOLNum LIKE ''%'+@bol+'%'''
				END

				IF(ISNULL(LEN(@dispatcher),0) <> 0)
				BEGIN
					SET @sql=@sql+' AND empDispatch LIKE ''%'+@dispatcher+'%'''
				END
			
				IF(ISNULL(LEN(@agent),0) <> 0)
				BEGIN
					SET @sql=@sql+' AND L.SalesAgent LIKE ''%'+@agent+'%'''
				END

				IF(ISNULL(LEN(@searchText),0) <> 0)
				BEGIN
					IF(@exactMatchSearch <> 1)
					BEGIN
						SET @searchText = '%'+@searchText+'%'
					END
				
					SET @sql=@sql+' AND (l.CarrierName like '''+@searchText+'''
								 		   or l.LoadDriverName like '''+@searchText+'''
								 		   or statusText like '''+@searchText+'''
										   or LoadNumber like '''+@searchText+'''
								 		   or CustomerPONo like '''+@searchText+'''
								 		   or l.shipperState like '''+@searchText+'''
								 		   or l.shipperCity like '''+@searchText+'''
								 		   or l.consigneeState like '''+@searchText+'''
								 		   or l.consigneeCity like '''+@searchText+'''
										   or BOLNum like '''+@searchText+'''
										   or empDispatch like '''+@searchText+'''
										   or l.SalesAgent like '''+@searchText+'''
										   or l.custName like '''+@searchText+'''
										   or l.InternalRef like '''+@searchText+'''
										   OR l.LoadID IN (select LoadID from loadstops where userDef1 LIKE ''123''
											OR userDef2 LIKE '''+@searchText+'''
												OR userDef3 LIKE '''+@searchText+'''
											OR userDef4 LIKE '''+@searchText+'''
											OR userDef5 LIKE '''+@searchText+'''
											OR userDef6 LIKE '''+@searchText+'''
											OR userDefinedFieldTrucking LIKE '''+@searchText+'''
											)
											or (SELECT TOP 1
											DESCRIPTION
											FROM LoadStopCommodities
											WHERE LoadStopID IN (SELECT TOP 1
											LoadStopID
											FROM loADSTOPS
											WHERE LoadID = l.LoadID
											AND StopNo = 0))  			like '''+@searchText+'''

											or (SELECT TOP 1
											CustName
											FROM loadstops
											WHERE LoadID = l.LoadID
											AND StopNo = 0
											AND LoadStopID IN (SELECT
											MAX(LoadStopID)
											FROM loadstops
											WHERE LoadID = l.LoadID
											AND StopNo = 0))   		like '''+@searchText+''')'
				END


				IF(ISNULL(LEN(@agentUsername),0) <> 0)
				BEGIN
					SET @sql=@sql+' AND StatusTypeID IN (
									SELECT loadStatusTypeID
									FROM AgentsLoadTypes'

					IF(ISNULL(LEN(@empID),0) <> 0)
					BEGIN
						SET @sql=@sql+'WHERE AgentID = '''+@empID+''''
					END
					ELSE
					BEGIN
						SET @sql=@sql+'WHERE AgentID = (
											SELECT EmployeeID
											FROM Employees
											WHERE loginid = '''+@agentUsername+'''
										)'
					END

					SET @sql=@sql+')'

				END

				IF(@pageNo <> - 1)
				BEGIN
					SET @sql=@sql+')
						 SELECT * FROM page WHERE Row between ('+@pageNo+' - 1) * '+@pageSize+' + 1 and '+@pageNo+' * '+@pageSize+'  order by row';
				END
		END
	ELSE
		BEGIN
			IF(@pageNo <> - 1)
			BEGIN
				SET @sql=@sql+'WITH page AS ('
			END
			SET @sql=@sql+'SELECT 
	      			L.LoadID
					,L.LoadNumber
					,ISNULL(L.ARExported,''0'') AS ARExportedNN 
					,ISNULL(L.APExported,''0'') AS APExportedNN
					,ISNULL(L.orderDate, '''') AS orderDate
					,L.CarrierInvoiceNumber
					,L.CustomerPONo
					,L.StatusTypeID
					,LST.statusText 
					,LST.StatusDescription
					,LST.StatusOrder
					,CASE WHEN COUNT(FLST.StatusTypeID) <> 0 THEN 1 ELSE 0 END AS ForceNextStatus
					,LST.ColorCode
					,L.CustomerID AS PayerID
					,L.TotalCustomerCharges 
					,ISNULL(L.CarrierName,L.LoadDriverName) AS CarrierName
					,ISNULL(L.DeadHeadMiles,0) AS DeadHeadMiles
					,L.NewPickupDate as PickupDate
					,L.NewDeliveryDate as DeliveryDate 
					,L.NewPickupTime as PickUpTime
					,L.NewDeliveryTime as DeliveryTime
					,L.BillDate
					,L.TotalCarrierCharges
					,E.Name AS EmpDispatch
					,L.SalesAgent as EmpAgent
					,L.userDefinedFieldTrucking
					,L.EquipmentName
					,L.DriverName
					,L.TotalMiles as Miles 
					,CustCurrency.CurrencyNameISO as CustomerCurrencyISO
					,CarrCurrency.CurrencyNameISO as CarrierCurrencyISO
					,L.CustName
					,L.CarrierID
					,L.InternalRef
					,Eq.EquipmentType AS EquipmentType
					,REq.EquipmentName AS RelEquip
					,LST.TextColorCode
					,CASE WHEN LST.ShowStopOnLoadStatus = 1 THEN REPLACE(REPLACE(L.LoadStatusStopNo,''S'',''P''),''C'',''D'') ELSE NULL END AS LoadStatusStopNo
					,ROW_NUMBER() OVER (ORDER BY ' + @sortby + ' ' + @sortOrder + '  ,L.LoadNumber) AS Row
					FROM Loads L WITH (NOLOCK)
					INNER JOIN CustomerOffices CO ON CO.CustomerID = L.CustomerID
					INNER JOIN Offices O ON O.OfficeID = CO.OfficeID
					LEFT JOIN LoadStatusTypes LST ON LST.StatusTypeID = L.StatusTypeID
					LEFT JOIN LoadStatusTypes FLST ON FLST.StatusOrder <= LST.StatusOrder AND ISNULL(FLST.ForceNextStatus,0) = 1
					LEFT JOIN Employees E ON E.EmployeeID = L.DispatcherID
					LEFT JOIN Currencies CustCurrency on CustCurrency.CurrencyID = L.CustomerCurrency
					LEFT JOIN Currencies CarrCurrency on CarrCurrency.CurrencyID = L.CarrierCurrency
					LEFT JOIN Equipments Eq on Eq.EquipmentID = L.EquipmentID
					LEFT  JOIN Equipments REq on REq.EquipmentID = Eq.TruckTrailerOption'
			
			SET @sql=@sql+' WHERE LST.IsActive = 1 AND O.CompanyID = '''+@CompanyID+''''

			IF((@currentusertype = 'sales representative' OR @currentusertype = 'dispatcher' OR @currentusertype = 'manager') AND  ISNULL(LEN(@officeID),0) <> 0 )
			BEGIN
				SET @sql=@sql+' AND O.OfficeID = '''+@officeID+''''
			END

			IF(ISNULL(LEN(@Office),0) <> 0 )
			BEGIN
				SET @sql=@sql+' AND O.OfficeID = '''+@Office+''''
			END

			IF(@currentusertype = 'sales representative' AND ISNULL(LEN(@empID),0) <> 0 AND @showAllOfficeLoads = 0)
			BEGIN
				SET @sql=@sql+' AND (SalesRepID='''+@empID+''' or L.DispatcherID = '''+@empID+''')'
			END

			IF(ISNULL(LEN(@CustomerID),0) <> 0)
			BEGIN
				SET @sql=@sql+' AND L.CustomerID = '''+@CustomerID+''''
			END

			IF(ISNULL(LEN(@LoadStatus),0) <> 0)
			BEGIN
				SET @sql=@sql+' AND L.StatusTypeID = '''+@LoadStatus+''''
			END

			IF(ISNULL(LEN(@LoadNumber),0) <> 0)
			BEGIN
				SET @sql=@sql+' AND L.LoadNumber = '''+@LoadNumber+''''
			END

			IF(ISNULL(LEN(@CustomerPO),0) <> 0)
			BEGIN
				SET @sql=@sql+' AND L.CustomerPONo LIKE ''%'+@CustomerPO+'%'''
			END

			IF(ISNULL(LEN(@shipperCity),0) <> 0)
			BEGIN
				SET @sql=@sql+' AND L.shipperCity LIKE ''%'+@shipperCity+'%'''
			END

			IF(ISNULL(LEN(@consigneeCity),0) <> 0)
			BEGIN
				SET @sql=@sql+' AND L.consigneeCity LIKE ''%'+@consigneeCity+'%'''
			END

			IF(ISNULL(LEN(@ShipperState),0) <> 0)
			BEGIN
				SET @sql=@sql+' AND L.shipperState IN ('+@ShipperState+')'
			END

			IF(ISNULL(LEN(@ConsigneeState),0) <> 0)
			BEGIN
				SET @sql=@sql+' AND L.ConsigneeState IN ('+@ConsigneeState+')'
			END

			IF(ISNULL(LEN(@CustomerName),0) <> 0)
			BEGIN
				SET @sql=@sql+' AND L.custname LIKE ''%'+@CustomerName+'%'''
			END

			IF(ISNULL(LEN(@StartDate),0) <> 0)
			BEGIN
				SET @sql=@sql+' AND L.NewPickupDate >= '''+CAST(@StartDate AS VARCHAR(30))+''''
			END

			IF(ISNULL(LEN(@EndDate),0) <> 0)
			BEGIN
				SET @sql=@sql+' AND L.NewPickupDate <= '''+CAST(@EndDate AS VARCHAR(30))+''''
			END
			IF(ISNULL(LEN(@BillDate),0) <> 0)
			BEGIN
				SET @sql=@sql+' AND L.BillDate = '''+CAST(@BillDate AS VARCHAR(30))+''''
			END
			IF(ISNULL(LEN(@orderdateAdv),0) <> 0)
			BEGIN
				SET @sql=@sql+' AND L.OrderDate = '''+CAST(@orderdateAdv  AS VARCHAR(30))+''''
			END

			IF(ISNULL(LEN(@invoicedateAdv),0) <> 0)
			BEGIN
				SET @sql=@sql+' AND L.BillDate = '''+CAST(@invoicedateAdv  AS VARCHAR(30))+''''
			END

			IF(ISNULL(LEN(@CarrierName),0) <> 0)
			BEGIN
				SET @sql=@sql+' AND L.CarrierName LIKE ''%'+@CarrierName+'%'''
			END

			IF(ISNULL(LEN(@bol),0) <> 0)
			BEGIN
				SET @sql=@sql+' AND L.BOLNum LIKE ''%'+@bol+'%'''
			END

			IF(ISNULL(LEN(@dispatcher),0) <> 0)
			BEGIN
				SET @sql=@sql+' AND E.Name LIKE ''%'+@dispatcher+'%'''
			END
			
			IF(ISNULL(LEN(@agent),0) <> 0)
			BEGIN
				SET @sql=@sql+' AND L.SalesAgent LIKE ''%'+@agent+'%'''
			END

			IF(ISNULL(LEN(@internalRefAdv),0) <> 0)
			BEGIN
				SET @sql=@sql+' AND L.InternalRef LIKE ''%'+@internalRefAdv+'%'''
			END

			IF(ISNULL(LEN(@userDefinedForTruckingAdv),0) <> 0)
			BEGIN
				SET @sql=@sql+' AND L.userDefinedFieldTrucking LIKE ''%'+@userDefinedForTruckingAdv+'%'''
			END

			IF(ISNULL(LEN(@EquipmentAdv),0) <> 0)
			BEGIN
				SET @sql=@sql+' AND L.EquipmentID IN ('+@EquipmentAdv+')'
			END

			IF(ISNULL(@LoadsDaysFilter,0) <> 0)
			BEGIN
				SET @sql=@sql+' AND DATEDIFF(Day, L.CreatedDateTime, getdate()) <= '+CAST(@LoadsDaysFilter AS varchar(50))
			END

			IF(@pending=1)
			BEGIN
				SET @sql=@sql+' AND LST.StatusDescription IN (''ACTIVE'',''BOOKED'') AND  (select count(Att.AttachmentTypeID) from FileAttachmentTypes Att where Att.CompanyID = '''+@CompanyID+''' AND Att.AttachmentType = ''Load'' and Att.Required = 1 
				and  Att.AttachmentTypeID not in (select MFA.AttachmentTypeID from FileAttachments FA
				inner join MultipleFileAttachmentsTypes MFA ON FA.attachment_Id = MFA.AttachmentID
				where FA.linked_Id=CAST(L.LoadID as varchar(36))) 
				) > 0'
			END

			IF(ISNULL(LEN(@searchText),0) <> 0)
			BEGIN
				IF(@exactMatchSearch <> 1)
				BEGIN
					SET @searchText = '%'+@searchText+'%'
				END
				
				SET @sql=@sql+' AND (l.CarrierName like '''+@searchText+'''
								 	   or l.LoadDriverName like '''+@searchText+'''
								 	   or LST.statusText like '''+@searchText+'''
									   or LoadNumber like '''+@searchText+'''
								 	   or CustomerPONo like '''+@searchText+'''
								 	   or l.shipperState like '''+@searchText+'''
								 	   or l.shipperCity like '''+@searchText+'''
								 	   or l.consigneeState like '''+@searchText+'''
								 	   or l.consigneeCity like '''+@searchText+'''
									   or BOLNum like '''+@searchText+'''
									   or E.Name like '''+@searchText+'''
									   or l.SalesAgent like '''+@searchText+'''
									   or l.InternalRef like '''+@searchText+'''
									   OR userDefinedFieldTrucking LIKE '''+@searchText+'''
									   OR CONVERT(varchar, NewPickupDate, 101) LIKE '''+@searchText+'''
									   OR CONVERT(varchar, NewDeliveryDate, 101) LIKE '''+@searchText+'''
									   OR CONVERT(varchar,BillDate,101) LIKE '''+@searchText+'''
									   or l.custName like '''+@searchText+''')'
			END

			IF(ISNULL(LEN(@UserLoadStatusTypeID),0) <> 0)
			BEGIN
				SET @sql=@sql+' AND L.StatusTypeID IN ('+@UserLoadStatusTypeID+')'
			END

			/*IF(ISNULL(LEN(@agentUsername),0) <> 0 AND ISNULL(LEN(@CustomerID),0) = 0)
				IF(ISNULL(LEN(@UserLoadStatusTypeID),0) <> 0)

					BEGIN
						SET @sql=@sql+' AND L.StatusTypeID IN ('+@UserLoadStatusTypeID+')'
					END

				ELSE
					BEGIN
						IF(ISNULL(LEN(@empID),0) <> 0)
						BEGIN
							IF(SELECT COUNT(E.EmployeeID) FROM Employees E WHERE E.EmployeeID = @empID)<>0
							BEGIN
								SET @sql=@sql+' AND L.StatusTypeID IN (
										SELECT loadStatusTypeID
										FROM AgentsLoadTypes'
								SET @sql=@sql+' WHERE AgentID = '''+@empID+''''
								SET @sql=@sql+')'
							END
						END
						ELSE
						BEGIN
						SET @sql=@sql+' AND L.StatusTypeID IN (
										SELECT loadStatusTypeID
										FROM AgentsLoadTypes'
							SET @sql=@sql+' WHERE AgentID = (
												SELECT EmployeeID
												FROM Employees
												WHERE loginid = '''+@agentUsername+'''
											)'
							SET @sql=@sql+')'
						END
					END

			IF(ISNULL(LEN(@CustomerID),0) <> 0 AND @showloadtypestatusonloadsscreen =1)
			BEGIN
				IF(ISNULL(LEN(@UserLoadStatusTypeID),0) <> 0)
					BEGIN
						SET @sql=@sql+' AND L.StatusTypeID IN ('+@UserLoadStatusTypeID+')'
					END
				ELSE
					BEGIN
						SET @sql=@sql+' AND L.StatusTypeID IN (
								SELECT loadStatusTypeID
								FROM AgentsLoadTypes WHERE agentid = '''+@CustomerID+''' )'
					END
			END*/

			SET @sql=@sql+'GROUP BY 
				L.LoadID
				,L.LoadNumber
				,L.ARExported
				,L.APExported
				,L.orderDate
				,L.CarrierInvoiceNumber
				,L.CustomerPONo
				,L.StatusTypeID
				,LST.statusText 
				,LST.StatusDescription
				,LST.StatusOrder
				,LST.ColorCode
				,L.CustomerID
				,L.TotalCustomerCharges 
				,L.CarrierName
				,L.LoadDriverName
				,L.DeadHeadMiles
				,L.NewPickupDate
				,L.NewDeliveryDate
				,L.NewPickupTime
				,L.NewDeliveryTime
				,L.BillDate
				,L.TotalCarrierCharges
				,E.Name
				,L.SalesAgent
				,L.userDefinedFieldTrucking
				,L.EquipmentName
				,L.DriverName
				,L.TotalMiles
				,CustCurrency.CurrencyNameISO
				,CarrCurrency.CurrencyNameISO
				,L.CustName
				,L.CarrierID
				,L.InternalRef
				,Eq.EquipmentType
				,REq.EquipmentName 
				,LST.TextColorCode
				,LST.ShowStopOnLoadStatus
				,L.LoadStatusStopNo
				,L.ShipperCity
				,L.ShipperState
				,L.ConsigneeCity
				,L.ConsigneeState'

			IF(@pageNo <> - 1)
			BEGIN
				SET @sql=@sql+')
	                 SELECT *,(select (max(row)/'+@PageSize+') + (CASE WHEN max(row)%'+@PageSize+' <> 0 THEN 1 ELSE 0 END)  FROM page) AS TotalPages FROM page WHERE Row between ('+@pageNo+' - 1) * '+@pageSize+' + 1 and '+@pageNo+' * '+@pageSize+'  order by row';
			END

		END
	EXEC(@sql);
END


GO


