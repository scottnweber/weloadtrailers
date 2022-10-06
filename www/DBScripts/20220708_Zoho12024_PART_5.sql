IF(SELECT COUNT(ID) FROM SecurityParameter WHERE parameter = 'EditLockedLoadDatesOnly') = 0
BEGIN
INSERT INTO [SecurityParameter] 
([Category],[Parameter],[Description],[CreatedBy],[ModifiedBy],[Type]) 
VALUES ('Edit','EditLockedExceptLoadDates','Allow Users to edit everything on a load except for the dates, after the load reaches the Load Lock Status.','Scott','Scott','Load')
END

IF(SELECT COUNT(ID) FROM SecurityParameter WHERE parameter = 'EditLockedLoadDatesOnly') = 0
BEGIN
INSERT INTO [SecurityParameter] 
([Category],[Parameter],[Description],[CreatedBy],[ModifiedBy],[Type]) 
VALUES ('Edit','EditLockedLoadDatesOnly','Allow Users to edit the Order Date, Invoice Date, Pickup Date and Delivery Date even after the load has reached a Load Lock status.','Scott','Scott','Load')
END

UPDATE Roles SET userRights = userRights + ',EditLockedExceptLoadDates' WHERE RoleValue = 'Administrator' AND userRights NOT LIKE '%EditLockedExceptLoadDates%'


UPDATE Roles SET userRights = userRights + ',EditLockedLoadDatesOnly' WHERE RoleValue = 'Administrator' AND userRights NOT LIKE '%EditLockedLoadDatesOnly%'