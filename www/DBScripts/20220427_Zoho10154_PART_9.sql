IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'FileAttachmentTypes' and column_name = 'Recurring')
BEGIN
	ALTER TABLE FileAttachmentTypes ADD Recurring BIT NOT NULL DEFAULT(0);
END

IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'FileAttachmentTypes' and column_name = 'RenewalDate')
BEGIN
	ALTER TABLE FileAttachmentTypes ADD RenewalDate datetime;
END

IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'FileAttachmentTypes' and column_name = 'Interval')
BEGIN
	ALTER TABLE FileAttachmentTypes ADD Interval INT;
END

