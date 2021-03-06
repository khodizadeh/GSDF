USE [master]
GO
/****** Object:  Database [Aircrash]    Script Date: 3/12/2020 1:11:21 AM ******/
CREATE DATABASE [Aircrash]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Kaggle', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\Kaggle.mdf' , SIZE = 279552KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'Kaggle_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\Kaggle_log.ldf' , SIZE = 688384KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [Aircrash] SET COMPATIBILITY_LEVEL = 120
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Aircrash].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [Aircrash] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [Aircrash] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [Aircrash] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [Aircrash] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [Aircrash] SET ARITHABORT OFF 
GO
ALTER DATABASE [Aircrash] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [Aircrash] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [Aircrash] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [Aircrash] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [Aircrash] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [Aircrash] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [Aircrash] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [Aircrash] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [Aircrash] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [Aircrash] SET  DISABLE_BROKER 
GO
ALTER DATABASE [Aircrash] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [Aircrash] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [Aircrash] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [Aircrash] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [Aircrash] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [Aircrash] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [Aircrash] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [Aircrash] SET RECOVERY FULL 
GO
ALTER DATABASE [Aircrash] SET  MULTI_USER 
GO
ALTER DATABASE [Aircrash] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [Aircrash] SET DB_CHAINING OFF 
GO
ALTER DATABASE [Aircrash] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [Aircrash] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
ALTER DATABASE [Aircrash] SET DELAYED_DURABILITY = DISABLED 
GO
EXEC sys.sp_db_vardecimal_storage_format N'Aircrash', N'ON'
GO
USE [Aircrash]
GO
/****** Object:  UserDefinedFunction [dbo].[GetSiteFullName]    Script Date: 3/12/2020 1:11:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<M. Khodizadeh,,Name>
-- Create date: <2019-05-02>
-- Description:	<Get Full Location Description>
-- =============================================
CREATE FUNCTION [dbo].[GetSiteFullName]
(
	@idLoc int
)
RETURNS nvarchar(4000)
AS
BEGIN
	
	
  
    
   declare  cur1 cursor for 
   select rest from location where id = @idLoc



   declare @r nvarchar(400)
   declare @s nvarchar(4000) = ''

   open cur1 
   FETCH NEXT FROM cur1   
   INTO @r 
        
    
   
    
    WHILE @@FETCH_STATUS = 0 
	BEGIN
	    If @s <> '' set  @s = @s + ', '
        set @s = @s + @r

		FETCH NEXT FROM cur1   
		INTO @r 
        
    END
    
    
    Return @s
    

END


GO
/****** Object:  UserDefinedFunction [dbo].[LevSim]    Script Date: 3/12/2020 1:11:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<M. Khodizadeh>
-- Create date: <2019-05-26>
-- Description:	<Calc string Edit Similarity based on Levenshtein Distance >
-- =============================================
create  FUNCTION [dbo].[LevSim]
(
	@S1 nvarchar(400) , @S2 nvarchar(400)
)
RETURNS real

AS
BEGIN

declare @ml int

If Len(@S1) > Len(@S2)   set @ml = Len(@S1)
				 Else    set @ml = Len(@S2)

    


RETURN  1 - dbo.Levenshtein(@S1, @S2, 400) / cast(@ml as real ) 


END


GO
/****** Object:  UserDefinedFunction [dbo].[replaceUnderLine]    Script Date: 3/12/2020 1:11:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[replaceUnderLine] 
(
	@s nvarchar(4000)
)
RETURNS nvarchar(4000)
AS
BEGIN
	
    declare @t As nvarchar(4000)
	declare @i int 
    
    set @t = ''
	set @i= 1 
    
    while  @i <= Len(@s)
	begin
            If Substring(@s, @i, 1) <> '_' set  @t = @t + substring(@s, @i, 1)
            Else   set @t = @t + ' '
            
			set @i=@i+1
                
    end

	RETURN @t

END


GO
/****** Object:  Table [dbo].[GeoFound]    Script Date: 3/12/2020 1:11:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GeoFound](
	[Location] [nvarchar](255) NULL,
	[sid] [int] NULL,
	[eid] [int] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Location]    Script Date: 3/12/2020 1:11:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Location](
	[id] [int] NULL,
	[Location] [nvarchar](255) NULL,
	[Prefix] [nvarchar](255) NULL,
	[Rest] [nvarchar](255) NULL,
	[Rest2] [nvarchar](255) NULL,
	[Rest3] [nvarchar](255) NULL,
	[Postfix] [nvarchar](255) NULL,
	[Infix] [nvarchar](255) NULL
) ON [PRIMARY]

GO
/****** Object:  UserDefinedFunction [dbo].[LocationSEid]    Script Date: 3/12/2020 1:11:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<M. Khodizaeh>
-- Create date: <2019-05-02>
-- Description:	<Return range of found loaction>
-- =============================================
CREATE FUNCTION [dbo].[LocationSEid]
(	
	@idLoc int
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT	Location.ID, Location.Location, 
			Min(GeoFound.sid) AS sid, Min(GeoFound.eid) AS eid
	FROM Location INNER JOIN GeoFound 
	ON dbo.replaceUnderLine(Location.Location)= GeoFound.Location
	GROUP BY Location.ID, Location.Location
	HAVING Location.ID=@idLoc

)


GO
/****** Object:  Table [dbo].[GeonameMain]    Script Date: 3/12/2020 1:11:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GeonameMain](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[toponymName] [nvarchar](255) NULL,
	[name] [nvarchar](255) NULL,
	[lat] [nvarchar](255) NULL,
	[lng] [nvarchar](255) NULL,
	[geonameId] [nvarchar](255) NULL,
	[countryCode] [nvarchar](255) NULL,
	[countryName] [nvarchar](255) NULL,
	[fcl] [nvarchar](255) NULL,
	[fcode] [nvarchar](255) NULL,
	[inTop20] [nvarchar](1) NULL
) ON [PRIMARY]

GO
/****** Object:  UserDefinedFunction [dbo].[LocationFound]    Script Date: 3/12/2020 1:11:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<M. Khodizaeh>
-- Create date: <2019-05-02>
-- Description:	<Return all result for a gien location>
-- =============================================
CREATE FUNCTION [dbo].[LocationFound]
(	
	@idLoc int
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT	LocationSEid.*, 
			geonameMain.toponymName, 
			geonameMain.name, 
			cast ([geonameId] as int) AS gid
	FROM dbo.LocationSEid(@idLoc) LocationSEid, geonameMain
	WHERE LocationSEid.eid>=[geonameMain].[id]
	AND LocationSEid.sid<=[geonameMain].[id]


)


GO
/****** Object:  Table [dbo].[AlternativeName]    Script Date: 3/12/2020 1:11:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AlternativeName](
	[geonameId] [int] NULL,
	[alternativeName] [nvarchar](255) NULL
) ON [PRIMARY]

GO
/****** Object:  UserDefinedFunction [dbo].[LocationFoundAlternative]    Script Date: 3/12/2020 1:11:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<M. Khodizaeh>
-- Create date: <2019-05-02>
-- Description:	<Add Alternative Names to found location>
-- =============================================
Create FUNCTION [dbo].[LocationFoundAlternative]
(	
	@idLoc int
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT LocationFound.*, alternativeName.alternativeName
	FROM dbo.LocationFound(@idLoc) LocationFound LEFT JOIN alternativeName 
	ON LocationFound.gid = alternativeName.geonameId



)


GO
/****** Object:  UserDefinedFunction [dbo].[LocationFound gid]    Script Date: 3/12/2020 1:11:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<M. Khodizaeh>
-- Create date: <2019-05-02>
-- Description:	<Return unique id from found location>
-- =============================================
Create FUNCTION [dbo].[LocationFound gid]
(	
	@idLoc int
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT LocationFoundAlternative.gid 
	FROM dbo.LocationFoundAlternative(@idLoc) LocationFoundAlternative
	GROUP BY LocationFoundAlternative.gid




)


GO
/****** Object:  Table [dbo].[GeonameHier]    Script Date: 3/12/2020 1:11:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GeonameHier](
	[inc] [nvarchar](255) NULL,
	[geonameIdMain] [int] NULL,
	[sid] [int] NULL,
	[eid] [int] NULL,
	[id] [nvarchar](255) NULL,
	[toponymName] [nvarchar](255) NULL,
	[name] [nvarchar](255) NULL,
	[lat] [real] NULL,
	[lng] [real] NULL,
	[geonameId] [nvarchar](255) NULL,
	[countryCode] [nvarchar](50) NULL,
	[countryName] [nvarchar](255) NULL,
	[fcl] [nvarchar](50) NULL,
	[fcode] [nvarchar](50) NULL
) ON [PRIMARY]

GO
/****** Object:  UserDefinedFunction [dbo].[LocationFound Hier]    Script Date: 3/12/2020 1:11:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<M. Khodizaeh>
-- Create date: <2019-05-02>
-- Description:	<get hierarchy info for found location>
-- =============================================
CREATE FUNCTION [dbo].[LocationFound Hier]
(	
	@idLoc int
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT GeoNameHier.*
	FROM dbo.[LocationFound gid](@idLoc) [LocationFound gid] 
	INNER JOIN GeoNameHier 
	ON [LocationFound gid].gid = cast (GeoNameHier.geonameIdMain as int)




)


GO
/****** Object:  UserDefinedFunction [dbo].[LocationFound HierTable]    Script Date: 3/12/2020 1:11:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<M. Khodizaeh>
-- Create date: <2019-05-02>
-- Description:	<get hierarchy info for found location>
-- =============================================
Create FUNCTION [dbo].[LocationFound HierTable]
(	
	@idLoc int
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT	cast ([geonameIdMain] as int) AS gidMain, 
			[LocationFound Hier].* 
 	FROM dbo.[LocationFound Hier](@idLoc) [LocationFound Hier]





)


GO
/****** Object:  UserDefinedFunction [dbo].[LocationFound AllNames]    Script Date: 3/12/2020 1:11:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<M. Khodizaeh>
-- Create date: <2019-05-02>
-- Description:	<Get all names ( Main name , Alternative name , Hierarchy Location Name) for found location>
-- =============================================
CREATE FUNCTION [dbo].[LocationFound AllNames]
(	
	@idLoc int
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT	LocationFoundAlternative.ID, 
			LocationFoundAlternative.Location, 
			LocationFoundAlternative.gid, 
			LocationFoundAlternative.toponymName, 
			LocationFoundAlternative.name, 
			LocationFoundAlternative.alternativeName, 
			[LocationFound HierTable].toponymName AS toponymNameHier, 
			[LocationFound HierTable].name AS nameHier
	FROM dbo.LocationFoundAlternative(@idLoc) LocationFoundAlternative 
	LEFT JOIN dbo.[LocationFound HierTable](@idLoc) [LocationFound HierTable]
	ON LocationFoundAlternative.gid = [LocationFound HierTable].gidMain




)


GO
/****** Object:  UserDefinedFunction [dbo].[LocationFound AllNamesUnion]    Script Date: 3/12/2020 1:11:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<M. Khodizaeh>
-- Create date: <2019-05-02>
-- Description:	<Union  all names ( Main name , Alternative name , Hierarchy Location Name) for found location>
-- =============================================
CREATE FUNCTION [dbo].[LocationFound AllNamesUnion]
(	
	@idLoc int
)
RETURNS TABLE 
AS
RETURN 
(
		
		SELECT [LocationFound AllNames].ID, [LocationFound AllNames].gid, [LocationFound AllNames].toponymName , 2 as zarib
		FROM dbo.[LocationFound AllNames](@idLoc) [LocationFound AllNames]
		
		union
		SELECT [LocationFound AllNames].ID, [LocationFound AllNames].gid, [LocationFound AllNames].name , 2 as zarib
		FROM dbo.[LocationFound AllNames](@idLoc) [LocationFound AllNames]
		
		union 
		SELECT [LocationFound AllNames].ID, [LocationFound AllNames].gid, [LocationFound AllNames].alternativeName , 1.5 as zarib
		FROM dbo.[LocationFound AllNames](@idLoc) [LocationFound AllNames]
		
		union 
		SELECT [LocationFound AllNames].ID, [LocationFound AllNames].gid,  [LocationFound AllNames].toponymNameHier ,1 as zarib
		FROM dbo.[LocationFound AllNames](@idLoc) [LocationFound AllNames]

		UNION 
		
		SELECT [LocationFound AllNames].ID, [LocationFound AllNames].gid,  [LocationFound AllNames].nameHier , 1 as zarib
		FROM dbo.[LocationFound AllNames](@idLoc) [LocationFound AllNames]
)

GO
/****** Object:  UserDefinedFunction [dbo].[LocationFoundMaxCovering]    Script Date: 3/12/2020 1:11:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<M. Khodizaeh>
-- Create date: <2019-05-02>
-- Description:	<Calculate Lev Similarity for all type of names>
-- =============================================
Create FUNCTION [dbo].[LocationFoundMaxCovering]
(	
	@idLoc int
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT Q.* , case when [Lev]>0.65 then [Lev] else 0 end * [zarib] AS LevEffective
	from 
	(
	
		SELECT	[LocationFound AllNamesUnion].ID, 
				LocationSEid.Location, 
				[LocationFound AllNamesUnion].gid, 
				[LocationFound AllNamesUnion].toponymName, 
				dbo.LevSim([Location],[toponymName]) AS Lev,
				Zarib

		FROM [dbo].[LocationFound AllNamesUnion](@idLoc) [LocationFound AllNamesUnion]
		INNER JOIN dbo.LocationSEid(@idLoc)  LocationSEid 
		ON [LocationFound AllNamesUnion].ID = LocationSEid.ID
		WHERE [LocationFound AllNamesUnion].toponymName Is Not Null
	) Q




)


GO
/****** Object:  UserDefinedFunction [dbo].[LocationFoundMaxCoveringSum]    Script Date: 3/12/2020 1:11:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<M. Khodizaeh>
-- Create date: <2019-05-02>
-- Description:	<Sum Lev Similarity for ech result>
-- =============================================
create FUNCTION [dbo].[LocationFoundMaxCoveringSum]
(	
	@idLoc int
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT LocationFoundMaxCovering.ID, 
			LocationFoundMaxCovering.gid, 
			Sum(LocationFoundMaxCovering.LevEffective) AS SumLevEffective
	FROM dbo.LocationFoundMaxCovering(@idLoc) LocationFoundMaxCovering
	GROUP BY LocationFoundMaxCovering.ID, LocationFoundMaxCovering.gid




)


GO
/****** Object:  UserDefinedFunction [dbo].[LocationFoundMaxCoveringSumMax]    Script Date: 3/12/2020 1:11:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<M. Khodizaeh>
-- Create date: <2019-05-02>
-- Description:	<Max of Lev Similarity for ech result>
-- =============================================
create FUNCTION [dbo].[LocationFoundMaxCoveringSumMax]
(	
	@idLoc int
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT  LocationFoundMaxCoveringSum.ID, 
			Max(LocationFoundMaxCoveringSum.SumLevEffective) AS MaxSumLevEffective
	FROM dbo.LocationFoundMaxCoveringSum(@idLoc) LocationFoundMaxCoveringSum
	GROUP BY LocationFoundMaxCoveringSum.ID

	



)


GO
/****** Object:  UserDefinedFunction [dbo].[MaxCovering]    Script Date: 3/12/2020 1:11:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<M. Khodizaeh>
-- Create date: <2019-05-02>
-- Description:	<Max Covering>
-- =============================================
CREATE  FUNCTION [dbo].[MaxCovering]
(	
	@idLoc int
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT LocationFoundMaxCoveringSumMax.ID, 
			dbo.getSiteFullName([LocationFoundMaxCoveringSumMax].[id]) AS MainName, 
			LocationFoundMaxCoveringSum.gid, 
			LocationFound.toponymName, 
			LocationFound.name
	FROM dbo.LocationFoundMaxCoveringSumMax(@idLoc) LocationFoundMaxCoveringSumMax
	INNER JOIN dbo.LocationFoundMaxCoveringSum(@idLoc) LocationFoundMaxCoveringSum
	ON LocationFoundMaxCoveringSumMax.MaxSumLevEffective = LocationFoundMaxCoveringSum.SumLevEffective
	INNER JOIN dbo.LocationFound(@idLoc) LocationFound ON LocationFoundMaxCoveringSum.gid = LocationFound.gid
	GROUP BY LocationFoundMaxCoveringSumMax.ID, 
	dbo.getSiteFullName([LocationFoundMaxCoveringSumMax].[id]), LocationFoundMaxCoveringSum.gid, LocationFound.toponymName, LocationFound.name


	



)


GO
/****** Object:  UserDefinedFunction [dbo].[Levenshtein]    Script Date: 3/12/2020 1:11:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Computes and returns the Levenshtein edit distance between two strings, i.e. the
-- number of insertion, deletion, and sustitution edits required to transform one
-- string to the other, or NULL if @max is exceeded. Comparisons use the case-
-- sensitivity configured in SQL Server (case-insensitive by default).
-- 
-- Based on Sten Hjelmqvist's "Fast, memory efficient" algorithm, described
-- at http://www.codeproject.com/Articles/13525/Fast-memory-efficient-Levenshtein-algorithm,
-- with some additional optimizations.
-- =============================================
Create FUNCTION [dbo].[Levenshtein](
    @s nvarchar(4000)
  , @t nvarchar(4000)
  , @max int
)
RETURNS int
WITH SCHEMABINDING
AS
BEGIN
    DECLARE @distance int = 0 -- return variable
          , @v0 nvarchar(4000)-- running scratchpad for storing computed distances
          , @start int = 1      -- index (1 based) of first non-matching character between the two string
          , @i int, @j int      -- loop counters: i for s string and j for t string
          , @diag int          -- distance in cell diagonally above and left if we were using an m by n matrix
          , @left int          -- distance in cell to the left if we were using an m by n matrix
          , @sChar nchar      -- character at index i from s string
          , @thisJ int          -- temporary storage of @j to allow SELECT combining
          , @jOffset int      -- offset used to calculate starting value for j loop
          , @jEnd int          -- ending value for j loop (stopping point for processing a column)
          -- get input string lengths including any trailing spaces (which SQL Server would otherwise ignore)
          , @sLen int = datalength(@s) / datalength(left(left(@s, 1) + '.', 1))    -- length of smaller string
          , @tLen int = datalength(@t) / datalength(left(left(@t, 1) + '.', 1))    -- length of larger string
          , @lenDiff int      -- difference in length between the two strings
    -- if strings of different lengths, ensure shorter string is in s. This can result in a little
    -- faster speed by spending more time spinning just the inner loop during the main processing.
    IF (@sLen > @tLen) BEGIN
        SELECT @v0 = @s, @i = @sLen -- temporarily use v0 for swap
        SELECT @s = @t, @sLen = @tLen
        SELECT @t = @v0, @tLen = @i
    END
    SELECT @max = ISNULL(@max, @tLen)
         , @lenDiff = @tLen - @sLen
    IF @lenDiff > @max RETURN NULL

    -- suffix common to both strings can be ignored
    WHILE(@sLen > 0 AND SUBSTRING(@s, @sLen, 1) = SUBSTRING(@t, @tLen, 1))
        SELECT @sLen = @sLen - 1, @tLen = @tLen - 1

    IF (@sLen = 0) RETURN @tLen

    -- prefix common to both strings can be ignored
    WHILE (@start < @sLen AND SUBSTRING(@s, @start, 1) = SUBSTRING(@t, @start, 1)) 
        SELECT @start = @start + 1
    IF (@start > 1) BEGIN
        SELECT @sLen = @sLen - (@start - 1)
             , @tLen = @tLen - (@start - 1)

        -- if all of shorter string matches prefix and/or suffix of longer string, then
        -- edit distance is just the delete of additional characters present in longer string
        IF (@sLen <= 0) RETURN @tLen

        SELECT @s = SUBSTRING(@s, @start, @sLen)
             , @t = SUBSTRING(@t, @start, @tLen)
    END

    -- initialize v0 array of distances
    SELECT @v0 = '', @j = 1
    WHILE (@j <= @tLen) BEGIN
        SELECT @v0 = @v0 + NCHAR(CASE WHEN @j > @max THEN @max ELSE @j END)
        SELECT @j = @j + 1
    END

    SELECT @jOffset = @max - @lenDiff
         , @i = 1
    WHILE (@i <= @sLen) BEGIN
        SELECT @distance = @i
             , @diag = @i - 1
             , @sChar = SUBSTRING(@s, @i, 1)
             -- no need to look beyond window of upper left diagonal (@i) + @max cells
             -- and the lower right diagonal (@i - @lenDiff) - @max cells
             , @j = CASE WHEN @i <= @jOffset THEN 1 ELSE @i - @jOffset END
             , @jEnd = CASE WHEN @i + @max >= @tLen THEN @tLen ELSE @i + @max END
        WHILE (@j <= @jEnd) BEGIN
            -- at this point, @distance holds the previous value (the cell above if we were using an m by n matrix)
            SELECT @left = UNICODE(SUBSTRING(@v0, @j, 1))
                 , @thisJ = @j
            SELECT @distance = 
                CASE WHEN (@sChar = SUBSTRING(@t, @j, 1)) THEN @diag                    --match, no change
                     ELSE 1 + CASE WHEN @diag < @left AND @diag < @distance THEN @diag    --substitution
                                   WHEN @left < @distance THEN @left                    -- insertion
                                   ELSE @distance                                        -- deletion
                                END    END
            SELECT @v0 = STUFF(@v0, @thisJ, 1, NCHAR(@distance))
                 , @diag = @left
                 , @j = case when (@distance > @max) AND (@thisJ = @i + @lenDiff) then @jEnd + 2 else @thisJ + 1 end
        END
        SELECT @i = CASE WHEN @j > @jEnd + 1 THEN @sLen + 1 ELSE @i + 1 END
    END
    RETURN CASE WHEN @distance <= @max THEN @distance ELSE NULL END
END





GO
/****** Object:  Table [dbo].[SourceData]    Script Date: 3/12/2020 1:11:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SourceData](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Date] [datetime] NULL,
	[Time] [nvarchar](255) NULL,
	[Location] [nvarchar](255) NULL,
	[Operator] [nvarchar](255) NULL,
	[Flight #] [nvarchar](255) NULL,
	[Route] [nvarchar](255) NULL,
	[Type] [nvarchar](255) NULL,
	[Registration] [nvarchar](255) NULL,
	[cn/In] [nvarchar](255) NULL,
	[Aboard] [int] NULL,
	[Fatalities] [int] NULL,
	[Ground] [int] NULL,
	[Summary] [nvarchar](255) NULL
) ON [PRIMARY]

GO
/****** Object:  StoredProcedure [dbo].[SP_GranularMaxCovering]    Script Date: 3/12/2020 1:11:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<M. Khodizadeh>
-- Create date: <2019-05-02>
-- Description:	<Show result of geocoding>
-- =============================================
CREATE PROCEDURE [dbo].[SP_GranularMaxCovering]
	@idLoc int 
AS
BEGIN
	select * from [dbo].[MaxCovering](@idLoc)
END


GO
USE [master]
GO
ALTER DATABASE [Aircrash] SET  READ_WRITE 
GO
