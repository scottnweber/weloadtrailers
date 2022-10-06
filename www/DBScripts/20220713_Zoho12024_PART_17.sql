IF(SELECT COUNT(ID) FROM SecurityParameter WHERE parameter = 'LockLoadDates') = 0
BEGIN
INSERT INTO [SecurityParameter] 
([Category],[Parameter],[Description],[CreatedBy],[ModifiedBy],[Type]) 
VALUES ('Edit','LockLoadDates','Users CANNOT edit any dates on the load.','Scott','Scott','Load')
END
