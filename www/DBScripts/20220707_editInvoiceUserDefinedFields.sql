IF(SELECT COUNT(ID) FROM SecurityParameter WHERE parameter = 'editInvoiceUserDefinedFields') = 0
BEGIN
INSERT INTO [SecurityParameter] 
([Category],[Parameter],[Description],[CreatedBy],[ModifiedBy],[Type]) 
VALUES ('Edit','editInvoiceUserDefinedFields','Allow the user to edit only userdefined fields and invoice date on load.','Scott','Scott','Load')
END


