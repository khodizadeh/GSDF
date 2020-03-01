USE [DFV2]
GO
/****** Object:  UserDefinedFunction [dbo].[airdbpSelectedPair]    Script Date: 3/1/2020 6:40:36 AM ******/
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
/****** Object:  StoredProcedure [dbo].[Z010-airSelected Make]    Script Date: 3/1/2020 6:40:36 AM ******/
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
/****** Object:  StoredProcedure [dbo].[Z011-dbpSelected Make]    Script Date: 3/1/2020 6:40:36 AM ******/
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
/****** Object:  StoredProcedure [dbo].[Z020-selectedSim Append]    Script Date: 3/1/2020 6:40:36 AM ******/
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
