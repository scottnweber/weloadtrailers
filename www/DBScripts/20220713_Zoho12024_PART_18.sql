IF(SELECT COUNT(ID) FROM SecurityParameter WHERE parameter = 'HideSalesRepNames') = 0
BEGIN
INSERT INTO [SecurityParameter] 
([Category],[Parameter],[Description],[CreatedBy],[ModifiedBy],[Type]) 
VALUES ('Edit','HideSalesRepNames','Only show the current user on the Sales Rep drop down list.','Scott','Scott','Load')
END

IF(SELECT COUNT(ID) FROM SecurityParameter WHERE parameter = 'HideDispatcherNames') = 0
BEGIN
INSERT INTO [SecurityParameter] 
([Category],[Parameter],[Description],[CreatedBy],[ModifiedBy],[Type]) 
VALUES ('Edit','HideDispatcherNames','Only show the current user on the Dispatcher drop down list.','Scott','Scott','Load')
END

