IF(SELECT COUNT(ID) FROM SecurityParameter WHERE parameter = 'AllowLogs') = 0
BEGIN
INSERT INTO [SecurityParameter] 
([Category],[Parameter],[Description],[CreatedBy],[ModifiedBy],[Type]) 
VALUES ('Edit','AllowLogs','Allow user to access logs.','Scott','Scott','Load')
END


update roles set UserRights = UserRights + ',AllowLogs' WHERE UserRights NOT LIKE '%AllowLogs%'


