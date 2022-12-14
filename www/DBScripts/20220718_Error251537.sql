
GO
/****** Object:  StoredProcedure [dbo].[USP_UpdateLoadItem]    Script Date: 7/18/2022 1:38:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




--select * from LoadStops

-----------------------------------------------------------------------------------------------------------------------------------
ALTER     proc [dbo].[USP_UpdateLoadItem]
(@LoadStopID varchar(200), 
@SrNo BIGINT,
@Qty DECIMAL(18,2),
@UnitID varchar(200),
@Description VARCHAR(1000),
@Weight float,
@ClassID varchar(200),
@CustRate VARCHAR(100),
@CarrRate VARCHAR(100),
@CustCharges money,
@CarrCharges money,
@CarrRateOfCustTotal decimal(10,2),
@fee bit,
@directCost VARCHAR(100),
@directCostTotal VARCHAR(100),
@Dimensions VARCHAR(150)
)
as
begin

if ltrim(Rtrim(IsNull(@UnitID, ''))) = ''
	set @UnitID = null

if ltrim(Rtrim(IsNull(@ClassID, ''))) = ''
		set @ClassID = null
declare @UnitCount int = 0
set @UnitCount = (select COUNT(UnitID) from Units where UnitID = @UnitID)
-- [SrNo]
-- [Qty]
-- [UnitID]
-- [Description]
-- [Weight]
-- [ClassID]
--[CustRate]
--[CarrRate]
-- [CustCharges]
-- [CarrCharges]
-- [CarrRateOfCustTotal]
update [dbo].[LoadStopCommodities]
set
[Qty]			 =@Qty,
[UnitID]		 = case when (@UnitCount > 0) then @UnitID else NULL end,
[Description]	 =@Description,
[Weight]		 =@Weight,
[ClassID]		 =@ClassID,
[CustRate]	     =@CustRate,
[CarrRate]	     =@CarrRate,
[CustCharges]	 =@CustCharges,
[CarrCharges]	 =@CarrCharges,
fee =			  @fee,
[CarrRateOfCustTotal] =@CarrRateOfCustTotal 
,directCost =@directCost 
,directCostTotal =@directCostTotal
,Dimensions =@Dimensions
where 
LoadStopID      =@LoadStopID and
[SrNo]			 =@SrNo

end


