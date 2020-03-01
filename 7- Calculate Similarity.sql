USE [DFV2]
GO
/****** Object:  UserDefinedFunction [dbo].[HierCommonFinal]    Script Date: 3/1/2020 6:44:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<M. Khodizadeh>
-- Create date: <2019-05-26>
-- Description:	<Count Hier Common Item>
-- =============================================
Create FUNCTION [dbo].[HierCommonFinal]
(
	@idAir int, @idDbp int
)
RETURNS tinyint

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


   RETURN @CommCount/ case when @DBPCount<@AirCount then @DBPCount else @AirCount end 





END

GO
/****** Object:  UserDefinedFunction [dbo].[ToponymSim]    Script Date: 3/1/2020 6:44:11 AM ******/
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
/****** Object:  StoredProcedure [dbo].[Z050-selectedSim UpdateParentChild]    Script Date: 3/1/2020 6:44:11 AM ******/
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
/****** Object:  StoredProcedure [dbo].[Z060-selectedSim UpdateDistance]    Script Date: 3/1/2020 6:44:11 AM ******/
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
/****** Object:  StoredProcedure [dbo].[Z070-selectedSim UpdateDistSim]    Script Date: 3/1/2020 6:44:11 AM ******/
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
								   else (100-[Distance])/100
							   end 
	WHERE selectedSim.Finished=0





END

GO
/****** Object:  StoredProcedure [dbo].[Z080-selectedGranSim]    Script Date: 3/1/2020 6:44:11 AM ******/
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
/****** Object:  StoredProcedure [dbo].[Z090-selectedLevSim]    Script Date: 3/1/2020 6:44:11 AM ******/
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
