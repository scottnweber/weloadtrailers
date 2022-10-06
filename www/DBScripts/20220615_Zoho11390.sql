IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'LoadStops' and column_name = 'DeliverySignatureReceived')
BEGIN
	ALTER TABLE LoadStops ADD DeliverySignatureReceived bit not null default 0;
END

IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'LoadStops' and column_name = 'DeliverySignedBy')
BEGIN
	ALTER TABLE LoadStops ADD DeliverySignedBy varchar(150);
END

IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'LoadStops' and column_name = 'DeliverySignedOn')
BEGIN
	ALTER TABLE LoadStops ADD DeliverySignedOn datetime;
END