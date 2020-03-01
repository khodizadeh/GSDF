USE [DFV2]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_HaveGap]    Script Date: 3/1/2020 6:49:09 AM ******/
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
