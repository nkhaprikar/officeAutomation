USE [OfficeAutomation]
GO
/****** Object:  StoredProcedure [dbo].[deleteEmployee]    Script Date: 12/31/2015 7:02:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[deleteEmployee] 
	-- Add the parameters for the stored procedure here
	@personalId char(8)
AS
BEGIN
	DECLARE @nationalId char(10);
	DECLARE @cId char(10);
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	-- sysUser,education,contract,employee,person

	BEGIN TRANSACTION

	BEGIN TRY
		set @nationalId = (
		SELECT NationalID
		FROM Employee
		where PersonalID = @personalId
		)

		set @cId = (
		SELECT ContractID
		FROM Employee
		where PersonalID = @personalId
		)

		DELETE
		FROM sysUser
		WHERE PersonalID = @personalId;

		DELETE
		FROM Education
		WHERE NationalID = @nationalId;

		
		DELETE
		FROM Employee
		WHERE PersonalID = @personalId;

		DELETE
		FROM Contract
		WHERE ContractID = @cId;

		DELETE
		FROM Person
		WHERE NationalID = @nationalId;
		
		COMMIT TRANSACTION
		SELECT 1;
	END TRY

	BEGIN CATCH
		ROLLBACK TRANSACTION
		SELECT 0;
	END CATCH

END
