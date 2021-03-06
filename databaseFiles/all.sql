USE [master]
GO
/****** Object:  Database [OfficeAutomation]    Script Date: 1/4/2016 3:52:24 PM ******/
CREATE DATABASE [OfficeAutomation]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'OfficeAutomation', FILENAME = N'D:\installed place\Microsoft SQL server 14\MSSQL12.MESSQLSERVER\MSSQL\DATA\OfficeAutomation.mdf' , SIZE = 5120KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'OfficeAutomation_log', FILENAME = N'D:\installed place\Microsoft SQL server 14\MSSQL12.MESSQLSERVER\MSSQL\DATA\OfficeAutomation_log.ldf' , SIZE = 2560KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [OfficeAutomation] SET COMPATIBILITY_LEVEL = 120
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [OfficeAutomation].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [OfficeAutomation] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [OfficeAutomation] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [OfficeAutomation] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [OfficeAutomation] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [OfficeAutomation] SET ARITHABORT OFF 
GO
ALTER DATABASE [OfficeAutomation] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [OfficeAutomation] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [OfficeAutomation] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [OfficeAutomation] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [OfficeAutomation] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [OfficeAutomation] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [OfficeAutomation] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [OfficeAutomation] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [OfficeAutomation] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [OfficeAutomation] SET  DISABLE_BROKER 
GO
ALTER DATABASE [OfficeAutomation] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [OfficeAutomation] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [OfficeAutomation] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [OfficeAutomation] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [OfficeAutomation] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [OfficeAutomation] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [OfficeAutomation] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [OfficeAutomation] SET RECOVERY FULL 
GO
ALTER DATABASE [OfficeAutomation] SET  MULTI_USER 
GO
ALTER DATABASE [OfficeAutomation] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [OfficeAutomation] SET DB_CHAINING OFF 
GO
ALTER DATABASE [OfficeAutomation] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [OfficeAutomation] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
ALTER DATABASE [OfficeAutomation] SET DELAYED_DURABILITY = DISABLED 
GO
USE [OfficeAutomation]
GO
/****** Object:  UserDefinedFunction [dbo].[getAllEmployeeList]    Script Date: 1/4/2016 3:52:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[getAllEmployeeList] 
(
	-- Add the parameters for the function here
	
)
RETURNS 
@ansTable TABLE 
(
	-- Add the column definitions for the TABLE variable here
	firstName varchar(20),
	lastName varchar(20),
	birthDate date,
	gender char(1),
	personalId char(10),
	nationalId char(10),
	contractType varchar(20),
	post varchar(20),
	officeUnit varchar(20),
	eduLevel varchar(50)
)
AS
BEGIN
	-- Fill the table variable with the rows for your result set
	
	DECLARE @pId char(10);
	-- Fill the table variable with the rows for your result set
	DECLARE emp2_cursor CURSOR FOR  
	SELECT PersonalID  
	FROM Employee 

	OPEN emp2_cursor   
	FETCH NEXT FROM emp2_cursor INTO @pId   

	WHILE @@FETCH_STATUS = 0   
	BEGIN   
		with temp1 as( 
	select PersonalID,Employee.NationalID,ContractID,PostID,OfficeID,EduLevel
		from  Employee join Education on Employee.NationalID = Education.NationalID
		where Employee.PersonalID = @pId 
	)	
	,temp3 as( 
	select PersonalID,NationalID,ContractID,Post_Score.PostTitle,EduLevel,OfficeID
		from  temp1 left join Post_Score on temp1.PostID = Post_Score.PostID
	)
	,temp4 as( 
	select firstName,lastName,Birthdate,Gender,PersonalID,temp3.NationalID,ContractID,PostTitle ,EduLevel,OfficeID
		from  temp3,Person
		where temp3.NationalID = Person.NationalID 
	)
	,temp5 as( 
	select firstName,lastName,Birthdate,Gender,PersonalID,NationalID,Contract.contractType,PostTitle,EduLevel,temp4.OfficeID
		from  temp4,Contract
		where temp4.ContractID = Contract.ContractID 
	)
	,temp6 as( 
	select firstName,lastName,Birthdate,Gender,PersonalID,NationalID,contractType,PostTitle,OfficeUnit.OfficeTitle,EduLevel
		from  temp5,OfficeUnit
		where OfficeUnit.OfficeID = temp5.OfficeID 
	)
	
	Insert into @ansTable
	select * from temp6;

		   FETCH NEXT FROM emp2_cursor INTO @pId   
	END   

	CLOSE emp2_cursor   
	DEALLOCATE emp2_cursor
	RETURN  
END

GO
/****** Object:  UserDefinedFunction [dbo].[getEmployeeListInOffice]    Script Date: 1/4/2016 3:52:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[getEmployeeListInOffice]
(
	-- Add the parameters for the function here
	@officeId char(2)
)
RETURNS 
@ansTable TABLE 
(
	-- Add the column definitions for the TABLE variable here
	firstName varchar(20),
	lastName varchar(20),
	birthDate date,
	gender char(1),
	personalId char(10),
	nationalId char(10),
	contractType varchar(20),
	post varchar(20),
	eduLevel varchar(50)
	
)
AS
BEGIN
	DECLARE @pId char(10);
	-- Fill the table variable with the rows for your result set
	DECLARE emp_cursor CURSOR FOR  
	SELECT PersonalID  
	FROM Employee 
	WHERE  OfficeID = @officeId;

	OPEN emp_cursor   
	FETCH NEXT FROM emp_cursor INTO @pId   

	WHILE @@FETCH_STATUS = 0   
	BEGIN   
		with temp1 as( 
	select PersonalID,Employee.NationalID,ContractID,PostID,OfficeID,EduLevel
		from  Employee join Education on Employee.NationalID = Education.NationalID
		where Employee.PersonalID = @pId 
	)	
	,temp3 as( 
	select PersonalID,NationalID,ContractID,Post_Score.PostTitle,EduLevel
		from  temp1 left join Post_Score on temp1.PostID = Post_Score.PostID
	)
	,temp4 as( 
	select firstName,lastName,Birthdate,Gender,PersonalID,temp3.NationalID,ContractID,PostTitle ,EduLevel
		from  temp3,Person
		where temp3.NationalID = Person.NationalID 
	)
	,temp5 as( 
	select firstName,lastName,Birthdate,Gender,PersonalID,NationalID,Contract.contractType,PostTitle,EduLevel
		from  temp4,Contract
		where temp4.ContractID = Contract.ContractID 
	)
	Insert into @ansTable
	select * from temp5;

		   FETCH NEXT FROM emp_cursor INTO @pId   
	END   

	CLOSE emp_cursor   
	DEALLOCATE emp_cursor
	RETURN 
END

GO
/****** Object:  UserDefinedFunction [dbo].[getManagerTitles]    Script Date: 1/4/2016 3:52:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[getManagerTitles] 
(
	-- Add the parameters for the function here
	
)
RETURNS 
@ansTable TABLE 
(
	-- Add the column definitions for the TABLE variable here
	title varchar(20)
)
AS
BEGIN
	-- Fill the table variable with the rows for your result set
	INSERT INTO @ansTable
	SELECT ManagementTitle
	FROM Management_Score

	RETURN 
END

GO
/****** Object:  UserDefinedFunction [dbo].[getOfficeList]    Script Date: 1/4/2016 3:52:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[getOfficeList] 
(
	-- Add the parameters for the function here
	
)
RETURNS 
@ansTable TABLE 
(
	-- Add the column definitions for the TABLE variable here
	office varchar(20)
)
AS
BEGIN
	-- Fill the table variable with the rows for your result set
	INSERT INTO @ansTable
	SELECT OfficeTitle
	FROM OfficeUnit

	RETURN 
END

GO
/****** Object:  UserDefinedFunction [dbo].[getPersonalInfo]    Script Date: 1/4/2016 3:52:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[getPersonalInfo] 
(
	-- Add the parameters for the function here
	@pId char(8)
)
RETURNS 
@ansTable TABLE 
(
	-- Add the column definitions for the TABLE variable here
	firstName varchar(20),
	lastName varchar(20),
	birthDate date,
	sodoorPlace varchar(20),
	maritalStatus char(1),
	gender char(1),
	childrenNumber tinyint,
	nationalId char(10),
	eduLevel varchar(50),
	field varchar(50),
	institute varchar(20),
	graduationDate date,
	finalProjectTitle varchar(20),
	average float

)
AS
BEGIN
	-- Fill the table variable with the rows for your result set
	with temp1 as(
		select firstName,lastName,Birthdate,SodoorPlace,maritalStatus,Gender,ChildrenNumber,Person.NationalID
		from Employee left join Person on Employee.NationalID=Person.NationalID
		where Employee.PersonalID = @pId
	)
	, temp2 as(
		select firstName,lastName,Birthdate,SodoorPlace,maritalStatus,Gender,ChildrenNumber,temp1.NationalID,EduLevel,Field,Institute,GraduationDate,FinalProjectTitle,Average
		from temp1 left join Education on temp1.NationalID = Education.NationalID
	)
	insert into @ansTable
	select * from temp2; 
	RETURN 
END

GO
/****** Object:  UserDefinedFunction [dbo].[getPostList]    Script Date: 1/4/2016 3:52:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[getPostList] 
(
	-- Add the parameters for the function here
	
)
RETURNS 
@ansTable TABLE 
(
	-- Add the column definitions for the TABLE variable here
	post varchar(20)
)
AS
BEGIN
	-- Fill the table variable with the rows for your result set
	INSERT INTO @ansTable
	SELECT PostTitle
	FROM Post_Score;

	RETURN 
END

GO
/****** Object:  UserDefinedFunction [dbo].[getSalaries]    Script Date: 1/4/2016 3:52:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[getSalaries] 
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
	years int,
	childrenNumber int,
	maritalStatus char(1),
	length int
)
AS
BEGIN
	-- Fill the table variable with the rows for your result set
	with temp as
	( 
		SELECT PostID,ManagerID,PersonalID,Employee.NationalID,ChildrenNumber,maritalStatus,ContractID
		FROM Employee left join Person on Employee.NationalID = Person.NationalID
		WHERE Employee.PersonalID = @pId
	)
	,temp0 as
	( 
		SELECT temp.PostID,ManagerID,PersonalID,NationalID,ChildrenNumber,maritalStatus,Length
		FROM temp left join Contract on temp.ContractID = Contract.ContractID
		WHERE temp.PersonalID = @pId
	)
	,temp1 as
	(
		select EduLevel,PostID,ManagerID,ChildrenNumber,maritalStatus,Length
		from  temp0 left join Education on temp0.NationalID = Education.NationalID
		where temp0.PersonalID = @pId 
	)
	, temp2 as(
		select EduLevel,Post_Score.Score pScore,ManagerID,ChildrenNumber,maritalStatus,Length
		from temp1 left join Post_Score on temp1.PostID = Post_Score.PostID
	)
	, temp3 as(
		select EduLevel,pScore,Management_Score.Score mScore,ChildrenNumber,maritalStatus,Length
		from temp2 left join Management_Score on temp2.ManagerID = Management_Score.ID
	),
	temp4 as(
		select mScore,pScore,Base base,Adding adding,Additional additional,BadClimate badClimate,Hardness hardness,FamilyScore familyScore,Children children,Years years,ChildrenNumber,maritalStatus,Length
		from temp3 left join Score on temp3.EduLevel = Score.EduLevel
	)
	Insert into @ansTalbe
	select * from temp4;
 
	RETURN 
END

GO
/****** Object:  UserDefinedFunction [dbo].[getStatement]    Script Date: 1/4/2016 3:52:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohammad Eslahi Sani
-- Create date: 1394-10-04
-- Description:	to get statement of employees by their personalID
-- =============================================
CREATE FUNCTION [dbo].[getStatement] 
(
	-- Add the parameters for the function here
	@emplyeeID char(8) 
	
)
RETURNS 
@ansTable TABLE 
(
	firstName varchar(20),
	lastName varchar(20),
	birthDate date,
	sodoorPlace varchar(20),
	maritalStatus char(1),
	gender char(1),
	childrenNumber tinyint,
	personalId char(8),
	nationalId char(10),
	contractType varchar(20),
	mScore int,
	pScore int,
	postTitle varchar(20), 
	officeTitle varchar(20),
	managerId char(1),
	eduLevel varchar(50),
	field varchar(50),
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
	with temp1 as( 
	select PersonalID,Employee.NationalID,ContractID,PostID,OfficeID,ManagerID,EduLevel,Field
		from  Employee join Education on Employee.NationalID = Education.NationalID
		where Employee.PersonalID = @emplyeeID 
	)

	,temp2 as( 
	select PersonalID,NationalID,ContractID,PostID, OfficeUnit.OfficeTitle ,ManagerID,EduLevel,Field
		from  temp1,OfficeUnit
		where OfficeUnit.OfficeID = temp1.OfficeID 
	)
	,temp3 as( 
	select PersonalID,NationalID,ContractID,Post_Score.PostTitle,Post_Score.Score, OfficeTitle ,ManagerID,EduLevel,Field
		from  temp2 left join Post_Score on temp2.PostID = Post_Score.PostID
	)

	,temp4 as( 
	select firstName,lastName,Birthdate,SodoorPlace,maritalStatus,Gender,ChildrenNumber,PersonalID,temp3.NationalID,ContractID,Score,PostTitle, OfficeTitle ,ManagerID,EduLevel,Field
		from  temp3,Person
		where temp3.NationalID = Person.NationalID 
	)
	,temp5 as( 
	select firstName,lastName,Birthdate,SodoorPlace,maritalStatus,Gender,ChildrenNumber,PersonalID,NationalID,Contract.contractType,Score,PostTitle, OfficeTitle ,ManagerID,EduLevel,Field
		from  temp4,Contract
		where temp4.ContractID = Contract.ContractID 
	)
	,temp6 as( 
	select firstName,lastName,Birthdate,SodoorPlace,maritalStatus,Gender,ChildrenNumber,PersonalID,NationalID,contractType,Score,PostTitle, OfficeTitle ,ManagerID,temp5.EduLevel,Field,Base,Adding,Additional,BadClimate,Hardness,FamilyScore,Children,Years
		from  temp5,Score
		where temp5.EduLevel = Score.EduLevel 
	)
	,temp7 as( 
	select firstName,lastName,Birthdate,SodoorPlace,maritalStatus,Gender,ChildrenNumber,PersonalID,NationalID,contractType,Management_Score.Score mScore,temp6.Score pScore,PostTitle, OfficeTitle ,ManagerID,EduLevel,Field,Base,Adding,Additional,BadClimate,Hardness,FamilyScore,Children,Years
		from  temp6 left join Management_Score on temp6.ManagerID = Management_Score.ID
	)
	Insert into @ansTable
	select * from temp7;
 


	RETURN 
END

GO
/****** Object:  UserDefinedFunction [dbo].[getUserInfo]    Script Date: 1/4/2016 3:52:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[getUserInfo]
(
	-- Add the parameters for the function here
	@inUser varchar(50)
)
RETURNS 
@ansTable TABLE 
(
	-- Add the column definitions for the TABLE variable here
	username varchar(50),
	pass	varchar(50),
	userType varchar(10),
	pId char(8)
)
AS
BEGIN
	-- Fill the table variable with the rows for your result set
	with temp1 as(
		select * from sysUser where sysUser.Username = @inUser
	)
	Insert into @ansTable
	select * from temp1;
	RETURN 
END

GO
/****** Object:  UserDefinedFunction [dbo].[isInUnit]    Script Date: 1/4/2016 3:52:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[isInUnit] 
(
	-- Add the parameters for the function here
	@headId char(10),
	@employeeId char(10)
)
RETURNS INT
AS
BEGIN
	-- Declare the return variable here
	DECLARE @result int;
	DECLARE @headUnitId char(2);
	DECLARE @employeeUnitId char(2);
	-- Add the T-SQL statements to compute the return value here
	SET @headUnitId = (
		SELECT OfficeID
		FROM Employee
		WHERE PersonalID = @headId 
	);

	
	SET @employeeUnitId = (
		SELECT OfficeID
		FROM Employee
		WHERE PersonalID = @employeeId
	);

	IF @headUnitId = @employeeUnitId
	BEGIN
		SET @result = 1;
	END
	ELSE
	BEGIN
		SET @result = 0;
	END

	-- Return the result of the function
	RETURN @result

END

GO
/****** Object:  Table [dbo].[Contract]    Script Date: 1/4/2016 3:52:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Contract](
	[ContractID] [char](10) NOT NULL,
	[StartDate] [date] NOT NULL,
	[ExpireDate] [date] NULL,
	[Length] [int] NULL,
	[PostID] [char](2) NULL,
	[OfficeID] [char](2) NULL,
	[contractType] [varchar](20) NOT NULL,
 CONSTRAINT [PK_Contract] PRIMARY KEY CLUSTERED 
(
	[ContractID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Education]    Script Date: 1/4/2016 3:52:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Education](
	[NationalID] [char](10) NOT NULL,
	[EduLevel] [varchar](50) NOT NULL,
	[Field] [varchar](50) NOT NULL,
	[Institute] [varchar](20) NOT NULL,
	[GraduationDate] [date] NOT NULL,
	[FinalProjectTitle] [varchar](20) NOT NULL,
	[Average] [float] NOT NULL,
 CONSTRAINT [PK_Education] PRIMARY KEY CLUSTERED 
(
	[NationalID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Employee]    Script Date: 1/4/2016 3:52:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Employee](
	[PersonalID] [char](8) NOT NULL,
	[NationalID] [char](10) NOT NULL,
	[ContractID] [char](10) NOT NULL,
	[PostID] [char](2) NULL,
	[OfficeID] [char](2) NULL,
	[ManagerID] [char](1) NULL,
 CONSTRAINT [PK_Employee] PRIMARY KEY CLUSTERED 
(
	[PersonalID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Management_Score]    Script Date: 1/4/2016 3:52:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Management_Score](
	[ID] [char](1) NOT NULL,
	[ManagementTitle] [varchar](20) NOT NULL,
	[Score] [int] NOT NULL,
 CONSTRAINT [PK_Management_Score] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[OfficeUnit]    Script Date: 1/4/2016 3:52:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[OfficeUnit](
	[OfficeID] [char](2) NOT NULL,
	[OfficeTitle] [varchar](20) NOT NULL,
 CONSTRAINT [PK_OfficeUnit] PRIMARY KEY CLUSTERED 
(
	[OfficeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Person]    Script Date: 1/4/2016 3:52:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Person](
	[firstName] [varchar](20) NOT NULL,
	[lastName] [varchar](20) NOT NULL,
	[Birthdate] [date] NOT NULL,
	[NationalID] [char](10) NOT NULL,
	[SodoorPlace] [varchar](15) NOT NULL,
	[maritalStatus] [char](1) NOT NULL,
	[Gender] [char](1) NOT NULL,
	[ChildrenNumber] [tinyint] NOT NULL,
 CONSTRAINT [PK_Person] PRIMARY KEY CLUSTERED 
(
	[NationalID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Post_Score]    Script Date: 1/4/2016 3:52:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Post_Score](
	[PostID] [char](2) NOT NULL,
	[PostTitle] [varchar](20) NOT NULL,
	[Score] [int] NOT NULL,
 CONSTRAINT [PK_Table_1] PRIMARY KEY CLUSTERED 
(
	[PostID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Score]    Script Date: 1/4/2016 3:52:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Score](
	[EduLevel] [varchar](50) NOT NULL,
	[Base] [int] NOT NULL,
	[Additional] [int] NOT NULL,
	[Adding] [int] NOT NULL,
	[Hardness] [int] NOT NULL,
	[BadClimate] [int] NOT NULL,
	[FamilyScore] [int] NOT NULL,
	[Children] [int] NOT NULL,
	[Years] [int] NOT NULL,
 CONSTRAINT [PK_Score_1] PRIMARY KEY CLUSTERED 
(
	[EduLevel] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[sysUser]    Script Date: 1/4/2016 3:52:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[sysUser](
	[Username] [varchar](50) NOT NULL,
	[Password] [varchar](50) NOT NULL,
	[Role] [varchar](20) NOT NULL,
	[PersonalID] [char](8) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[Contract]  WITH CHECK ADD  CONSTRAINT [FK_Contract_OfficeUnit] FOREIGN KEY([OfficeID])
REFERENCES [dbo].[OfficeUnit] ([OfficeID])
GO
ALTER TABLE [dbo].[Contract] CHECK CONSTRAINT [FK_Contract_OfficeUnit]
GO
ALTER TABLE [dbo].[Contract]  WITH CHECK ADD  CONSTRAINT [FK_Contract_Post_Score] FOREIGN KEY([PostID])
REFERENCES [dbo].[Post_Score] ([PostID])
GO
ALTER TABLE [dbo].[Contract] CHECK CONSTRAINT [FK_Contract_Post_Score]
GO
ALTER TABLE [dbo].[Education]  WITH CHECK ADD  CONSTRAINT [FK_Education_Person] FOREIGN KEY([NationalID])
REFERENCES [dbo].[Person] ([NationalID])
GO
ALTER TABLE [dbo].[Education] CHECK CONSTRAINT [FK_Education_Person]
GO
ALTER TABLE [dbo].[Employee]  WITH CHECK ADD  CONSTRAINT [FK_Employee_Contract] FOREIGN KEY([ContractID])
REFERENCES [dbo].[Contract] ([ContractID])
GO
ALTER TABLE [dbo].[Employee] CHECK CONSTRAINT [FK_Employee_Contract]
GO
ALTER TABLE [dbo].[Employee]  WITH CHECK ADD  CONSTRAINT [FK_Employee_Management_Score] FOREIGN KEY([ManagerID])
REFERENCES [dbo].[Management_Score] ([ID])
GO
ALTER TABLE [dbo].[Employee] CHECK CONSTRAINT [FK_Employee_Management_Score]
GO
ALTER TABLE [dbo].[Employee]  WITH CHECK ADD  CONSTRAINT [FK_Employee_OfficeUnit] FOREIGN KEY([OfficeID])
REFERENCES [dbo].[OfficeUnit] ([OfficeID])
GO
ALTER TABLE [dbo].[Employee] CHECK CONSTRAINT [FK_Employee_OfficeUnit]
GO
ALTER TABLE [dbo].[Employee]  WITH CHECK ADD  CONSTRAINT [FK_Employee_Person] FOREIGN KEY([NationalID])
REFERENCES [dbo].[Person] ([NationalID])
GO
ALTER TABLE [dbo].[Employee] CHECK CONSTRAINT [FK_Employee_Person]
GO
ALTER TABLE [dbo].[Employee]  WITH CHECK ADD  CONSTRAINT [FK_Employee_Post_Score] FOREIGN KEY([PostID])
REFERENCES [dbo].[Post_Score] ([PostID])
GO
ALTER TABLE [dbo].[Employee] CHECK CONSTRAINT [FK_Employee_Post_Score]
GO
ALTER TABLE [dbo].[sysUser]  WITH CHECK ADD  CONSTRAINT [FK_User_Employee] FOREIGN KEY([PersonalID])
REFERENCES [dbo].[Employee] ([PersonalID])
GO
ALTER TABLE [dbo].[sysUser] CHECK CONSTRAINT [FK_User_Employee]
GO
/****** Object:  StoredProcedure [dbo].[addEmployee]    Script Date: 1/4/2016 3:52:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[addEmployee] 
	-- Add the parameters for the stored procedure here
	
	-- personal parameters:
	@firstName varchar(20),
	@lastName varchar(20),
	@nationalId char(10),
	@birthDate date,
	@sodoorPlace varchar(15),
	@maritalStatus char(1),
	@gender char(1),
	@childrenNumber tinyint,
	
	-- contract parameters:
	@contractId char(10),
	@startDate date,
	@expireDate date,
	@postId char(2),
	@officeId char(2),
	@contractType varchar(20),

	-- education parameters:
	@eduLevel varchar(50),
	@field varchar(50),
	@institute varchar(20),
	@graduationDate date,
	@projectTitle varchar(20),
	@avarage float,

	-- employee parameters:
	@personalId char(8),
	@managerId char(1),

	-- user parameters:
	@username varchar(50),
	@pass	varchar(50),
	@role	varchar(10)
		
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @debugNumber int = 0;
    -- Insert statements for procedure here
	BEGIN TRANSACTION

	BEGIN TRY
		INSERT INTO Person
		(firstName,lastName,NationalID,Birthdate,SodoorPlace,maritalStatus,Gender,ChildrenNumber)
		VALUES (@firstName,@lastName,@nationalId,@birthDate,@sodoorPlace,@maritalStatus,@gender,@childrenNumber);
	
		SET @debugNumber = 2;

		INSERT INTO Contract
		(ContractID,StartDate,ExpireDate,PostID,OfficeID,contractType)
		VALUES (@contractId,@startDate,@expireDate,@postId,@officeId,@contractType);
	
		SET @debugNumber = 3;

		INSERT INTO Education
		(NationalID,EduLevel,Field,Institute,GraduationDate,FinalProjectTitle,Average)
		VALUES (@nationalId,@eduLevel,@field,@institute,@graduationDate,@projectTitle,@avarage);
	
		SET @debugNumber = 4;

		INSERT INTO Employee
		(PersonalID,NationalID,ContractID,PostID,OfficeID,ManagerID)
		VALUES (@personalId,@nationalId,@contractId,@postId,@officeId,@managerId);
	
		SET @debugNumber = 5;

		INSERT INTO sysUser
		(Username,Password,Role,PersonalID)
		VALUES (@username,@pass,@role,@personalId);
		
		SET @debugNumber = 6;

		COMMIT TRANSACTION;
		SELECT 1;
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;
		SELECT @debugNumber;
	END CATCH

	
END

GO
/****** Object:  StoredProcedure [dbo].[addOfficeUnit]    Script Date: 1/4/2016 3:52:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[addOfficeUnit] 
	-- Add the parameters for the stored procedure here
	@id char(2),
	@title varchar(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO OfficeUnit
	(OfficeID,OfficeTitle)
	values(@id,@title);

END

GO
/****** Object:  StoredProcedure [dbo].[addPost]    Script Date: 1/4/2016 3:52:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[addPost] 
	-- Add the parameters for the stored procedure here
	@postId char(2),
	@postTitle varchar(20),
	@postScore int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		INSERT INTO Post_Score
		(PostID,PostTitle,Score)
		VALUES (@postId,@postTitle,@postScore);
	
		SELECT 1;
	END TRY
	BEGIN CATCH
		SELECT 0;
	END CATCH
END

GO
/****** Object:  StoredProcedure [dbo].[deleteEmployee]    Script Date: 1/4/2016 3:52:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[deleteEmployee] 
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

GO
/****** Object:  StoredProcedure [dbo].[editContract]    Script Date: 1/4/2016 3:52:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[editContract]
	-- Add the parameters for the stored procedure here
	@cId char(10),
	@fieldName varchar(20),
	@fieldChar varchar(20) = NULL,
	@fieldDate date = NULL,
	@fieldInt int = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
	IF @fieldName = 'startDate'
	BEGIN
		UPDATE Contract
		SET StartDate = @fieldDate
		WHERE ContractID = @cId
	END

	ELSE IF @fieldName = 'expireDate'
	BEGIN
		UPDATE Contract
		SET ExpireDate = @fieldDate
		WHERE ContractID = @cId
	END

	ELSE IF @fieldName = 'length'
	BEGIN
		UPDATE Contract
		SET Length = @fieldInt
		WHERE ContractID = @cId
	END

	ELSE IF @fieldName = 'postId'
	BEGIN
		UPDATE Contract
		SET PostID = @fieldChar
		WHERE ContractID = @cId
	END

	ELSE IF @fieldName = 'officeId'
	BEGIN
		UPDATE Contract
		SET OfficeID = @fieldChar
		WHERE ContractID = @cId
	END

	ELSE IF @fieldName = 'contractType'
	BEGIN
		UPDATE Contract
		SET contractType = @fieldChar
		WHERE ContractID = @cId
	END
		
		SELECT 1;
	END TRY

	BEGIN CATCH
		
		SELECT 0;
	END CATCH
END


GO
/****** Object:  StoredProcedure [dbo].[editEmployee]    Script Date: 1/4/2016 3:52:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[editEmployee] 
	-- Add the parameters for the stored procedure here
	@personalId char(10),
	@paramName varchar(20),
	@paramChar varchar(20) = NULL,
	@paramDate date = NULL,
	@paramInt int = NULL,
	@paramFloat float = NULL
AS
BEGIN
	DECLARE @nationalId char(10);
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
	SET @nationalId = (
		SELECT NationalID
		FROM Employee
		WHERE PersonalID = @personalId
	);

	

	IF @paramName = 'firstName'
	BEGIN
		UPDATE Person
		SET firstName = @paramChar
		WHERE NationalID = @nationalId;
	END

	ELSE IF @paramName = 'lastName'
	BEGIN
		UPDATE Person
		SET lastName = @paramChar
		WHERE NationalID = @nationalId;
	END
	
	ELSE IF @paramName = 'sodoorPlace'
	BEGIN
		UPDATE Person
		SET SodoorPlace = @paramChar
		WHERE NationalID = @nationalId;
	END
	
	ELSE IF @paramName = 'maritalStatus'
	BEGIN
		UPDATE Person
		SET maritalStatus = @paramChar
		WHERE NationalID = @nationalId;
	END
	
	ELSE IF @paramName = 'gender'
	BEGIN
		UPDATE Person
		SET Gender = @paramChar
		WHERE NationalID = @nationalId;
	END
	
	ELSE IF @paramName = 'birthDate'
	BEGIN
		UPDATE Person
		SET Birthdate = @paramDate
		WHERE NationalID = @nationalId;
	END
	
	ELSE IF @paramName = 'childrenNumber'
	BEGIN
		UPDATE Person
		SET ChildrenNumber = @paramInt
		WHERE NationalID = @nationalId;
	END

	ELSE IF @paramName = 'contractId'
	BEGIN
		UPDATE Employee
		SET ContractID = @paramChar
		WHERE PersonalID = @personalId;
	END

	ELSE IF @paramName = 'postId'
	BEGIN
		UPDATE Employee
		SET PostID = @paramChar
		WHERE PersonalID = @personalId;
	END

	ELSE IF @paramName = 'officeId'
	BEGIN
		UPDATE Employee
		SET OfficeID = @paramChar
		WHERE PersonalID = @personalId;
	END

	ELSE IF @paramName = 'managerId'
	BEGIN
		UPDATE Employee
		SET ManagerID = @paramChar
		WHERE PersonalID = @personalId;
	END

	ELSE IF @paramName = 'eduLevel'
	BEGIN
		UPDATE Education
		SET EduLevel = @paramChar
		WHERE NationalID = @nationalId;
	END
	
	ELSE IF @paramName = 'field'
	BEGIN
		UPDATE Education
		SET Field = @paramChar
		WHERE NationalID = @nationalId;
	END

	ELSE IF @paramName = 'institute'
	BEGIN
		UPDATE Education
		SET Institute = @paramChar
		WHERE NationalID = @nationalId;
	END
	
	ELSE IF @paramName = 'graduationDate'
	BEGIN
		UPDATE Education
		SET GraduationDate = @paramDate
		WHERE NationalID = @nationalId;
	END

	
	ELSE IF @paramName = 'finalProjectTitle'
	BEGIN
		UPDATE Education
		SET FinalProjectTitle = @paramChar
		WHERE NationalID = @nationalId;
	END

	
	ELSE IF @paramName = 'average'
	BEGIN
		UPDATE Education
		SET Average = @paramFloat
		WHERE NationalID = @nationalId;
	END



		SELECT 1;
	END TRY
	BEGIN CATCH
		SELECT 0;
	END CATCH
END

GO
/****** Object:  StoredProcedure [dbo].[editScore]    Script Date: 1/4/2016 3:52:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[editScore] 
	-- Add the parameters for the stored procedure here
	@eduLevel varchar(50),
	@fieldName varchar(20),
	@fieldVal int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
	
	IF @fieldName = 'base'
	BEGIN
		UPDATE Score
		SET Base = @fieldVal
		WHERE EduLevel = @eduLevel;
	END

	ELSE IF @fieldName = 'additional'
	BEGIN
		UPDATE Score
		SET Additional = @fieldVal
		WHERE EduLevel = @eduLevel;
	END
	
	ELSE IF @fieldName = 'adding'
	BEGIN
		UPDATE Score
		SET Adding = @fieldVal
		WHERE EduLevel = @eduLevel;
	END

	ELSE IF @fieldName = 'hardness'
	BEGIN
		UPDATE Score
		SET Hardness = @fieldVal
		WHERE EduLevel = @eduLevel;
	END

	ELSE IF @fieldName = 'badClimate'
	BEGIN
		UPDATE Score
		SET BadClimate = @fieldVal
		WHERE EduLevel = @eduLevel;
	END

	ELSE IF @fieldName = 'familyScore'
	BEGIN
		UPDATE Score
		SET FamilyScore = @fieldVal
		WHERE EduLevel = @eduLevel;
	END

	ELSE IF @fieldName = 'children'
	BEGIN
		UPDATE Score
		SET Children = @fieldVal
		WHERE EduLevel = @eduLevel;
	END

	ELSE IF @fieldName = 'years'
	BEGIN
		UPDATE Score
		SET Years = @fieldVal
		WHERE EduLevel = @eduLevel;
	END

		SELECT 1;
	END TRY
	BEGIN CATCH
		SELECT 0;
	END CATCH

END

GO
/****** Object:  StoredProcedure [dbo].[getBackup]    Script Date: 1/4/2016 3:52:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[getBackup] 
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @name VARCHAR(50) -- database name  
	DECLARE @path VARCHAR(256) -- path for backup files  
	DECLARE @fileName VARCHAR(256) -- filename for backup  
	DECLARE @fileDate VARCHAR(20) -- used for file name 

	SET @path = 'C:\officeAutomation\Backup\'  

	SELECT @fileDate = CONVERT(VARCHAR(20),GETDATE(),112) 

	DECLARE db_cursor CURSOR FOR  
	SELECT name 
	FROM MASTER.dbo.sysdatabases 
	WHERE name = 'officeAutomation'  

	OPEN db_cursor   
	FETCH NEXT FROM db_cursor INTO @name   

	WHILE @@FETCH_STATUS = 0   
	BEGIN   
		   SET @fileName = @path + @name + '_' + @fileDate + '.BAK'  
		   BACKUP DATABASE @name TO DISK = @fileName  

		   FETCH NEXT FROM db_cursor INTO @name   
	END   

	CLOSE db_cursor   
	DEALLOCATE db_cursor
END

GO
USE [master]
GO
ALTER DATABASE [OfficeAutomation] SET  READ_WRITE 
GO
