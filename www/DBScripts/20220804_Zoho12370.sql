GO

/****** Object:  StoredProcedure [dbo].[USP_GetLoadsForCommissionReport]    Script Date: 04-08-2022 10:57:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER             PROCEDURE [dbo].[USP_GetLoadsForCommissionReport] 
	-- Add the parameters for the stored procedure here
	
	@datetype varchar(20),
	@orderDateFrom varchar(10),
	@orderDateTo varchar(10),
	@billDateFrom varchar(10),
	@billDateTo varchar(10),
	@groupsBy varchar(20),
	@groupBy varchar(20),
	@salesAgentFrom VARCHAR(200),
	@salesAgentTo VARCHAR(200),
	@dispatcherFrom VARCHAR(200),
	@dispatcherTo VARCHAR(200),
	@statusTo VARCHAR(200),
	@statusFrom VARCHAR(200),
	@deductionPercentage VARCHAR(200),
	@equipmentFrom VARCHAR(200),
	@equipmentTo VARCHAR(200),
	@officeFrom VARCHAR(200),
	@officeTo VARCHAR(200),
	@carrierFrom VARCHAR(200),
	@carrierTo VARCHAR(200),
	@customerFrom VARCHAR(200),
	@customerTo VARCHAR(200),
	@freightBroker VARCHAR(200),
	@createDateFrom varchar(10),
	@createDateTo varchar(10),
	@companyid VARCHAR(200),
	@deliveryDateFrom varchar(10),
	@deliveryDateTo varchar(10),
	@sortBy varchar(20),
	@SalesRepReport bit,
	@IncludeAllDispatchers bit
AS
BEGIN
	IF @groupsBy = 'none'
		IF @freightBroker ='Driver'
			IF @datetype = 'Shipdate'
				SELECT *,'none' as GrpBy,'none' as SCommissionPercent,0 as SCommissionAmt FROM vwSalesRepCommission
				WHERE orderdate BETWEEN @orderDateFrom AND @orderDateTo
				AND userDefinedFieldTrucking BETWEEN @salesAgentFrom AND @salesAgentTo
				AND ((Dispatcher BETWEEN @dispatcherFrom AND @dispatcherTo)  
					OR (Dispatcher2 BETWEEN @dispatcherFrom AND @dispatcherTo AND @IncludeAllDispatchers = 1)
					OR (Dispatcher3 BETWEEN @dispatcherFrom AND @dispatcherTo AND @IncludeAllDispatchers = 1))
				AND statusText >= @statusTo
				AND statusText <= @statusFrom
				AND EquiptName >= @equipmentFrom
				AND EquiptName <= @equipmentTo
				AND OfficeCode >= @officeFrom AND OfficeCode <= @officeTo
				AND Carrier >= @carrierFrom
				AND Carrier <= @carrierTo
				AND trim(CustName) BETWEEN @customerFrom AND @customerTo
				AND CompanyID = @companyid
				ORDER BY	
					CASE WHEN @sortBy = 'LoadNumber' THEN LoadNumber END ASC,
					CASE WHEN @sortBy = 'date' THEN orderdate END  ASC,sortfield
					
			ELSE IF @datetype = 'Deliverydate'
				SELECT *,'none' as GrpBy,'none' as SCommissionPercent,0 as SCommissionAmt FROM vwSalesRepCommission
				WHERE Deliverydate BETWEEN @deliveryDateFrom AND @deliveryDateTo
				AND userDefinedFieldTrucking BETWEEN @salesAgentFrom AND @salesAgentTo
				AND ((Dispatcher BETWEEN @dispatcherFrom AND @dispatcherTo)  
					OR (Dispatcher2 BETWEEN @dispatcherFrom AND @dispatcherTo AND @IncludeAllDispatchers = 1)
					OR (Dispatcher3 BETWEEN @dispatcherFrom AND @dispatcherTo AND @IncludeAllDispatchers = 1))
				AND statusText >= @statusTo
				AND statusText <= @statusFrom
				AND EquiptName >= @equipmentFrom
				AND EquiptName <= @equipmentTo
				AND OfficeCode >= @officeFrom AND OfficeCode <= @officeTo
				AND Carrier >= @carrierFrom
				AND Carrier <= @carrierTo
				AND trim(CustName) BETWEEN @customerFrom AND @customerTo
				AND CompanyID = @companyid
				ORDER BY	
					CASE WHEN @sortBy = 'LoadNumber' THEN LoadNumber END ASC,
					CASE WHEN @sortBy = 'date' THEN DeliveryDate END  ASC
			ELSE IF @datetype = 'Createdate'
				SELECT *,'none' as GrpBy,'none' as SCommissionPercent,0 as SCommissionAmt FROM vwSalesRepCommission
				WHERE CAST(CreatedDateTime as date) BETWEEN @createDateFrom AND @createDateTo
				AND userDefinedFieldTrucking BETWEEN @salesAgentFrom AND @salesAgentTo
				AND ((Dispatcher BETWEEN @dispatcherFrom AND @dispatcherTo)  
					OR (Dispatcher2 BETWEEN @dispatcherFrom AND @dispatcherTo AND @IncludeAllDispatchers = 1)
					OR (Dispatcher3 BETWEEN @dispatcherFrom AND @dispatcherTo AND @IncludeAllDispatchers = 1))
				AND statusText >= @statusTo
				AND statusText <= @statusFrom
				AND EquiptName >= @equipmentFrom
				AND EquiptName <= @equipmentTo
				AND OfficeCode >= @officeFrom AND OfficeCode <= @officeTo
				AND Carrier >= @carrierFrom
				AND Carrier <= @carrierTo
				AND trim(CustName) BETWEEN @customerFrom AND @customerTo
				AND CompanyID = @companyid
				ORDER BY	
					CASE WHEN @sortBy = 'LoadNumber' THEN LoadNumber END ASC,
					CASE WHEN @sortBy = 'date' THEN CreatedDateTime END  ASC
			ELSE 
				SELECT *,'none' as GrpBy,'none' as SCommissionPercent,0 as SCommissionAmt FROM vwSalesRepCommission
				WHERE billdate BETWEEN @billDateFrom AND @billDateTo
				AND userDefinedFieldTrucking BETWEEN @salesAgentFrom AND @salesAgentTo
				AND ((Dispatcher BETWEEN @dispatcherFrom AND @dispatcherTo)  
					OR (Dispatcher2 BETWEEN @dispatcherFrom AND @dispatcherTo AND @IncludeAllDispatchers = 1)
					OR (Dispatcher3 BETWEEN @dispatcherFrom AND @dispatcherTo AND @IncludeAllDispatchers = 1))

				AND statusText >= @statusTo
				AND statusText <= @statusFrom
				AND EquiptName >= @equipmentFrom
				AND EquiptName <= @equipmentTo
				AND OfficeCode >= @officeFrom AND OfficeCode <= @officeTo
				AND Carrier >= @carrierFrom
				AND Carrier <= @carrierTo
				AND trim(CustName) BETWEEN @customerFrom AND @customerTo
				AND CompanyID = @companyid
				ORDER BY	
					CASE WHEN @sortBy = 'LoadNumber' THEN LoadNumber END ASC,
					CASE WHEN @sortBy = 'date' THEN billdate END  ASC
		ELSE
			IF @datetype = 'Shipdate'
				SELECT *,'none' as GrpBy,'none' as SCommissionPercent,0 as SCommissionAmt FROM vwSalesRepCommission
				WHERE orderdate BETWEEN @orderDateFrom AND @orderDateTo

				AND (
					(@SalesRepReport = 1 
						AND (SalesAgent = @salesAgentFrom OR SalesAgent2 = @salesAgentFrom OR SalesAgent2 = @salesAgentFrom 
							OR Dispatcher = @dispatcherFrom OR Dispatcher2 = @dispatcherFrom OR Dispatcher3 = @dispatcherFrom)
					) 
					OR 
					(@SalesRepReport = 0 
						AND SalesAgent BETWEEN @salesAgentFrom AND @salesAgentTo
						AND ((Dispatcher BETWEEN @dispatcherFrom AND @dispatcherTo)  
							OR (Dispatcher2 BETWEEN @dispatcherFrom AND @dispatcherTo AND @IncludeAllDispatchers = 1)
							OR (Dispatcher3 BETWEEN @dispatcherFrom AND @dispatcherTo AND @IncludeAllDispatchers = 1))
					)
				)

				AND statusText >= @statusTo
				AND statusText <= @statusFrom
				AND EquiptName >= @equipmentFrom
				AND EquiptName <= @equipmentTo
				AND OfficeCode >= @officeFrom AND OfficeCode <= @officeTo
				AND Carrier >= @carrierFrom
				AND Carrier <= @carrierTo
				AND trim(CustName) BETWEEN @customerFrom AND @customerTo
				AND CompanyID = @companyid
				ORDER BY	
					CASE WHEN @sortBy = 'LoadNumber' THEN LoadNumber END ASC,
					CASE WHEN @sortBy = 'date' THEN orderdate END  ASC
			ELSE IF @datetype = 'Deliverydate'
				SELECT *,'none' as GrpBy,'none' as SCommissionPercent,0 as SCommissionAmt FROM vwSalesRepCommission
				WHERE Deliverydate BETWEEN @DeliverydateFrom AND @DeliverydateTo
				AND (
					(@SalesRepReport = 1 
						AND (SalesAgent = @salesAgentFrom OR SalesAgent2 = @salesAgentFrom OR SalesAgent2 = @salesAgentFrom 
							OR Dispatcher = @dispatcherFrom OR Dispatcher2 = @dispatcherFrom OR Dispatcher3 = @dispatcherFrom)
					) 
					OR 
					(@SalesRepReport = 0 
						AND SalesAgent BETWEEN @salesAgentFrom AND @salesAgentTo
						AND ((Dispatcher BETWEEN @dispatcherFrom AND @dispatcherTo)  
							OR (Dispatcher2 BETWEEN @dispatcherFrom AND @dispatcherTo AND @IncludeAllDispatchers = 1)
							OR (Dispatcher3 BETWEEN @dispatcherFrom AND @dispatcherTo AND @IncludeAllDispatchers = 1))
					)
				)
				AND statusText >= @statusTo
				AND statusText <= @statusFrom
				AND EquiptName >= @equipmentFrom
				AND EquiptName <= @equipmentTo
				AND OfficeCode >= @officeFrom AND OfficeCode <= @officeTo
				AND Carrier >= @carrierFrom
				AND Carrier <= @carrierTo
				AND trim(CustName) BETWEEN @customerFrom AND @customerTo
				AND CompanyID = @companyid
				ORDER BY	
					CASE WHEN @sortBy = 'LoadNumber' THEN LoadNumber END ASC,
					CASE WHEN @sortBy = 'date' THEN DeliveryDate END  ASC
			ELSE IF @datetype = 'Createdate'
				SELECT *,'none' as GrpBy,'none' as SCommissionPercent,0 as SCommissionAmt FROM vwSalesRepCommission
				WHERE CAST(CreatedDateTime as date) BETWEEN @createDateFrom AND @createDateTo
				AND (
					(@SalesRepReport = 1 
						AND (SalesAgent = @salesAgentFrom OR SalesAgent2 = @salesAgentFrom OR SalesAgent2 = @salesAgentFrom 
							OR Dispatcher = @dispatcherFrom OR Dispatcher2 = @dispatcherFrom OR Dispatcher3 = @dispatcherFrom)
					) 
					OR 
					(@SalesRepReport = 0 
						AND SalesAgent BETWEEN @salesAgentFrom AND @salesAgentTo
						AND ((Dispatcher BETWEEN @dispatcherFrom AND @dispatcherTo)  
							OR (Dispatcher2 BETWEEN @dispatcherFrom AND @dispatcherTo AND @IncludeAllDispatchers = 1)
							OR (Dispatcher3 BETWEEN @dispatcherFrom AND @dispatcherTo AND @IncludeAllDispatchers = 1))
					)
				)
				AND statusText >= @statusTo
				AND statusText <= @statusFrom
				AND EquiptName >= @equipmentFrom
				AND EquiptName <= @equipmentTo
				AND OfficeCode >= @officeFrom AND OfficeCode <= @officeTo
				AND Carrier >= @carrierFrom
				AND Carrier <= @carrierTo
				AND trim(CustName) BETWEEN @customerFrom AND @customerTo
				AND CompanyID = @companyid
				ORDER BY	
					CASE WHEN @sortBy = 'LoadNumber' THEN LoadNumber END ASC,
					CASE WHEN @sortBy = 'date' THEN CreatedDateTime END  ASC
			ELSE	
				SELECT *,'none' as GrpBy,'none' as SCommissionPercent,0 as SCommissionAmt FROM vwSalesRepCommission
				WHERE billdate BETWEEN @billDateFrom AND @billDateTo
				AND (
					(@SalesRepReport = 1 
						AND (SalesAgent = @salesAgentFrom OR SalesAgent2 = @salesAgentFrom OR SalesAgent2 = @salesAgentFrom 
							OR Dispatcher = @dispatcherFrom OR Dispatcher2 = @dispatcherFrom OR Dispatcher3 = @dispatcherFrom)
					) 
					OR 
					(@SalesRepReport = 0 
						AND SalesAgent BETWEEN @salesAgentFrom AND @salesAgentTo
						AND ((Dispatcher BETWEEN @dispatcherFrom AND @dispatcherTo)  
							OR (Dispatcher2 BETWEEN @dispatcherFrom AND @dispatcherTo AND @IncludeAllDispatchers = 1)
							OR (Dispatcher3 BETWEEN @dispatcherFrom AND @dispatcherTo AND @IncludeAllDispatchers = 1))
					)
				)
				AND statusText >= @statusTo
				AND statusText <= @statusFrom
				AND EquiptName >= @equipmentFrom
				AND EquiptName <= @equipmentTo
				AND OfficeCode >= @officeFrom AND OfficeCode <= @officeTo
				AND Carrier >= @carrierFrom
				AND Carrier <= @carrierTo
				AND trim(CustName) BETWEEN @customerFrom AND @customerTo
				AND CompanyID = @companyid
				ORDER BY	
					CASE WHEN @sortBy = 'LoadNumber' THEN LoadNumber END ASC,
					CASE WHEN @sortBy = 'date' THEN billdate END  ASC		
	Else	
		IF @freightBroker ='Driver'
			IF @datetype = 'Shipdate'
				SELECT *, 
				CASE 
					WHEN @groupsBy = 'userDefinedFieldTrucking' THEN userDefinedFieldTrucking 
				ELSE 
					CASE 
						WHEN @groupsBy = 'DISPATCHER' THEN DISPATCHER
					ELSE
						CASE 
							WHEN @groupsBy = 'CUSTOMERNAME' THEN CustName
						ElSE	
							CASE 
								WHEN @groupsBy = 'Carrier' THEN Carrier
							ELSE
								Driver
							END
						END
					END		
				END 
				AS GrpBy, 
				CASE WHEN @groupsBy = 'DISPATCHER' THEN DispatchCommissionPercent ELSE CommissionPercent END  AS SCommissionPercent,
				CASE WHEN @groupsBy = 'DISPATCHER' THEN DispatchCommissionAmt ELSE CommissionAmt END  AS SCommissionAmt
				FROM vwSalesRepCommission
				WHERE orderdate BETWEEN @orderDateFrom AND @orderDateTo
				AND userDefinedFieldTrucking BETWEEN @salesAgentFrom AND @salesAgentTo
				AND ((Dispatcher BETWEEN @dispatcherFrom AND @dispatcherTo)  
					OR (Dispatcher2 BETWEEN @dispatcherFrom AND @dispatcherTo AND @IncludeAllDispatchers = 1)
					OR (Dispatcher3 BETWEEN @dispatcherFrom AND @dispatcherTo AND @IncludeAllDispatchers = 1))
				AND statusText >= @statusTo
				AND statusText <= @statusFrom
				AND EquiptName >= @equipmentFrom
				AND EquiptName <= @equipmentTo
				AND OfficeCode >= @officeFrom AND OfficeCode <= @officeTo
				AND Carrier >= @carrierFrom
				AND Carrier <= @carrierTo
				AND trim(CustName) BETWEEN @customerFrom AND @customerTo
				AND CompanyID = @companyid
				ORDER BY
				CASE WHEN @groupBy = 'userDefinedFieldTrucking' 
					THEN userDefinedFieldTrucking END ASC, 
				CASE WHEN @groupBy = 'dispatcher'
					THEN Dispatcher END ASC,
				CASE WHEN @groupBy = 'Carrier'
					THEN Carrier END ASC,
				CASE WHEN @groupBy = 'Driver'
					THEN Driver END ASC,	
				CASE WHEN @groupBy = 'CustName'
					THEN CustName END ASC,			
				CASE WHEN @sortBy = 'LoadNumber'
				     THEN LoadNumber END ASC,
				CASE WHEN @sortBy = 'Date'
				     THEN orderdate END ASC
			ELSE IF @datetype = 'Deliverydate'
				SELECT *, 
				CASE 
					WHEN @groupsBy = 'userDefinedFieldTrucking' THEN userDefinedFieldTrucking 
				ELSE 
					CASE 
						WHEN @groupsBy = 'DISPATCHER' THEN DISPATCHER
					ELSE
						CASE 
							WHEN @groupsBy = 'CUSTOMERNAME' THEN CustName
						ElSE	
							CASE 
								WHEN @groupsBy = 'Carrier' THEN Carrier
							ELSE
								Driver
							END
						END
					END		
				END 
				AS GrpBy, 
				CASE WHEN @groupsBy = 'DISPATCHER' THEN DispatchCommissionPercent ELSE CommissionPercent END  AS SCommissionPercent,
				CASE WHEN @groupsBy = 'DISPATCHER' THEN DispatchCommissionAmt ELSE CommissionAmt END  AS SCommissionAmt
				FROM vwSalesRepCommission
				WHERE Deliverydate BETWEEN @DeliverydateFrom AND @DeliverydateTo
				AND userDefinedFieldTrucking BETWEEN @salesAgentFrom AND @salesAgentTo
				AND ((Dispatcher BETWEEN @dispatcherFrom AND @dispatcherTo)  
					OR (Dispatcher2 BETWEEN @dispatcherFrom AND @dispatcherTo AND @IncludeAllDispatchers = 1)
					OR (Dispatcher3 BETWEEN @dispatcherFrom AND @dispatcherTo AND @IncludeAllDispatchers = 1))
				AND statusText >= @statusTo
				AND statusText <= @statusFrom
				AND EquiptName >= @equipmentFrom
				AND EquiptName <= @equipmentTo
				AND OfficeCode >= @officeFrom AND OfficeCode <= @officeTo
				AND Carrier >= @carrierFrom
				AND Carrier <= @carrierTo
				AND trim(CustName) BETWEEN @customerFrom AND @customerTo
				AND CompanyID = @companyid
				ORDER BY
				CASE WHEN @groupBy = 'userDefinedFieldTrucking' 
					THEN userDefinedFieldTrucking END ASC, 
				CASE WHEN @groupBy = 'dispatcher'
					THEN Dispatcher END ASC,
				CASE WHEN @groupBy = 'Carrier'
					THEN Carrier END ASC,
				CASE WHEN @groupBy = 'Driver'
					THEN Driver END ASC,	
				CASE WHEN @groupBy = 'CustName'
					THEN CustName END ASC,			
				CASE WHEN @sortBy = 'LoadNumber'
				     THEN LoadNumber END ASC,
				CASE WHEN @sortBy = 'Date'
				     THEN Deliverydate END ASC
			ELSE IF @datetype = 'Createdate'
				SELECT *, 
				CASE 
					WHEN @groupsBy = 'userDefinedFieldTrucking' THEN userDefinedFieldTrucking 
				ELSE 
					CASE 
						WHEN @groupsBy = 'DISPATCHER' THEN DISPATCHER
					ELSE
						CASE 
							WHEN @groupsBy = 'CUSTOMERNAME' THEN CustName
						ElSE	
							CASE 
								WHEN @groupsBy = 'Carrier' THEN Carrier
							ELSE
								Driver
							END
						END
					END		
				END 
				AS GrpBy, 
				CASE WHEN @groupsBy = 'DISPATCHER' THEN DispatchCommissionPercent ELSE CommissionPercent END  AS SCommissionPercent,
				CASE WHEN @groupsBy = 'DISPATCHER' THEN DispatchCommissionAmt ELSE CommissionAmt END  AS SCommissionAmt
				FROM vwSalesRepCommission
				WHERE CAST(CreatedDateTime as date) BETWEEN @createDateFrom AND @createDateTo
				AND userDefinedFieldTrucking BETWEEN @salesAgentFrom AND @salesAgentTo
				AND ((Dispatcher BETWEEN @dispatcherFrom AND @dispatcherTo)  
					OR (Dispatcher2 BETWEEN @dispatcherFrom AND @dispatcherTo AND @IncludeAllDispatchers = 1)
					OR (Dispatcher3 BETWEEN @dispatcherFrom AND @dispatcherTo AND @IncludeAllDispatchers = 1))
				AND statusText >= @statusTo
				AND statusText <= @statusFrom
				AND EquiptName >= @equipmentFrom
				AND EquiptName <= @equipmentTo
				AND OfficeCode >= @officeFrom AND OfficeCode <= @officeTo
				AND Carrier >= @carrierFrom
				AND Carrier <= @carrierTo
				AND trim(CustName) BETWEEN @customerFrom AND @customerTo
				AND CompanyID = @companyid
				ORDER BY
				CASE WHEN @groupBy = 'userDefinedFieldTrucking' 
					THEN userDefinedFieldTrucking END ASC, 
				CASE WHEN @groupBy = 'dispatcher'
					THEN Dispatcher END ASC,
				CASE WHEN @groupBy = 'Carrier'
					THEN Carrier END ASC,
				CASE WHEN @groupBy = 'Driver'
					THEN Driver END ASC,	
				CASE WHEN @groupBy = 'CustName'
					THEN CustName END ASC,			
				CASE WHEN @sortBy = 'LoadNumber'
				     THEN LoadNumber END ASC,
				CASE WHEN @sortBy = 'Date'
				     THEN CreatedDateTime END ASC
			ELSE
				SELECT *, 
				CASE 
					WHEN @groupsBy = 'userDefinedFieldTrucking' THEN userDefinedFieldTrucking 
				ELSE 
					CASE 
						WHEN @groupsBy = 'DISPATCHER' THEN DISPATCHER
					ELSE
						CASE 
							WHEN @groupsBy = 'CUSTOMERNAME' THEN CustName
						ElSE	
							CASE 
								WHEN @groupsBy = 'Carrier' THEN Carrier
							ELSE
								Driver
							END
						END
					END		
				END 
				AS GrpBy, 
				CASE WHEN @groupsBy = 'DISPATCHER' THEN DispatchCommissionPercent ELSE CommissionPercent END  AS SCommissionPercent,
				CASE WHEN @groupsBy = 'DISPATCHER' THEN DispatchCommissionAmt ELSE CommissionAmt END  AS SCommissionAmt
				FROM vwSalesRepCommission
				WHERE billdate BETWEEN @billDateFrom AND @billDateTo
				AND userDefinedFieldTrucking BETWEEN @salesAgentFrom AND @salesAgentTo
				AND ((Dispatcher BETWEEN @dispatcherFrom AND @dispatcherTo)  
					OR (Dispatcher2 BETWEEN @dispatcherFrom AND @dispatcherTo AND @IncludeAllDispatchers = 1)
					OR (Dispatcher3 BETWEEN @dispatcherFrom AND @dispatcherTo AND @IncludeAllDispatchers = 1))
				AND statusText >= @statusTo
				AND statusText <= @statusFrom
				AND EquiptName >= @equipmentFrom
				AND EquiptName <= @equipmentTo
				AND OfficeCode >= @officeFrom AND OfficeCode <= @officeTo
				AND Carrier >= @carrierFrom
				AND Carrier <= @carrierTo
				AND trim(CustName) BETWEEN @customerFrom AND @customerTo
				AND CompanyID = @companyid
				ORDER BY
				CASE WHEN @groupBy = 'userDefinedFieldTrucking' 
					THEN userDefinedFieldTrucking END ASC, 
				CASE WHEN @groupBy = 'dispatcher'
					THEN Dispatcher END ASC,
				CASE WHEN @groupBy = 'Carrier'
					THEN Carrier END ASC,
				CASE WHEN @groupBy = 'Driver'
					THEN Driver END ASC,	
				CASE WHEN @groupBy = 'CustName'
					THEN CustName END ASC,			
				CASE WHEN @sortBy = 'LoadNumber'
				     THEN LoadNumber END ASC,
				CASE WHEN @sortBy = 'Date'
				     THEN billdate END ASC
		ELSE
			IF @datetype = 'Shipdate'
					SELECT *, 
				CASE 
					WHEN @groupsBy = 'SALESAGENT' THEN SALESAGENT 
				ELSE 
					CASE 
						WHEN @groupsBy = 'DISPATCHER' THEN DISPATCHER
					ELSE
						CASE 
							WHEN @groupsBy = 'CUSTOMERNAME' THEN CustName
						ElSE	
							CASE 
								WHEN @groupsBy = 'Carrier' THEN Carrier
							ELSE
								Driver
							END
						END
					END		
				END 
				AS GrpBy, 
				CASE WHEN @groupsBy = 'DISPATCHER' THEN DispatchCommissionPercent ELSE CommissionPercent END  AS SCommissionPercent,
				CASE WHEN @groupsBy = 'DISPATCHER' THEN DispatchCommissionAmt ELSE CommissionAmt END  AS SCommissionAmt
				FROM vwSalesRepCommission
				WHERE orderdate BETWEEN @orderDateFrom AND @orderDateTo
				AND (
					(@SalesRepReport = 1 
						AND (SalesAgent = @salesAgentFrom OR SalesAgent2 = @salesAgentFrom OR SalesAgent2 = @salesAgentFrom 
							OR Dispatcher = @dispatcherFrom OR Dispatcher2 = @dispatcherFrom OR Dispatcher3 = @dispatcherFrom)
					) 
					OR 
					(@SalesRepReport = 0 
						AND SalesAgent BETWEEN @salesAgentFrom AND @salesAgentTo
						AND ((Dispatcher BETWEEN @dispatcherFrom AND @dispatcherTo)  
							OR (Dispatcher2 BETWEEN @dispatcherFrom AND @dispatcherTo AND @IncludeAllDispatchers = 1)
							OR (Dispatcher3 BETWEEN @dispatcherFrom AND @dispatcherTo AND @IncludeAllDispatchers = 1))
					)
				)
				AND statusText >= @statusTo
				AND statusText <= @statusFrom
				AND EquiptName >= @equipmentFrom
				AND EquiptName <= @equipmentTo
				AND OfficeCode >= @officeFrom AND OfficeCode <= @officeTo
				AND Carrier >= @carrierFrom
				AND Carrier <= @carrierTo
				AND trim(CustName) BETWEEN @customerFrom AND @customerTo
				AND CompanyID = @companyid
				ORDER BY
				CASE WHEN @groupBy = 'sales Agent' 
					THEN SalesAgent END ASC, 
				CASE WHEN @groupBy = 'dispatcher'
					THEN Dispatcher END ASC,
				CASE WHEN @groupBy = 'Carrier'
					THEN Carrier END ASC,
				CASE WHEN @groupBy = 'Driver'
					THEN Driver END ASC,	
				CASE WHEN @groupBy = 'CustName'
					THEN CustName END ASC,			
				CASE WHEN @sortBy = 'LoadNumber'
				     THEN LoadNumber END ASC,
				CASE WHEN @sortBy = 'Date'
				     THEN orderdate END ASC
			ELSE IF @datetype = 'Deliverydate'
					SELECT *, 
				CASE 
					WHEN @groupsBy = 'SALESAGENT' THEN SALESAGENT 
				ELSE 
					CASE 
						WHEN @groupsBy = 'DISPATCHER' THEN DISPATCHER
					ELSE
						CASE 
							WHEN @groupsBy = 'CUSTOMERNAME' THEN CustName
						ElSE	
							CASE 
								WHEN @groupsBy = 'Carrier' THEN Carrier
							ELSE
								Driver
							END
						END
					END		
				END 
				AS GrpBy, 
				CASE WHEN @groupsBy = 'DISPATCHER' THEN DispatchCommissionPercent ELSE CommissionPercent END  AS SCommissionPercent,
				CASE WHEN @groupsBy = 'DISPATCHER' THEN DispatchCommissionAmt ELSE CommissionAmt END  AS SCommissionAmt
				FROM vwSalesRepCommission
				WHERE Deliverydate BETWEEN @DeliverydateFrom AND @DeliverydateTo
				AND (
					(@SalesRepReport = 1 
						AND (SalesAgent = @salesAgentFrom OR SalesAgent2 = @salesAgentFrom OR SalesAgent2 = @salesAgentFrom 
							OR Dispatcher = @dispatcherFrom OR Dispatcher2 = @dispatcherFrom OR Dispatcher3 = @dispatcherFrom)
					) 
					OR 
					(@SalesRepReport = 0 
						AND SalesAgent BETWEEN @salesAgentFrom AND @salesAgentTo
						AND ((Dispatcher BETWEEN @dispatcherFrom AND @dispatcherTo)  
							OR (Dispatcher2 BETWEEN @dispatcherFrom AND @dispatcherTo AND @IncludeAllDispatchers = 1)
							OR (Dispatcher3 BETWEEN @dispatcherFrom AND @dispatcherTo AND @IncludeAllDispatchers = 1))
					)
				)
				AND statusText >= @statusTo
				AND statusText <= @statusFrom
				AND EquiptName >= @equipmentFrom
				AND EquiptName <= @equipmentTo
				AND OfficeCode >= @officeFrom AND OfficeCode <= @officeTo
				AND Carrier >= @carrierFrom
				AND Carrier <= @carrierTo
				AND trim(CustName) BETWEEN @customerFrom AND @customerTo
				AND CompanyID = @companyid
				ORDER BY
				CASE WHEN @groupBy = 'sales Agent' 
					THEN SalesAgent END ASC, 
				CASE WHEN @groupBy = 'dispatcher'
					THEN Dispatcher END ASC,
				CASE WHEN @groupBy = 'Carrier'
					THEN Carrier END ASC,
				CASE WHEN @groupBy = 'Driver'
					THEN Driver END ASC,	
				CASE WHEN @groupBy = 'CustName'
					THEN CustName END ASC,			
				CASE WHEN @sortBy = 'LoadNumber'
				     THEN LoadNumber END ASC,
				CASE WHEN @sortBy = 'Date'
				     THEN Deliverydate END ASC
			ELSE IF @datetype = 'Createdate'
					SELECT *, 
				CASE 
					WHEN @groupsBy = 'SALESAGENT' THEN SALESAGENT 
				ELSE 
					CASE 
						WHEN @groupsBy = 'DISPATCHER' THEN DISPATCHER
					ELSE
						CASE 
							WHEN @groupsBy = 'CUSTOMERNAME' THEN CustName
						ElSE	
							CASE 
								WHEN @groupsBy = 'Carrier' THEN Carrier
							ELSE
								Driver
							END
						END
					END		
				END 
				AS GrpBy, 
				CASE WHEN @groupsBy = 'DISPATCHER' THEN DispatchCommissionPercent ELSE CommissionPercent END  AS SCommissionPercent,
				CASE WHEN @groupsBy = 'DISPATCHER' THEN DispatchCommissionAmt ELSE CommissionAmt END  AS SCommissionAmt
				FROM vwSalesRepCommission
				WHERE CAST(CreatedDateTime as date) BETWEEN @createDateFrom AND @createDateTo
				AND (
					(@SalesRepReport = 1 
						AND (SalesAgent = @salesAgentFrom OR SalesAgent2 = @salesAgentFrom OR SalesAgent2 = @salesAgentFrom 
							OR Dispatcher = @dispatcherFrom OR Dispatcher2 = @dispatcherFrom OR Dispatcher3 = @dispatcherFrom)
					) 
					OR 
					(@SalesRepReport = 0 
						AND SalesAgent BETWEEN @salesAgentFrom AND @salesAgentTo
						AND ((Dispatcher BETWEEN @dispatcherFrom AND @dispatcherTo)  
							OR (Dispatcher2 BETWEEN @dispatcherFrom AND @dispatcherTo AND @IncludeAllDispatchers = 1)
							OR (Dispatcher3 BETWEEN @dispatcherFrom AND @dispatcherTo AND @IncludeAllDispatchers = 1))
					)
				)
				AND statusText >= @statusTo
				AND statusText <= @statusFrom
				AND EquiptName >= @equipmentFrom
				AND EquiptName <= @equipmentTo
				AND OfficeCode >= @officeFrom AND OfficeCode <= @officeTo
				AND Carrier >= @carrierFrom
				AND Carrier <= @carrierTo
				AND trim(CustName) BETWEEN @customerFrom AND @customerTo
				AND CompanyID = @companyid
				ORDER BY
				CASE WHEN @groupBy = 'sales Agent' 
					THEN SalesAgent END ASC, 
				CASE WHEN @groupBy = 'dispatcher'
					THEN Dispatcher END ASC,
				CASE WHEN @groupBy = 'Carrier'
					THEN Carrier END ASC,
				CASE WHEN @groupBy = 'Driver'
					THEN Driver END ASC,	
				CASE WHEN @groupBy = 'CustName'
					THEN CustName END ASC,			
				CASE WHEN @sortBy = 'LoadNumber'
				     THEN LoadNumber END ASC,
				CASE WHEN @sortBy = 'Date'
				     THEN CreatedDateTime END ASC
			ELSE
				SELECT *, 
				CASE 
					WHEN @groupsBy = 'SALESAGENT' THEN SALESAGENT 
				ELSE 
					CASE 
						WHEN @groupsBy = 'DISPATCHER' THEN DISPATCHER
					ELSE
						CASE 
							WHEN @groupsBy = 'CUSTOMERNAME' THEN CustName
						ElSE	
							CASE 
								WHEN @groupsBy = 'Carrier' THEN Carrier
							ELSE
								Driver
							END
						END
					END		
				END 
				AS GrpBy, 
				CASE WHEN @groupsBy = 'DISPATCHER' THEN DispatchCommissionPercent ELSE CommissionPercent END  AS SCommissionPercent,
				CASE WHEN @groupsBy = 'DISPATCHER' THEN DispatchCommissionAmt ELSE CommissionAmt END  AS SCommissionAmt
				FROM vwSalesRepCommission
				WHERE billdate BETWEEN @billDateFrom AND @billDateTo
				AND (
					(@SalesRepReport = 1 
						AND (SalesAgent = @salesAgentFrom OR SalesAgent2 = @salesAgentFrom OR SalesAgent2 = @salesAgentFrom 
							OR Dispatcher = @dispatcherFrom OR Dispatcher2 = @dispatcherFrom OR Dispatcher3 = @dispatcherFrom)
					) 
					OR 
					(@SalesRepReport = 0 
						AND SalesAgent BETWEEN @salesAgentFrom AND @salesAgentTo
						AND ((Dispatcher BETWEEN @dispatcherFrom AND @dispatcherTo)  
							OR (Dispatcher2 BETWEEN @dispatcherFrom AND @dispatcherTo AND @IncludeAllDispatchers = 1)
							OR (Dispatcher3 BETWEEN @dispatcherFrom AND @dispatcherTo AND @IncludeAllDispatchers = 1))
					)
				)
				AND statusText >= @statusTo
				AND statusText <= @statusFrom
				AND EquiptName >= @equipmentFrom
				AND EquiptName <= @equipmentTo
				AND OfficeCode >= @officeFrom AND OfficeCode <= @officeTo
				AND Carrier >= @carrierFrom
				AND Carrier <= @carrierTo
				AND trim(CustName) BETWEEN @customerFrom AND @customerTo
				AND CompanyID = @companyid
				ORDER BY
				CASE WHEN @groupBy = 'sales Agent' 
					THEN SalesAgent END ASC, 
				CASE WHEN @groupBy = 'dispatcher'
					THEN Dispatcher END ASC,
				CASE WHEN @groupBy = 'Carrier'
					THEN Carrier END ASC,
				CASE WHEN @groupBy = 'Driver'
					THEN Driver END ASC,	
				CASE WHEN @groupBy = 'CustName'
					THEN CustName END ASC,			
				CASE WHEN @sortBy = 'LoadNumber'
				     THEN LoadNumber END ASC,
				CASE WHEN @sortBy = 'Date'
				     THEN billdate END ASC
END





GO


