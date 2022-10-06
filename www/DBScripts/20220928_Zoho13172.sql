ALTER TABLE LoadsConsolidated ADD CreatedDateTime DateTime NOT NULL DEFAULT(getdate())
ALTER TABLE LoadsConsolidated ADD CreatedBy varchar(150)
ALTER TABLE LoadsConsolidatedDetail ADD CreatedDateTime DateTime NOT NULL DEFAULT(getdate())
ALTER TABLE LoadsConsolidatedDetail ADD CreatedBy  varchar(150)