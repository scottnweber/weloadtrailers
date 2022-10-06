GO

/****** Object:  Table [dbo].[WelcomeEmails]    Script Date: 23-06-2022 16:21:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[WelcomeEmails](
	[ID] [uniqueidentifier] NOT NULL,
	[AutoNumber] [int] IDENTITY(1,1) NOT NULL,
	[CategoryID] [int] NULL,
	[Description] [varchar](150) NULL,
	[Subject] [varchar](150) NULL,
	[EmailText] [text] NULL,
	[LastModifiedOn] [datetime] NULL,
	[LastModifiedBy] [varchar](20) NULL,
 CONSTRAINT [PK_WelcomeEmails] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[WelcomeEmails] ADD  CONSTRAINT [DF_WelcomeEmails_ID]  DEFAULT (newid()) FOR [ID]
GO
INSERT INTO [dbo].[WelcomeEmails]
           ([CategoryID]
           ,[Description]
           ,[Subject]
           ,[EmailText]
           ,[LastModifiedOn]
           ,[LastModifiedBy])
     VALUES
           (1
           ,'Freight Broker'
           ,'Your Load Manager Freight Broker Site is Live'
           ,''
           ,getdate()
           ,'lm')

INSERT INTO [dbo].[WelcomeEmails]
           ([CategoryID]
           ,[Description]
           ,[Subject]
           ,[EmailText]
           ,[LastModifiedOn]
           ,[LastModifiedBy])
     VALUES
           (2
           ,'Carrier TMS'
           ,'Your Load Manager Carrier TMS Site is Live'
           ,''
           ,getdate()
           ,'lm')

INSERT INTO [dbo].[WelcomeEmails]
           ([CategoryID]
           ,[Description]
           ,[Subject]
           ,[EmailText]
           ,[LastModifiedOn]
           ,[LastModifiedBy])
     VALUES
           (3
           ,'Dispatch Service'
           ,'Your Load Manager Dispatch Service Site is Live'
           ,''
           ,getdate()
           ,'lm')

INSERT INTO [dbo].[WelcomeEmails]
           ([CategoryID]
           ,[Description]
           ,[Subject]
           ,[EmailText]
           ,[LastModifiedOn]
           ,[LastModifiedBy])
     VALUES
           (4
           ,'Freight Broker & Carrier TMS'
           ,'Your Load Manager Freight Broker & Carrier TMS Site is Live'
           ,''
           ,getdate()
           ,'lm')

