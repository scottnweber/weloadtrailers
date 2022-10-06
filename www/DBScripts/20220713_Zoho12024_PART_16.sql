IF(SELECT COUNT(ID) FROM SecurityParameter WHERE parameter = 'LockLoadAmounts') = 0
BEGIN
INSERT INTO [SecurityParameter] 
([Category],[Parameter],[Description],[CreatedBy],[ModifiedBy],[Type]) 
VALUES ('Edit','LockLoadAmounts','Users CANNOT edit the Customer rate or Carrier/Driver rate on the load.','Scott','Scott','Load')
END





