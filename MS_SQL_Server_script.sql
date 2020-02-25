USE [DFV2]
GO
/****** Object:  UserDefinedFunction [dbo].[calcGeoDistance]    Script Date: 2/25/2020 8:42:33 PM ******/
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
/****** Object:  UserDefinedFunction [dbo].[fn_HaveGap]    Script Date: 2/25/2020 8:42:33 PM ******/
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
/****** Object:  Table [dbo].[airSelected]    Script Date: 2/25/2020 8:42:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[airSelected](
	[geoFoundId] [int] IDENTITY(1,1) NOT NULL,
	[round] [int] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[dbpSelected]    Script Date: 2/25/2020 8:42:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dbpSelected](
	[geoFoundId] [int] IDENTITY(1,1) NOT NULL,
	[round] [int] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[finalresultAirCrash]    Script Date: 2/25/2020 8:42:33 PM ******/
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
/****** Object:  Table [dbo].[finalresultDBPedia]    Script Date: 2/25/2020 8:42:33 PM ******/
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
/****** Object:  Table [dbo].[Neighbours]    Script Date: 2/25/2020 8:42:33 PM ******/
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
/****** Object:  Table [dbo].[selectedSim]    Script Date: 2/25/2020 8:42:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[selectedSim](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[airGeoFoundID] [int] NULL,
	[dbpGeoFoundID] [int] NULL,
	[ParentChild] [int] NULL,
	[Distance] [int] NULL,
	[DistSim] [float] NULL,
	[GranSim] [float] NULL,
	[LevSim] [float] NULL,
	[Gap] [bit] NULL,
	[Finished] [bit] NULL,
	[round] [int] NULL,
	[RealDistance] [int] NULL
) ON [PRIMARY]

GO
/****** Object:  UserDefinedFunction [dbo].[airdbpSelectedPair]    Script Date: 2/25/2020 8:42:33 PM ******/
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
/****** Object:  StoredProcedure [dbo].[Z010-airSelected Make]    Script Date: 2/25/2020 8:42:33 PM ******/
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
/****** Object:  StoredProcedure [dbo].[Z011-dbpSelected Make]    Script Date: 2/25/2020 8:42:33 PM ******/
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
/****** Object:  StoredProcedure [dbo].[Z020-selectedSim Append]    Script Date: 2/25/2020 8:42:33 PM ******/
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
