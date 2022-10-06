IF(SELECT COUNT(ID) FROM SecurityParameter WHERE parameter = 'EditLockedLoadNotePads') = 0
BEGIN
INSERT INTO [SecurityParameter] 
([Category],[Parameter],[Description],[CreatedBy],[ModifiedBy],[Type]) 
VALUES ('Edit','EditLockedLoadNotePads','Allow Users to edit the Notepads even after the load has reached a Load Lock status.','Scott','Scott','Load')
END

IF(SELECT COUNT(ID) FROM SecurityParameter WHERE parameter = 'EditLockedLoadCustPaidCarrPaid') = 0
BEGIN
INSERT INTO [SecurityParameter] 
([Category],[Parameter],[Description],[CreatedBy],[ModifiedBy],[Type]) 
VALUES ('Edit','EditLockedLoadCustPaidCarrPaid','Allow Users to edit the Cust. Paid and Carr. Paid even after the load has reached a Load Lock status.','Scott','Scott','Load')
END

UPDATE Roles SET userRights = userRights + ',EditLockedLoadNotePads' WHERE RoleValue = 'Administrator' AND userRights NOT LIKE '%EditLockedLoadNotePads%'
UPDATE Roles SET userRights = userRights + ',EditLockedLoadCustPaidCarrPaid' WHERE RoleValue = 'Administrator' AND userRights NOT LIKE '%EditLockedLoadCustPaidCarrPaid%'