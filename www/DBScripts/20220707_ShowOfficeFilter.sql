IF(SELECT COUNT(ID) FROM SecurityParameter WHERE parameter = 'ShowOfficeFilter') = 0
BEGIN
INSERT INTO [SecurityParameter] 
([Category],[Parameter],[Description],[CreatedBy],[ModifiedBy],[Type]) 
VALUES ('Edit','ShowOfficeFilter','Show office filter on All/My Loads.','Scott','Scott','Load')
END


