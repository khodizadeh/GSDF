USE [DFV2]
GO
/****** Object:  UserDefinedFunction [dbo].[GroundTruthMax]    Script Date: 3/1/2020 6:42:17 AM ******/
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
/****** Object:  View [dbo].[Z032-mapLocation Query]    Script Date: 3/1/2020 6:42:17 AM ******/
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
/****** Object:  View [dbo].[Z041-GroundTruth Query]    Script Date: 3/1/2020 6:42:17 AM ******/
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
/****** Object:  StoredProcedure [dbo].[Z030-airMapLocation Append]    Script Date: 3/1/2020 6:42:17 AM ******/
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
/****** Object:  StoredProcedure [dbo].[Z031-dbpMapLocation Append]    Script Date: 3/1/2020 6:42:17 AM ******/
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
/****** Object:  StoredProcedure [dbo].[Z040-GroundTruth Append]    Script Date: 3/1/2020 6:42:17 AM ******/
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
/****** Object:  StoredProcedure [dbo].[Z042-Finish GroundTruth]    Script Date: 3/1/2020 6:42:17 AM ******/
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
/****** Object:  StoredProcedure [dbo].[Z043-GroundTruthUnique Append]    Script Date: 3/1/2020 6:42:17 AM ******/
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
