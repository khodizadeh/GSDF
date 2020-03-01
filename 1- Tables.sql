USE [DFV2]
GO
/****** Object:  Table [dbo].[airAlternativeName]    Script Date: 3/1/2020 6:50:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[alternativeName](
	[geonameId] [int] NULL,
	[alternativeName] [nvarchar](4000) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[dbpediaGeoNameHier]    Script Date: 3/1/2020 6:51:33 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dbpediaGeoNameHier](
	[geonameIdMain] [nvarchar](255) NULL,
	[sid] [nvarchar](255) NULL,
	[eid] [nvarchar](255) NULL,
	[id] [nvarchar](255) NULL,
	[toponymName] [nvarchar](255) NULL,
	[name] [nvarchar](255) NULL,
	[lat] [real] NULL,
	[lng] [real] NULL,
	[geonameId] [nvarchar](255) NULL,
	[countryCode] [nvarchar](50) NULL,
	[countryName] [nvarchar](50) NULL,
	[fcl] [nvarchar](50) NULL,
	[fcode] [nvarchar](50) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[GeoFound]    Script Date: 3/1/2020 6:51:33 AM ******/
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
/****** Object:  Table [dbo].[geonameMain]    Script Date: 3/1/2020 6:51:33 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[geonameMain](
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
 CONSTRAINT [PK_geonameMain] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Location]    Script Date: 3/1/2020 6:51:33 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Location](
	[ID] [int] NULL,
	[Prefix] [nvarchar](255) NULL,
	[Rest] [nvarchar](255) NULL,
	[Rest2] [nvarchar](255) NULL,
	[Rest3] [nvarchar](255) NULL,
	[Postfix] [nvarchar](255) NULL,
	[Location] [nvarchar](255) NULL,
	[Infix] [nvarchar](255) NULL
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[airAlternativeName](
	[geonameId] [int] NULL,
	[alternativeName] [nvarchar](4000) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[airdbpCountryNull]    Script Date: 3/1/2020 6:50:04 AM ******/
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
/****** Object:  Table [dbo].[airdbpParentChild]    Script Date: 3/1/2020 6:50:04 AM ******/
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
/****** Object:  Table [dbo].[airSelected]    Script Date: 3/1/2020 6:50:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[airSelected](
	[geoFoundId] [int] IDENTITY(1,1) NOT NULL,
	[round] [int] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[dbpAlternativeName]    Script Date: 3/1/2020 6:50:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dbpAlternativeName](
	[geonameId] [int] NULL,
	[alternativeName] [nvarchar](4000) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[dbpSelected]    Script Date: 3/1/2020 6:50:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dbpSelected](
	[geoFoundId] [int] IDENTITY(1,1) NOT NULL,
	[round] [int] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[finalresultAirCrash]    Script Date: 3/1/2020 6:50:04 AM ******/
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
/****** Object:  Table [dbo].[finalresultDBPedia]    Script Date: 3/1/2020 6:50:04 AM ******/
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
/****** Object:  Table [dbo].[GeonameHier]    Script Date: 3/1/2020 6:50:04 AM ******/
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
/****** Object:  Table [dbo].[GroundTruth]    Script Date: 3/1/2020 6:50:04 AM ******/
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
/****** Object:  Table [dbo].[GroundTruthUnique]    Script Date: 3/1/2020 6:50:04 AM ******/
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
/****** Object:  Table [dbo].[mapLocation]    Script Date: 3/1/2020 6:50:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[mapLocation](
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
/****** Object:  Table [dbo].[MapLocationGoogle]    Script Date: 3/1/2020 6:50:04 AM ******/
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
/****** Object:  Table [dbo].[Neighbours]    Script Date: 3/1/2020 6:50:04 AM ******/
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
/****** Object:  Table [dbo].[QualityMetric]    Script Date: 3/1/2020 6:50:04 AM ******/
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
/****** Object:  Table [dbo].[QualityMetricBulkSum]    Script Date: 3/1/2020 6:50:04 AM ******/
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
/****** Object:  Table [dbo].[selectedSim]    Script Date: 3/1/2020 6:50:04 AM ******/
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
	[Gap] [tinyint] NULL,
	[Finished] [tinyint] NULL,
	[round] [int] NULL,
	[RealDistance] [int] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Threshold]    Script Date: 3/1/2020 6:50:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Threshold](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[T] [float] NULL
) ON [PRIMARY]

GO
