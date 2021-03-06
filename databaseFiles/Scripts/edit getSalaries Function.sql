USE [OfficeAutomation]
GO
/****** Object:  UserDefinedFunction [dbo].[getSalaries]    Script Date: 12/26/2015 9:22:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER FUNCTION [dbo].[getSalaries] 
(
	-- Add the parameters for the function here
	@pId char(8)
)
RETURNS 
@ansTalbe TABLE 
(
	-- Add the column definitions for the TABLE variable here
	mScore int,
	pScore int,
	base int,
	adding int,
	additional int,
	badClimate int,
	hardness int,
	familyScore int,
	children int,
	years int
)
AS
BEGIN
	-- Fill the table variable with the rows for your result set
	with temp1 as
	(
		select EduLevel,PostID,ManagerID
		from  Employee left join Education on Employee.NationalID = Education.NationalID
		where Employee.PersonalID = @pId 
	)
	, temp2 as(
		select EduLevel,Post_Score.Score pScore,ManagerID
		from temp1 left join Post_Score on temp1.PostID = Post_Score.PostID
	)
	, temp3 as(
		select EduLevel,pScore,Management_Score.Score mScore
		from temp2 left join Management_Score on temp2.ManagerID = Management_Score.ID
	),
	temp4 as(
		select mScore,pScore,Base base,Adding adding,Additional additional,BadClimate badClimate,Hardness hardness,FamilyScore familyScore,Children children,Years years
		from temp3 left join Score on temp3.EduLevel = Score.EduLevel
	)
	Insert into @ansTalbe
	select * from temp4;
 
	RETURN 
END
