USE [master]
GO
/****** Object:  Database [GSDF]    Script Date: 3/12/2020 1:09:44 AM ******/
CREATE DATABASE [GSDF]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'DFV2', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\DFV2.mdf' , SIZE = 121856KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'DFV2_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\DFV2_log.ldf' , SIZE = 291904KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [GSDF] SET COMPATIBILITY_LEVEL = 120
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [GSDF].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [GSDF] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [GSDF] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [GSDF] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [GSDF] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [GSDF] SET ARITHABORT OFF 
GO
ALTER DATABASE [GSDF] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [GSDF] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [GSDF] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [GSDF] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [GSDF] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [GSDF] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [GSDF] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [GSDF] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [GSDF] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [GSDF] SET  DISABLE_BROKER 
GO
ALTER DATABASE [GSDF] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [GSDF] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [GSDF] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [GSDF] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [GSDF] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [GSDF] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [GSDF] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [GSDF] SET RECOVERY FULL 
GO
ALTER DATABASE [GSDF] SET  MULTI_USER 
GO
ALTER DATABASE [GSDF] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [GSDF] SET DB_CHAINING OFF 
GO
ALTER DATABASE [GSDF] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [GSDF] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
ALTER DATABASE [GSDF] SET DELAYED_DURABILITY = DISABLED 
GO
EXEC sys.sp_db_vardecimal_storage_format N'GSDF', N'ON'
GO
USE [GSDF]
GO
/****** Object:  UserDefinedFunction [dbo].[calcGeoDistance]    Script Date: 3/12/2020 1:09:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[calcGeoDistance](
	@lat1 float, 
	@lng1 float,
	@lat2 float, 
	@lng2 float
)
RETURNS int
AS
BEGIN


DECLARE @g1 geography
DECLARE @g2 geography



declare @s nvarchar(100)
set @s='POINT('+cast(@lng1 as nvarchar(20)) + ' ' + cast(@lat1 as nvarchar(20))+ ')' 


declare @t nvarchar(100)
set @t='POINT('+cast(@lng2 as nvarchar(20)) + ' ' + cast(@lat2 as nvarchar(20))+ ')' 




set @g1=geography::STPointFromText(@s,4326)
set @g2=geography::STPointFromText(@t,4326)

return @g1.STDistance(@g2) /1000

END
GO
/****** Object:  UserDefinedFunction [dbo].[fn_HaveGap]    Script Date: 3/12/2020 1:09:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<M. Khodizadeh>
-- Create date: <2019-05-20>
-- Description:	<Blocking the Data>
-- =============================================
CREATE FUNCTION [dbo].[fn_HaveGap] 
(
	@idAir int, @idDbp int
)
RETURNS tinyint

AS
BEGIN
	

	declare @c1 char(2) , @c2 char(2)
	declare @airLat real, @airLng real, @dbpLat real, @dbpLng real

	-- airdbpCountryLocInfo Query
	SELECT 
	 
	 @c1=finalresultAirCrash.countryCode , 
	 @airLat=finalresultAirCrash.lat , 
	 @airLng=finalresultAirCrash.lng , 
	 
	 
	 @c2=finalresultDBPedia.countryCode , 
	 @dbpLat=finalresultDBPedia.lat ,
	 @dbpLng=finalresultDBPedia.lng 
	FROM finalresultAirCrash, finalresultDBPedia
	WHERE finalresultAirCrash.geoFoundId=@idAir
	AND finalresultDBPedia.geoFoundId=@idDbp
 
	declare @haveGap tinyint 

    If @c1 = @c2 RETURN 0
        
	--------------------


    -- NeighbourCheck Query
	declare @NG tinyint

	SELECT @NG=Count(Neighbours.NeighbourCode) 
	
	FROM finalresultDBPedia 
	INNER JOIN (finalresultAirCrash INNER JOIN Neighbours 
				ON finalresultAirCrash.countryCode = Neighbours.CountryCode) 
	ON finalresultDBPedia.countryCode = Neighbours.NeighbourCode
	GROUP BY finalresultAirCrash.geoFoundId, finalresultDBPedia.geoFoundId
	HAVING finalresultAirCrash.geoFoundId=@idAir
	AND finalresultDBPedia.geoFoundId=@idDbp

    
	If @NG  is null   RETURN 1
       
    
	------------------
    
    If Abs(@airLat - @dbpLat) > 1  RETURN 1       
    
	
	--------------------
	declare @d int
	select @d=dbo.calcGeoDistance(Cast(@airLat as real), Cast(@airLng as real), Cast(@dbpLat as real), Cast(@dbpLng as real) )
    If   @d > 150  RETURN 1
              
   
    
   
 
   RETURN 0





END

GO
/****** Object:  UserDefinedFunction [dbo].[HierCommonFinal]    Script Date: 3/12/2020 1:09:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<M. Khodizadeh>
-- Create date: <2019-05-26>
-- Description:	<Count Hier Common Item>
-- =============================================
CREATE FUNCTION [dbo].[HierCommonFinal]
(
		@idAir int, @idDbp int
)
RETURNS real

	AS
	BEGIN

	declare @CommCount tinyint, @DBPCount tinyint , @AirCount tinyint	

	
	SELECT @AirCount=Count(HierAir.TPN) 
	FROM (
			SELECT Cast([GeonameHier].[toponymName] as nvarchar(1000) ) AS TPN
			FROM finalresultAirCrash INNER JOIN GeonameHier 
			ON finalresultAirCrash.geonameId = GeonameHier.geonameIdMain
			GROUP BY Cast([GeonameHier].[toponymName] as nvarchar(1000) ), finalresultAirCrash.geoFoundId
			HAVING finalresultAirCrash.geoFoundId=@idAir

	) HierAir





	SELECT @DBPCount=Count(HierDBP.TPN)
	FROM (

			SELECT Cast([GeonameHier].[toponymName] as nvarchar(1000) ) AS TPN
			FROM GeonameHier INNER JOIN finalresultDBPedia ON GeonameHier.geonameIdMain = finalresultDBPedia.geonameId
			GROUP BY Cast([GeonameHier].[toponymName] as nvarchar(1000) ), finalresultDBPedia.geoFoundId
			HAVING finalresultDBPedia.geoFoundId=@idDbp

	) HierDBP



	SELECT @CommCount= Count(HierAir.TPN)
	FROM (

			SELECT Cast([GeonameHier].[toponymName] as nvarchar(1000) ) AS TPN
			FROM finalresultAirCrash INNER JOIN GeonameHier 
			ON finalresultAirCrash.geonameId = GeonameHier.geonameIdMain
			GROUP BY Cast([GeonameHier].[toponymName] as nvarchar(1000) ), finalresultAirCrash.geoFoundId
			HAVING finalresultAirCrash.geoFoundId=@idAir

	)
	HierAir INNER JOIN (
			SELECT Cast([GeonameHier].[toponymName] as nvarchar(1000) ) AS TPN
			FROM GeonameHier INNER JOIN finalresultDBPedia ON GeonameHier.geonameIdMain = finalresultDBPedia.geonameId
			GROUP BY Cast([GeonameHier].[toponymName] as nvarchar(1000) ), finalresultDBPedia.geoFoundId
			HAVING finalresultDBPedia.geoFoundId=@idDbp
	)
	HierDBP ON HierAir.TPN = HierDBP.TPN


	   RETURN cast(@CommCount as real) / case when @DBPCount<@AirCount then @DBPCount else @AirCount end 





END

GO
/****** Object:  UserDefinedFunction [dbo].[LevSim]    Script Date: 3/12/2020 1:09:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<M. Khodizadeh>
-- Create date: <2019-05-26>
-- Description:	<Calc string Edit Similarity based on Levenshtein Distance >
-- =============================================
CREATE FUNCTION [dbo].[LevSim]
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
/****** Object:  UserDefinedFunction [dbo].[selectedFinalSim2]    Script Date: 3/12/2020 1:09:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<M. Khodizadeh>
-- Create date: <2019-05-27>
-- Description:	<Calculte Final Similarity>
-- =============================================
Create  FUNCTION [dbo].[selectedFinalSim2]
(
	@DS real, @GS real , @LV real

)
RETURNS real

AS
BEGIN

	declare @Mx real , @Mn real , @T real
    If @DS > @GS 
    begin
	    set @Mx = @DS
        set @Mn = @GS
    end
	else
	begin 
	    set @Mx = @GS
        set @Mn = @DS
    end 
    
    set @T = (@Mx * 0.7 + @Mn * 0.3)
    
    If @T > 0.6 
        If @LV > @T  RETURN @T * 0.5 + @LV * 0.5
        Else         RETURN @T * 0.9 + @LV * 0.1
        
    Else             RETURN @T * 0.7 + @LV * 0.3 


	RETURN 0


END

GO
/****** Object:  UserDefinedFunction [dbo].[ToponymSim]    Script Date: 3/12/2020 1:09:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<M. Khodizadeh>
-- Create date: <2019-05-27>
-- Description:	<Calculte Toponym Similarity>
-- =============================================
CREATE FUNCTION [dbo].[ToponymSim]
(
	@idAir int, @idDbp int
)
RETURNS real

AS
BEGIN

   declare @airToponymName Table	( TName nvarchar(400) )

   insert into @airToponymName
   select ToponymName
   from finalresultAirCrash
   where geoFoundID=@idAir
   union
   select name
   from finalresultAirCrash
   where geoFoundID=@idAir
   union 
   select cast(alternativeName as nvarchar(4000)) 
   from finalresultAirCrash
   inner join  airAlternativeName
   on finalresultAirCrash.geonameId= airAlternativeName.geonameId
   where geoFoundID=@idAir
   and len(cast(alternativeName as nvarchar(4000)))>0

   
   declare @dbpToponymName Table	( TName nvarchar(400) )

   insert into @dbpToponymName
   select ToponymName
   from finalresultDBPedia
   where geoFoundID=@idDbp
   union
   select name
   from finalresultDBPedia
   where geoFoundID=@idDbp
   union 
   select cast(alternativeName as nvarchar(4000)) 
   from finalresultDBPedia
   inner join  dbpAlternativeName
   on finalresultDBPedia.geonameId= dbpAlternativeName.geonameId
   where geoFoundID=@idDbp
   and len(cast(alternativeName as nvarchar(4000)))>0



   declare @MLevSim real

   select @MLevSim=max(dbo.LevSim(A.TName  , D.TName ))
   from @airToponymName A , @dbpToponymName D

   RETURN @MLevSim 




END

GO
/****** Object:  Table [dbo].[airSelected]    Script Date: 3/12/2020 1:09:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[airSelected](
	[geoFoundId] [int] IDENTITY(1,1) NOT NULL,
	[round] [int] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[dbpSelected]    Script Date: 3/12/2020 1:09:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dbpSelected](
	[geoFoundId] [int] IDENTITY(1,1) NOT NULL,
	[round] [int] NULL
) ON [PRIMARY]

GO
/****** Object:  UserDefinedFunction [dbo].[airdbpSelectedPair]    Script Date: 3/12/2020 1:09:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<M. Khodizadeh>
-- Create date: <2019-05-19>
-- Description:	<Pairing Data from AirCrash and DBPedia Datasets>
-- =============================================
CREATE FUNCTION [dbo].[airdbpSelectedPair] 
(	
	@round int
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT airSelected.geoFoundId AS airGeoFoundId, dbpSelected.geoFoundId AS dbpGeoFoundId
	FROM airSelected, dbpSelected
	WHERE airSelected.round=@round OR dbpSelected.round=@round

)

GO
/****** Object:  Table [dbo].[MapLocation]    Script Date: 3/12/2020 1:09:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MapLocation](
	[mapLocationID] [int] IDENTITY(1,1) NOT NULL,
	[Location] [nvarchar](255) NULL,
	[lat] [float] NULL,
	[lng] [float] NULL,
	[countryCode] [nvarchar](255) NULL,
	[Comment] [nvarchar](255) NULL,
	[Source] [nvarchar](255) NULL,
	[Tolerance] [int] NULL,
	[round] [int] NULL
) ON [PRIMARY]

GO
/****** Object:  View [dbo].[Z032-mapLocation Query]    Script Date: 3/12/2020 1:09:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create View [dbo].[Z032-mapLocation Query]
as
SELECT mapLocation.mapLocationID, mapLocation.Location, 
mapLocation.lat, mapLocation.lng, mapLocation.countryCode, 
mapLocation.Comment, mapLocation.Round
FROM mapLocation
WHERE mapLocation.lat Is Null OR mapLocation.lng Is Null

GO
/****** Object:  Table [dbo].[SelectedSim]    Script Date: 3/12/2020 1:09:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SelectedSim](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[airGeoFoundID] [int] NULL,
	[dbpGeoFoundID] [int] NULL,
	[ParentChild] [int] NULL,
	[Distance] [int] NULL,
	[DistSim] [float] NULL,
	[GranSim] [float] NULL,
	[LevSim] [float] NULL,
	[Gap] [tinyint] NULL,
	[Finished] [tinyint] NULL,
	[round] [int] NULL,
	[RealDistance] [int] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Threshold]    Script Date: 3/12/2020 1:09:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Threshold](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[T] [float] NULL
) ON [PRIMARY]

GO
/****** Object:  UserDefinedFunction [dbo].[MatchingCandidate]    Script Date: 3/12/2020 1:09:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<M. Khodizadeh>
-- Create date: <2019-05-27>
-- Description:	<Calculate Final Similarity>
-- =============================================
CREATE  FUNCTION [dbo].[MatchingCandidate]
(	
	@round int
	
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT selectedSim.*, 
	cast (dbo.selectedFinalSim2([DistSim],[GranSim],[LevSim]) AS REAL ) AS FinalSim, 
	Threshold.T
	FROM selectedSim, Threshold
	WHERE selectedSim.Round=@round

)

GO
/****** Object:  Table [dbo].[GroundTruth]    Script Date: 3/12/2020 1:09:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GroundTruth](
	[airGeoFoundID] [int] NULL,
	[dbpGeoFoundID] [int] NULL,
	[airMainLocation] [nvarchar](255) NULL,
	[dbpMainLocation] [nvarchar](255) NULL,
	[airlat] [float] NULL,
	[airlng] [float] NULL,
	[dbplat] [float] NULL,
	[dbplng] [float] NULL,
	[Dist] [int] NULL,
	[Match] [tinyint] NULL,
	[Fnished] [tinyint] NULL,
	[round] [int] NULL
) ON [PRIMARY]

GO
/****** Object:  View [dbo].[Z041-GroundTruth Query]    Script Date: 3/12/2020 1:09:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create View		[dbo].[Z041-GroundTruth Query]
as
SELECT	GroundTruth.airGeoFoundID, GroundTruth.dbpGeoFoundID, 
		GroundTruth.airMainLocation, GroundTruth.dbpMainLocation, 
		GroundTruth.airlat, GroundTruth.airlng, 
		GroundTruth.dbplat, GroundTruth.dbplng, 
		GroundTruth.Dist, GroundTruth.Match, GroundTruth.Fnished
FROM GroundTruth
WHERE GroundTruth.Fnished=0;


GO
/****** Object:  UserDefinedFunction [dbo].[GroundTruthMax]    Script Date: 3/12/2020 1:09:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<M. Khodizadeh>
-- Create date: <2019-05-25>
-- Description:	<Grouping Data for Unique Ground Truth>
-- =============================================
Create FUNCTION [dbo].[GroundTruthMax]
(	
	@round int
	
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT GroundTruth.airGeoFoundID, GroundTruth.dbpGeoFoundID, 
	Max(GroundTruth.Match) AS MaxOfMatch
	FROM GroundTruth
	WHERE GroundTruth.round=@round
	GROUP BY GroundTruth.airGeoFoundID, GroundTruth.dbpGeoFoundID
)

GO
/****** Object:  UserDefinedFunction [dbo].[FinalSim]    Script Date: 3/12/2020 1:09:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<M. Khodizadeh>
-- Create date: <2019-05-28>
-- Description:	<Return Final Similarity>
-- =============================================
Create FUNCTION [dbo].[FinalSim]
(	
	@round int
	
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT selectedSim.*,
	 cast (dbo.selectedFinalSim2([DistSim],[GranSim],[LevSim]) as real ) AS FinalSim,
	 Threshold.T
	FROM selectedSim, Threshold
	WHERE selectedSim.Round=@round
	

)

GO
/****** Object:  Table [dbo].[QualityMetricBulkSum]    Script Date: 3/12/2020 1:09:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[QualityMetricBulkSum](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[T] [float] NULL,
	[STP] [float] NULL,
	[SFP] [float] NULL,
	[SFN] [float] NULL,
	[Segment] [nvarchar](255) NULL
) ON [PRIMARY]

GO
/****** Object:  UserDefinedFunction [dbo].[result3]    Script Date: 3/12/2020 1:09:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<M. Khodizadeh>
-- Create date: <2019-05-28>
-- Description:	<get result from Quality Metric Segment>
-- =============================================
Create FUNCTION [dbo].[result3]
(	
	
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT QualityMetricBulkSum.T, 
		Sum(QualityMetricBulkSum.STP) AS STP, 
		Sum(QualityMetricBulkSum.SFP) AS SFP, 
		Sum(QualityMetricBulkSum.SFN) AS SFN
	FROM QualityMetricBulkSum
	GROUP BY QualityMetricBulkSum.T



)

GO
/****** Object:  Table [dbo].[QualityMetric]    Script Date: 3/12/2020 1:09:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[QualityMetric](
	[airGeoFoundID] [int] NULL,
	[finalresultAirCrash_MainLocation] [nvarchar](255) NULL,
	[dbpGeoFoundID] [int] NULL,
	[finalresultDBPedia_MainLocation] [nvarchar](255) NULL,
	[FinalSim] [float] NULL,
	[Match] [bit] NULL,
	[RP] [int] NULL,
	[Expr1] [float] NULL,
	[P] [int] NULL,
	[TP] [int] NULL,
	[FP] [int] NULL,
	[FN] [int] NULL,
	[T] [float] NULL,
	[round] [int] NULL
) ON [PRIMARY]

GO
/****** Object:  UserDefinedFunction [dbo].[result2]    Script Date: 3/12/2020 1:09:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<M. Khodizadeh>
-- Create date: <2019-05-28>
-- Description:	<sum result from Quality Metric>
-- =============================================
Create FUNCTION [dbo].[result2]
(	
	
)
RETURNS TABLE 
AS
RETURN 
(
SELECT	QualityMetric.T, 
		Sum(QualityMetric.TP) AS SumOfTP,
		Sum(QualityMetric.FP) AS SumOfFP, 
		Sum(QualityMetric.FN) AS SumOfFN
		FROM QualityMetric
		GROUP BY QualityMetric.T

)

GO
/****** Object:  Table [dbo].[airdbpCountryNull]    Script Date: 3/12/2020 1:09:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[airdbpCountryNull](
	[airgeoFoundId] [int] NULL,
	[dbpgeoFoundId] [int] IDENTITY(1,1) NOT NULL,
	[LocationName] [nvarchar](255) NULL,
	[MainLocation] [nvarchar](255) NULL,
	[Location] [nvarchar](255) NULL,
	[TP] [int] NULL,
	[FP] [int] NULL
) ON [PRIMARY]

GO
/****** Object:  UserDefinedFunction [dbo].[airdbpCountryNullUnique]    Script Date: 3/12/2020 1:09:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<M. Khodizadeh>
-- Create date: <2019-05-28>
-- Description:	<UNKNOWN COUNTRY >
-- =============================================
Create FUNCTION [dbo].[airdbpCountryNullUnique]
(	
	
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT airdbpCountryNull.airgeoFoundId, 
			airdbpCountryNull.dbpgeoFoundId, 
			airdbpCountryNull.TP, 
			airdbpCountryNull.FP
	FROM airdbpCountryNull
	GROUP BY airdbpCountryNull.airgeoFoundId, airdbpCountryNull.dbpgeoFoundId, 
			 airdbpCountryNull.TP, airdbpCountryNull.FP


)

GO
/****** Object:  UserDefinedFunction [dbo].[resultCountryNull]    Script Date: 3/12/2020 1:09:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<M. Khodizadeh>
-- Create date: <2019-05-28>
-- Description:	<Sum result of unknown country>
-- =============================================
Create FUNCTION [dbo].[resultCountryNull]
(	
	
)
RETURNS TABLE 
AS
RETURN 
(
			 SELECT Sum(airdbpCountryNullUnique.TP) AS NCTP, 
					Sum(airdbpCountryNullUnique.FP) AS NCFP
			 FROM dbo.airdbpCountryNullUnique() airdbpCountryNullUnique
)

GO
/****** Object:  UserDefinedFunction [dbo].[result1]    Script Date: 3/12/2020 1:09:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<M. Khodizadeh>
-- Create date: <2019-05-28>
-- Description:	<Aggregte result Current+Segment+Unknown Country>
-- =============================================
Create FUNCTION [dbo].[result1]
(	
	
)
RETURNS TABLE 
AS
RETURN 
(
			SELECT result3.T, 
					isnull([SumOfTP],0)+[STP]+[NCTP] AS NSTP, 
					isnull([SumOfFP],0)+[SFP]+[NCFP] AS NSFP, 
					isnull([SumOfFN],0)+[SFN] AS NSFN
			FROM dbo.resultCountryNull() resultCountryNull, 
				 dbo.result2()  result2
			INNER JOIN dbo.result3() result3 
			ON result2.T = result3.T

)

GO
/****** Object:  UserDefinedFunction [dbo].[result]    Script Date: 3/12/2020 1:09:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<M. Khodizadeh>
-- Create date: <2019-05-28>
-- Description:	<Calculate Precision, Recall, FScore>
-- =============================================
Create FUNCTION [dbo].[result]
(	
	
)
RETURNS TABLE 
AS
RETURN 
(
	Select Q.*, 2*[Precision]*[Recall]/([Precision]+[Recall]) AS FScore
	From(
			SELECT result1.T, result1.NSTP, 
					result1.NSFP, result1.NSFN, 
					[NSTP]/([NSTP]+[NSFP]) AS [Precision],
					[NSTP]/([NSTP]+[NSFN]) AS Recall
			FROM dbo.result1() result1
	)Q


)

GO
/****** Object:  UserDefinedFunction [dbo].[Levenshtein]    Script Date: 3/12/2020 1:09:44 AM ******/
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
CREATE FUNCTION [dbo].[Levenshtein](
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
/****** Object:  Table [dbo].[airAlternativeName]    Script Date: 3/12/2020 1:09:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[airAlternativeName](
	[geonameId] [int] NULL,
	[alternativeName] [nvarchar](4000) NULL
) ON [PRIMARY]

GO
/****** Object:  Index [IX_airAlternativeName]    Script Date: 3/12/2020 1:09:44 AM ******/
CREATE CLUSTERED INDEX [IX_airAlternativeName] ON [dbo].[airAlternativeName]
(
	[geonameId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[airdbpParentChild]    Script Date: 3/12/2020 1:09:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[airdbpParentChild](
	[airGeoFoundID] [int] NULL,
	[dbpGeoFoundID] [int] NULL,
	[inc] [int] IDENTITY(1,1) NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[dbpAlternativeName]    Script Date: 3/12/2020 1:09:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dbpAlternativeName](
	[geonameId] [int] NULL,
	[alternativeName] [nvarchar](4000) NULL
) ON [PRIMARY]

GO
/****** Object:  Index [IX_dbpAlternativeName]    Script Date: 3/12/2020 1:09:44 AM ******/
CREATE CLUSTERED INDEX [IX_dbpAlternativeName] ON [dbo].[dbpAlternativeName]
(
	[geonameId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[finalresultAirCrash]    Script Date: 3/12/2020 1:09:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[finalresultAirCrash](
	[geoFoundId] [int] IDENTITY(1,1) NOT NULL,
	[ERROR] [nvarchar](255) NULL,
	[Manual] [nvarchar](255) NULL,
	[MainLocation] [nvarchar](255) NULL,
	[Location] [nvarchar](255) NULL,
	[selectedId] [int] NULL,
	[toponymName] [nvarchar](255) NULL,
	[name] [nvarchar](255) NULL,
	[lat] [nvarchar](255) NULL,
	[lng] [nvarchar](255) NULL,
	[geonameId] [nvarchar](255) NULL,
	[countryCode] [nvarchar](255) NULL,
	[countryName] [nvarchar](255) NULL,
	[fcl] [nvarchar](255) NULL,
	[fcode] [nvarchar](255) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[finalresultDBPedia]    Script Date: 3/12/2020 1:09:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[finalresultDBPedia](
	[geoFoundId] [int] IDENTITY(1,1) NOT NULL,
	[Manual] [nvarchar](255) NULL,
	[MainLocation] [nvarchar](255) NULL,
	[Location] [nvarchar](255) NULL,
	[selectedId] [int] NULL,
	[toponymName] [nvarchar](255) NULL,
	[name] [nvarchar](255) NULL,
	[lat] [nvarchar](255) NULL,
	[lng] [nvarchar](255) NULL,
	[geonameId] [nvarchar](255) NULL,
	[countryCode] [nvarchar](255) NULL,
	[countryName] [nvarchar](255) NULL,
	[fcl] [nvarchar](255) NULL,
	[fcode] [nvarchar](255) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[GeonameHier]    Script Date: 3/12/2020 1:09:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GeonameHier](
	[geonameIdMain] [nvarchar](255) NULL,
	[toponymName] [ntext] NULL,
	[name] [ntext] NULL,
	[lat] [real] NULL,
	[lng] [real] NULL,
	[geonameId] [nvarchar](255) NULL,
	[countryCode] [nvarchar](255) NULL,
	[countryName] [ntext] NULL,
	[fcl] [nvarchar](255) NULL,
	[fcode] [nvarchar](255) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[GroundTruthUnique]    Script Date: 3/12/2020 1:09:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GroundTruthUnique](
	[airGeoFoundID] [int] NULL,
	[dbpGeoFoundID] [int] NULL,
	[Match] [tinyint] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[MapLocationGoogle]    Script Date: 3/12/2020 1:09:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MapLocationGoogle](
	[Grade] [nvarchar](255) NULL,
	[Location] [nvarchar](255) NULL,
	[lat] [nvarchar](255) NULL,
	[lng] [nvarchar](255) NULL,
	[Source] [nvarchar](255) NULL,
	[Tolerance] [int] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Neighbours]    Script Date: 3/12/2020 1:09:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Neighbours](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CountryCode] [nvarchar](255) NULL,
	[NeighbourCode] [nvarchar](255) NULL
) ON [PRIMARY]

GO
/****** Object:  StoredProcedure [dbo].[Z010-airSelected Make]    Script Date: 3/12/2020 1:09:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<M. Khodizadeh>
-- Create date: <2019-05-17>
-- Description:	<Prepare Data from AirCrash Dataset for current round>
-- =============================================
CREATE PROCEDURE [dbo].[Z010-airSelected Make]
	-- Add the parameters for the stored procedure here
	@Round int,
	@CountryCode char(2)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    INSERT INTO airSelected ( geoFoundId, [round] )
	SELECT finalresultAirCrash.geoFoundId, @Round
	FROM finalresultAirCrash
	WHERE finalresultAirCrash.countryCode=@CountryCode;


END

GO
/****** Object:  StoredProcedure [dbo].[Z011-dbpSelected Make]    Script Date: 3/12/2020 1:09:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<M. Khodizadeh>
-- Create date: <2019-05-17>
-- Description:	<Prepare Data from DBPedi Dataset for current round>
-- =============================================
CREATE PROCEDURE [dbo].[Z011-dbpSelected Make] 
	@Round int,
	@CountryCode char(2)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO dbpSelected ( geoFoundId, [round] )
	SELECT finalresultDBPedia.geoFoundId, @round
	FROM finalresultDBPedia
	WHERE finalresultDBPedia.countryCode=@CountryCode

END

GO
/****** Object:  StoredProcedure [dbo].[Z020-selectedSim Append]    Script Date: 3/12/2020 1:09:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<M. Khodizadeh>
-- Create date: <2019-05-17>
-- Description:	<Pairing Data from AirCrash and DBPedia Datasets 
--               & Blocking the Data
--               Result inserted into selectedSim Table
-- =============================================
CREATE PROCEDURE [dbo].[Z020-selectedSim Append]
	@round int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    INSERT INTO selectedSim ( airGeoFoundId, dbpGeoFoundId, Gap, [round] )
	SELECT Cast([airGeoFoundId] as int) , Cast([dbpGeoFoundId] as int),
	       dbo.fn_haveGap([airGeoFoundId],[dbpGeoFoundId]) ,
		   @round
	FROM dbo.airdbpSelectedPair(@round)


END

GO
/****** Object:  StoredProcedure [dbo].[Z030-airMapLocation Append]    Script Date: 3/12/2020 1:09:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<M. Khodizadeh>
-- Create date: <2019-05-22>
-- Description:	<Add AirCrash location info from GoogleMap Data>
-- =============================================
CREATE PROCEDURE [dbo].[Z030-airMapLocation Append]
	@round int,
	@CountryCode char(2)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    INSERT INTO mapLocation ( Location, countryCode, lat, lng, Source, Tolerance, [round] )
	SELECT finalresultAirCrash.MainLocation, finalresultAirCrash.countryCode,
		   MapLocationGoogle.lat, MapLocationGoogle.lng, 
		   MapLocationGoogle.Source, MapLocationGoogle.Tolerance,
		   @round 
	FROM finalresultAirCrash LEFT JOIN MapLocationGoogle 
	ON finalresultAirCrash.MainLocation = MapLocationGoogle.Location
	WHERE finalresultAirCrash.countryCode=@CountryCode



END

GO
/****** Object:  StoredProcedure [dbo].[Z031-dbpMapLocation Append]    Script Date: 3/12/2020 1:09:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<M. Khodizadeh>
-- Create date: <2019-05-22>
-- Description:	<Add DBPedia location info from GoogleMap Data>
-- =============================================
Create PROCEDURE [dbo].[Z031-dbpMapLocation Append]
	@round int,
	@CountryCode char(2)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    INSERT INTO mapLocation ( Location, countryCode, lat, lng, Source, Tolerance, round )
	SELECT finalresultDBPedia.MainLocation, finalresultDBPedia.countryCode,
		   MapLocationGoogle.lat, MapLocationGoogle.lng, 
		   MapLocationGoogle.Source, MapLocationGoogle.Tolerance, 
		   @round
	FROM finalresultDBPedia LEFT JOIN MapLocationGoogle 
	ON finalresultDBPedia.MainLocation = MapLocationGoogle.Location
	WHERE finalresultDBPedia.countryCode=@CountryCode




END

GO
/****** Object:  StoredProcedure [dbo].[Z040-GroundTruth Append]    Script Date: 3/12/2020 1:09:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<M. Khodizadeh>
-- Create date: <2019-05-24>
-- Description:	<Create Ground Truth raw Data, Blocking is applied>
-- =============================================
Create PROCEDURE [dbo].[Z040-GroundTruth Append]
	@round int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO GroundTruth ( airGeoFoundID, dbpGeoFoundID, airMainLocation, dbpMainLocation, Dist, airlat, airlng, dbplat, dbplng, round )
	SELECT	MatchingCandidate.airGeoFoundID, 
			MatchingCandidate.dbpGeoFoundID, 
			MatchingCandidate.airMainLocation, 
			MatchingCandidate.dbpMainLocation, 
			dbo.calcGeoDistance([airlat],[airlng],[dbplat],[dbplng]) , 
			MatchingCandidate.airlat, 
			MatchingCandidate.airlng, 
			MatchingCandidate.dbplat, 
			MatchingCandidate.dbplng, 
			MatchingCandidate.Round
	FROM dbo.MatchingCandidate(@round) MatchingCandidate
	WHERE MatchingCandidate.Gap=0 AND MatchingCandidate.Finished=0





END

GO
/****** Object:  StoredProcedure [dbo].[Z042-Finish GroundTruth]    Script Date: 3/12/2020 1:09:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<M. Khodizadeh>
-- Create date: <2019-05-24>
-- Description:	<Finilize Ground Truth>
-- =============================================
create PROCEDURE [dbo].[Z042-Finish GroundTruth]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE GroundTruth SET GroundTruth.Fnished = 1
	WHERE GroundTruth.Fnished=0

END

GO
/****** Object:  StoredProcedure [dbo].[Z043-GroundTruthUnique Append]    Script Date: 3/12/2020 1:09:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<M. Khodizadeh>
-- Create date: <2019-05-24>
-- Description:	<Create unique data from GroundTruth Table>
-- =============================================
Create PROCEDURE [dbo].[Z043-GroundTruthUnique Append]
	@round int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO GroundTruthUnique ( airGeoFoundID, dbpGeoFoundID, [Match] )
	SELECT GroundTruthMax.airGeoFoundID, GroundTruthMax.dbpGeoFoundID, 
		   GroundTruthMax.MaxOfMatch
	FROM dbo.GroundTruthMax(@round) GroundTruthMax


END

GO
/****** Object:  StoredProcedure [dbo].[Z050-selectedSim UpdateParentChild]    Script Date: 3/12/2020 1:09:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<M. Khodizadeh>
-- Create date: <2019-05-25>
-- Description:	<Set ParentChiled for a pair location based on Hierrchy info from GeoNames>
-- =============================================
CREATE PROCEDURE [dbo].[Z050-selectedSim UpdateParentChild]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE  S
	SET S.ParentChild = A.[inc]
	FROM selectedSim S
	INNER JOIN airdbpParentChild  A
	ON (S.dbpGeoFoundID = A.dbpGeoFoundID) 
	AND (S.airGeoFoundID = A.airGeoFoundID) 
	
	WHERE S.Finished=0


END

GO
/****** Object:  StoredProcedure [dbo].[Z060-selectedSim UpdateDistance]    Script Date: 3/12/2020 1:09:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<M. Khodizadeh>
-- Create date: <2019-05-26>
-- Description:	<Set Distance for a pair location based on lat/long info from GeoNames Search web service>
-- =============================================
CREATE PROCEDURE [dbo].[Z060-selectedSim UpdateDistance]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE S
	SET S.Distance = case when [ParentChild] is not  null  then 0
						  when GAP=1 then 4000
						  else dbo.calcGeoDistance(A.[lat],A.[lng],D.[lat],D.[lng])
					  end 
	
	FROM selectedSim S 
	INNER JOIN finalresultAirCrash A
	ON S.airGeoFoundID = A.geoFoundId
	INNER JOIN finalresultDBPedia D
	ON S.dbpGeoFoundID = D.geoFoundId 
WHERE S.Finished=0 




END

GO
/****** Object:  StoredProcedure [dbo].[Z061-selectedSim ShowDistance]    Script Date: 3/12/2020 1:09:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<M. Khodizadeh>
-- Create date: <2019-05-26>
-- Description:	<Show Distance for a pair location based on lat/long info from GeoNames Search web service>
-- =============================================
CREATE PROCEDURE [dbo].[Z061-selectedSim ShowDistance]
	@round int 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
Select Q.* from 
(
	select S.[airGeoFoundID] as airID,
		   S.[dbpGeoFoundID] as dbpID, 
		   A.[MainLocation] as airLocation, 
		   A.[lat] as airLat,
		   A.[lng] as airLng,
		   D.[MainLocation] as dbpLocation,
		   D.[lat] as dbpLat,
		   D.[lng] as dbpLng,


	  case when [ParentChild] is not  null  then 0
						  when GAP=1 then 4000
						  else dbo.calcGeoDistance(A.[lat],A.[lng],D.[lat],D.[lng])
					  end  as Distance
	
	FROM selectedSim S 
	INNER JOIN finalresultAirCrash A
	ON S.airGeoFoundID = A.geoFoundId
	INNER JOIN finalresultDBPedia D
	ON S.dbpGeoFoundID = D.geoFoundId 
WHERE S.round= @round 
) Q
order by Q.Distance


END

GO
/****** Object:  StoredProcedure [dbo].[Z070-selectedSim UpdateDistSim]    Script Date: 3/12/2020 1:09:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<M. Khodizadeh>
-- Create date: <2019-05-26>
-- Description:	<Set Distance Similarity based on Distance>
-- =============================================
CREATE PROCEDURE [dbo].[Z070-selectedSim UpdateDistSim]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE selectedSim 
	SET selectedSim.DistSim = case when [Distance]>100 then 0 
								   else (100-[Distance])/100.0
							   end 
	WHERE selectedSim.Finished=0





END

GO
/****** Object:  StoredProcedure [dbo].[Z071-selectedSim ShowDistSim]    Script Date: 3/12/2020 1:09:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<M. Khodizadeh>
-- Create date: <2019-05-26>
-- Description:	<Show Distance Similarity based on Distance>
-- =============================================
CREATE PROCEDURE [dbo].[Z071-selectedSim ShowDistSim]
	@round int
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	select S.[airGeoFoundID] as airID,
		   S.[dbpGeoFoundID] as dbpID, 
		   S.Distance, 
		   	
		   case when [Distance]>100 then 0 
				else (100-[Distance])/100.0 
		   end  as DistSim
		    


	from SelectedSim S

	WHERE round=@round

	order by Distance





END

GO
/****** Object:  StoredProcedure [dbo].[Z080-selectedGranSim]    Script Date: 3/12/2020 1:09:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<M. Khodizadeh>
-- Create date: <2019-05-26>
-- Description:	<Set Granularity Similarity based on Hier Info>
-- =============================================
CREATE PROCEDURE [dbo].[Z080-selectedGranSim]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


   UPDATE selectedSim
   SET GranSim = dbo.HierCommonFinal(airGeoFoundID,dbpGeoFoundID)
   where Finished =0 and Gap=0

    


END
GO
/****** Object:  StoredProcedure [dbo].[Z081-selectedGranSim]    Script Date: 3/12/2020 1:09:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<M. Khodizadeh>
-- Create date: <2019-05-26>
-- Description:	<Show Granularity Similarity based on Hierarchy Info. from GeoNames>
-- =============================================
CREATE PROCEDURE [dbo].[Z081-selectedGranSim]
	@round int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


   Select  
		   S.[airGeoFoundID] as airID,
		   S.[dbpGeoFoundID] as dbpID, 
		   A.[MainLocation] as airLocation, 
		   D.[MainLocation] as dbpLocation,
		   dbo.HierCommonFinal(airGeoFoundID,dbpGeoFoundID)   as GranSim
    FROM selectedSim S 
	INNER JOIN finalresultAirCrash A
	ON S.airGeoFoundID = A.geoFoundId
	INNER JOIN finalresultDBPedia D
	ON S.dbpGeoFoundID = D.geoFoundId 

   where round=@round
   and gap=0
   
  order by dbo.HierCommonFinal(airGeoFoundID,dbpGeoFoundID) desc 




END
GO
/****** Object:  StoredProcedure [dbo].[Z090-selectedLevSim]    Script Date: 3/12/2020 1:09:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<M. Khodizadeh>
-- Create date: <2019-05-26>
-- Description:	<Set String Similarity based on Lev function>
-- =============================================
Create PROCEDURE [dbo].[Z090-selectedLevSim]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
   Update  selectedSim
   set LevSim= dbo.ToponymSim(airGeoFoundID, dbpGeoFoundID)
   where Finished=0  and Gap=0

END
GO
/****** Object:  StoredProcedure [dbo].[Z091-selectedLevSim]    Script Date: 3/12/2020 1:09:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<M. Khodizadeh>
-- Create date: <2019-05-26>
-- Description:	<Show String Similarity based on Lev function>
-- =============================================
CREATE PROCEDURE [dbo].[Z091-selectedLevSim]
	@round int 	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
  


   Select  
		   S.[airGeoFoundID] as airID,
		   S.[dbpGeoFoundID] as dbpID, 
		   A.[MainLocation] as airLocation, 
		   D.[MainLocation] as dbpLocation,
		   dbo.ToponymSim(airGeoFoundID, dbpGeoFoundID) as LevSim
	from   selectedSim 	S  
	INNER JOIN finalresultAirCrash A
	ON S.airGeoFoundID = A.geoFoundId
	INNER JOIN finalresultDBPedia D
	ON S.dbpGeoFoundID = D.geoFoundId 

   where round=@round
   and Gap=0

END
GO
/****** Object:  StoredProcedure [dbo].[Z093-QualityMetric]    Script Date: 3/12/2020 1:09:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<M. Khodizadeh>
-- Create date: <2019-05-26>
-- Description:	<calculated Quality Metric(TP,FP, FN , ...)  and append to Table> 
-- =============================================
CREATE PROCEDURE [dbo].[Z093-QualityMetric]
	@round int	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
  

	SELECT  Q.*, 
			case when ([P]=1 And [RP]=1) then 1 else 0 end AS TP,
			case when ([P]=1 And [RP]=0) then 1 else 0 end AS FP, 
			case when ([P]=0 And [RP]=1)  then 1 else 0 end AS FN
	From (
			SELECT	FinalSim.airGeoFoundID as airID, 
					FinalSim.dbpGeoFoundID as dbpID, 
					finalresultAirCrash.MainLocation as airLocation, 
					finalresultDBPedia.MainLocation as dbpLocation, 
					FinalSim.FinalSim, 
					--GroundTruthUnique.Match, 
					case when [Match]=1 then 1 else 0 end AS RP, 
					FinalSim.T, 
					--[FinalSim]-[T] AS Expr1, 
					case when ([FinalSim]-[T])>=-0.00001 then 1 else 0 end AS P
					
					--FinalSim.Round
			FROM dbo.FinalSim(@round) FinalSim 
			INNER JOIN finalresultAirCrash ON FinalSim.airGeoFoundID = finalresultAirCrash.geoFoundId 
			INNER JOIN finalresultDBPedia  ON FinalSim.dbpGeoFoundID = finalresultDBPedia.geoFoundId
			LEFT JOIN  GroundTruthUnique   ON FinalSim.dbpGeoFoundID = GroundTruthUnique.dbpGeoFoundID AND FinalSim.airGeoFoundID = GroundTruthUnique.airGeoFoundID
	)Q 
	where T=0.75 and FinalSim<>0
	--order by NewID() desc 

END
GO
/****** Object:  StoredProcedure [dbo].[Z094-QualityMetric Append]    Script Date: 3/12/2020 1:09:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<M. Khodizadeh>
-- Create date: <2019-05-26>
-- Description:	<calculated Quality Metric(TP,FP, FN , ...)  and append to Table> 
-- =============================================
Create PROCEDURE [dbo].[Z094-QualityMetric Append]
	@round int	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
  

	INSERT INTO QualityMetric ( airGeoFoundID, finalresultAirCrash_MainLocation, dbpGeoFoundID, finalresultDBPedia_MainLocation, FinalSim, [Match], RP, Expr1, P, T, round , TP, FP, FN )
	SELECT  Q.*, 
			case when ([P]=1 And [RP]=1) then 1 else 0 end AS TP,
			case when ([P]=1 And [RP]=0) then 1 else 0 end AS FP, 
			case when ([P]=0 And [RP]=1)  then 1 else 0 end AS FN
	From (
			SELECT	FinalSim.airGeoFoundID,
					finalresultAirCrash.MainLocation as airMainLocation, 
					FinalSim.dbpGeoFoundID, 
					finalresultDBPedia.MainLocation as dbpMainLocation, 
					FinalSim.FinalSim, 
					GroundTruthUnique.Match, 
					case when [Match]=1 then 1 else 0 end AS RP, 
					[FinalSim]-[T] AS Expr1, 
					case when ([FinalSim]-[T])>=-0.00001 then 1 else 0 end AS P,
					FinalSim.T, 
					FinalSim.Round
			FROM dbo.FinalSim(@round) FinalSim 
			INNER JOIN finalresultAirCrash ON FinalSim.airGeoFoundID = finalresultAirCrash.geoFoundId 
			INNER JOIN finalresultDBPedia  ON FinalSim.dbpGeoFoundID = finalresultDBPedia.geoFoundId
			LEFT JOIN  GroundTruthUnique   ON FinalSim.dbpGeoFoundID = GroundTruthUnique.dbpGeoFoundID AND FinalSim.airGeoFoundID = GroundTruthUnique.airGeoFoundID
	)Q 
END
GO
/****** Object:  StoredProcedure [dbo].[Z095-result Query]    Script Date: 3/12/2020 1:09:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<M. Khodizadeh>
-- Create date: <2019-05-26>
-- Description:	<Show last result> 
-- =============================================
Create PROCEDURE [dbo].[Z095-result Query]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
  

	SELECT	 result.T, result.NSTP, result.NSFP,
			 result.NSFN, result.Precision,
			 result.Recall, result.FScore
	FROM dbo.result() result

END
GO
/****** Object:  StoredProcedure [dbo].[Z100-Finish SelectedSim]    Script Date: 3/12/2020 1:09:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<M. Khodizadeh>
-- Create date: <2019-05-26>
-- Description:	<Finalize result> 
-- =============================================
Create PROCEDURE [dbo].[Z100-Finish SelectedSim]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
  

	UPDATE selectedSim 
	SET selectedSim.Finished = 1
	WHERE selectedSim.Finished=0


END
GO
USE [master]
GO
ALTER DATABASE [GSDF] SET  READ_WRITE 
GO
