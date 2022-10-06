GO

/****** Object:  StoredProcedure [dbo].[USP_SearchLoadLogs]    Script Date: 19-05-2022 12:55:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROC [dbo].[USP_SearchLoadLogs]
(
@searchText nvarchar(255),
@PageIndex integer,
@PageSize integer,
@sortOrder nvarchar(255),
@sortBy nvarchar(255),
@CompanyID varchar(50),
@bulkdelete bit
)
AS
BEGIN

	IF LEN(@sortBy) = 0
	BEGIN
		SET @sortBy = 'L.UpdatedTimestamp'
	END
	IF LEN(@sortOrder) = 0
	BEGIN
		SET @sortOrder = 'DESC'
	END
	DECLARE @sql AS varchar(max);
	SET @sql = 'WITH page AS (';
	
	SET @sql = @sql + 'SELECT 
					   L.LoadNumber,
					   L.FieldLabel,
					   L.OldValue,
					   L.NewValue,
					   L.UpdatedBy,
					   L.UpdatedTimeSTamp,
					   L.UpdatedByIP,
					   L.UnLockedFrom,
					   ROW_NUMBER() OVER (ORDER BY UPPER('+@sortBy+') '+@sortOrder+') AS Row
					   FROM LoadLogs L WITH (NOLOCK) 
					   INNER JOIN Employees E ON E.EmployeeID = L.UpdatedByUserID
					   INNER JOIN Offices O ON O.OfficeID = E.OfficeID'
	
	SET @sql = @sql + ' WHERE CompanyID = '''+@CompanyID+''''
	SET @sql = @sql + ' AND ISNULL(bulkdelete,0)='+CAST(@bulkdelete AS VARCHAR(1))
	IF(LEN(TRIM(@SearchText)) <> 0)
	BEGIN
		SET @searchText = '%'+@searchText+'%'
		SET @sql = @sql + ' AND
				(L.LoadNumber like '''+@SearchText+'''
				or L.FieldLabel like '''+@SearchText+'''
				or cast(L.OldValue as nvarchar(10)) like '''+@SearchText+'''
				or cast(L.NewValue as nvarchar(10)) like '''+@SearchText+'''
				or L.UpdatedBy like '''+@SearchText+'''
				or L.UpdatedTimestamp like '''+@SearchText+''')'
	END

	SET @sql = @sql + ')'

	SET @sql = @sql + 'SELECT *,(select (max(row)/30) + (CASE WHEN max(row)%30 <> 0 THEN 1 ELSE 0 END)  FROM page) AS TotalPages FROM page WHERE Row between ('+CAST(@PageIndex AS VARCHAR(10))+' - 1) * 30 + 1 and '+CAST(@PageIndex AS VARCHAR(10))+'*30 ORDER BY Row'

	EXEC(@sql);
END

GO


