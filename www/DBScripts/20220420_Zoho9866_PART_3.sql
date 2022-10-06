UPDATE Roles SET userRights = userRights  + ',editUserRoles' WHERE RoleValue ='Administrator' AND userRights  NOT LIKE '%editUserRoles%'


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SecurityParameter](
	[ID] [uniqueidentifier] NOT NULL,
	[Category] [varchar](150) NULL,
	[Parameter] [varchar](150) NULL,
	[Description] [varchar](250) NULL,
	[CreatedDateTime] [datetime] NULL,
	[ModifiedDateTime] [datetime] NULL,
	[AutoNumber] [int] IDENTITY(1,1) NOT NULL,
	[CreatedBy] [varchar](250) NULL,
	[ModifiedBy] [varchar](250) NULL,
 CONSTRAINT [PK_SecurityParameter] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [LoadManager_Data]
) ON [LoadManager_Data]
GO

ALTER TABLE [dbo].[SecurityParameter] ADD  CONSTRAINT [DF_Table_1_userRoleID]  DEFAULT (newid()) FOR [ID]
GO

ALTER TABLE [dbo].[SecurityParameter] ADD  CONSTRAINT [DF_SecurityParameter_CreatedDateTime]  DEFAULT (getdate()) FOR [CreatedDateTime]
GO

ALTER TABLE [dbo].[SecurityParameter] ADD  CONSTRAINT [DF_SecurityParameter_ModifiedDateTime]  DEFAULT (getdate()) FOR [ModifiedDateTime]
GO


Insert into [SecurityParameter] ([Category],[Parameter],[Description],[CreatedBy],[ModifiedBy]) Values ('Edit','addCarrier','User is allowed to add new carriers','Scott','Scott')
Insert into [SecurityParameter] ([Category],[Parameter],[Description],[CreatedBy],[ModifiedBy]) Values ('Edit','DeleteLoad','User will see an option to Delete a load. Note that all load deletions are logged.','Scott','Scott')
Insert into [SecurityParameter] ([Category],[Parameter],[Description],[CreatedBy],[ModifiedBy]) Values ('Edit','Editable Status','While not a Role Parameter it is a setting for each role where as you define which Load Status will allow the Role to edit a load with that status','Scott','Scott')
Insert into [SecurityParameter] ([Category],[Parameter],[Description],[CreatedBy],[ModifiedBy]) Values ('Edit','editDrivers','User is allowed edit Drivers','Scott','Scott')
Insert into [SecurityParameter] ([Category],[Parameter],[Description],[CreatedBy],[ModifiedBy]) Values ('Edit','editLoad','User is allowed to edit existing loads','Scott','Scott')
Insert into [SecurityParameter] ([Category],[Parameter],[Description],[CreatedBy],[ModifiedBy]) Values ('Finance','changeCustomerActiveStatus','User is allow to set the Payer Status to True.','Scott','Scott')
Insert into [SecurityParameter] ([Category],[Parameter],[Description],[CreatedBy],[ModifiedBy]) Values ('Finance','HideCustomerPricing','On the Load screen, hide the customer pricing and the load profit','Scott','Scott')
Insert into [SecurityParameter] ([Category],[Parameter],[Description],[CreatedBy],[ModifiedBy]) Values ('Finance','HideFinancialRates','Hides entire box with customer totals, carrier totals, miles charge, direct costs and profit on the load screen.','Scott','Scott')
Insert into [SecurityParameter] ([Category],[Parameter],[Description],[CreatedBy],[ModifiedBy]) Values ('Record Lock','EditLockedLoad','User is allowed to edit a load that has reached the Lock Load status.','Scott','Scott')
Insert into [SecurityParameter] ([Category],[Parameter],[Description],[CreatedBy],[ModifiedBy]) Values ('Record Lock','UnlockAgent','User can unlock a locked user on the user edit screen','Scott','Scott')
Insert into [SecurityParameter] ([Category],[Parameter],[Description],[CreatedBy],[ModifiedBy]) Values ('Record Lock','UnlockCarrier','User is allowed to unlock a locked carrier','Scott','Scott')
Insert into [SecurityParameter] ([Category],[Parameter],[Description],[CreatedBy],[ModifiedBy]) Values ('Record Lock','UnlockCustomer','User is allowed to unlock a locked customer','Scott','Scott')
Insert into [SecurityParameter] ([Category],[Parameter],[Description],[CreatedBy],[ModifiedBy]) Values ('Record Lock','UnlockDriver','User is allowed to unlock a locked driver','Scott','Scott')
Insert into [SecurityParameter] ([Category],[Parameter],[Description],[CreatedBy],[ModifiedBy]) Values ('Record Lock','UnlockEquipment','user is allowed to unlock a locked equipment','Scott','Scott')
Insert into [SecurityParameter] ([Category],[Parameter],[Description],[CreatedBy],[ModifiedBy]) Values ('Record Lock','UnlockLoad','User is allowed to unlock a locked load.','Scott','Scott')
Insert into [SecurityParameter] ([Category],[Parameter],[Description],[CreatedBy],[ModifiedBy]) Values ('Reports','runExport','User is allowed to run the Export Data option. Note this requires the "runReports" paramater.','Scott','Scott')
Insert into [SecurityParameter] ([Category],[Parameter],[Description],[CreatedBy],[ModifiedBy]) Values ('Reports','runReports','User is allowed to run reports under the "Report" menu.','Scott','Scott')
Insert into [SecurityParameter] ([Category],[Parameter],[Description],[CreatedBy],[ModifiedBy]) Values ('Reports','SalesRepReport','Allow the user to run only the Sales Report with their user information preset as the Sales Rep criteria so they can only see their loads.','Scott','Scott')
Insert into [SecurityParameter] ([Category],[Parameter],[Description],[CreatedBy],[ModifiedBy]) Values ('Settings','CarrierOnboardingVerifier','This allows a user to verify carrier onboarding documents to make them legit.','Scott','Scott')
Insert into [SecurityParameter] ([Category],[Parameter],[Description],[CreatedBy],[ModifiedBy]) Values ('Settings','EditSystemLoadStatus','User is allowed to make changes in the "Load Status" option under settings','Scott','Scott')
Insert into [SecurityParameter] ([Category],[Parameter],[Description],[CreatedBy],[ModifiedBy]) Values ('Settings','modifySystemSetup','User is allowed to make changes to the Settings/Configuration Options screen.','Scott','Scott')