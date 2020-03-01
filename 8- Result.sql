USE [DFV2]
GO
/****** Object:  UserDefinedFunction [dbo].[selectedFinalSim2]    Script Date: 3/1/2020 6:45:48 AM ******/
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
/****** Object:  UserDefinedFunction [dbo].[airdbpCountryNullUnique]    Script Date: 3/1/2020 6:45:48 AM ******/
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
/****** Object:  UserDefinedFunction [dbo].[resultCountryNull]    Script Date: 3/1/2020 6:45:48 AM ******/
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
/****** Object:  UserDefinedFunction [dbo].[result2]    Script Date: 3/1/2020 6:45:48 AM ******/
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
/****** Object:  UserDefinedFunction [dbo].[result3]    Script Date: 3/1/2020 6:45:48 AM ******/
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
/****** Object:  UserDefinedFunction [dbo].[result1]    Script Date: 3/1/2020 6:45:48 AM ******/
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
/****** Object:  UserDefinedFunction [dbo].[result]    Script Date: 3/1/2020 6:45:48 AM ******/
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
/****** Object:  UserDefinedFunction [dbo].[FinalSim]    Script Date: 3/1/2020 6:45:48 AM ******/
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
/****** Object:  UserDefinedFunction [dbo].[MatchingCandidate]    Script Date: 3/1/2020 6:45:48 AM ******/
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
/****** Object:  StoredProcedure [dbo].[Z094-QualityMetric Append]    Script Date: 3/1/2020 6:45:48 AM ******/
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
/****** Object:  StoredProcedure [dbo].[Z095-result Query]    Script Date: 3/1/2020 6:45:48 AM ******/
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
/****** Object:  StoredProcedure [dbo].[Z100-Finish SelectedSim]    Script Date: 3/1/2020 6:45:48 AM ******/
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
