USE [MusicStreaming]
GO
/****** Object:  Table [dbo].[Album]    Script Date: 31/07/2024 11:22:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Album](
	[AlbumId] [int] NOT NULL,
	[BandId] [int] NULL,
	[AlbumName] [nvarchar](1) NULL,
	[MusicType] [nvarchar](1) NULL,
	[Label] [nvarchar](1) NULL,
	[Genre] [nvarchar](1) NULL,
PRIMARY KEY CLUSTERED 
(
	[AlbumId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Band]    Script Date: 31/07/2024 11:22:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Band](
	[BandId] [int] NOT NULL,
	[CountryId] [int] NULL,
	[BandName] [nvarchar](1) NULL,
PRIMARY KEY CLUSTERED 
(
	[BandId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Country]    Script Date: 31/07/2024 11:22:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Country](
	[CountryId] [int] NOT NULL,
	[CountryName] [nvarchar](1) NULL,
PRIMARY KEY CLUSTERED 
(
	[CountryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Track]    Script Date: 31/07/2024 11:22:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Track](
	[TrackId] [int] NOT NULL,
	[TrackName] [nvarchar](1) NULL,
	[TrackDuration] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[TrackId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TrackAlbum]    Script Date: 31/07/2024 11:22:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TrackAlbum](
	[TrackAlbumId] [int] NOT NULL,
	[TrackId] [int] NULL,
	[AlbumId] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[TrackAlbumId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TracksListened]    Script Date: 31/07/2024 11:22:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TracksListened](
	[Id] [int] NOT NULL,
	[UserId] [int] NULL,
	[CountryId] [int] NULL,
	[TrackAlbumId] [int] NULL,
	[SessionId] [int] NULL,
	[DateHour] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[User]    Script Date: 31/07/2024 11:22:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[User](
	[UserId] [int] NOT NULL,
	[UserName] [nvarchar](1) NULL,
	[Role] [nvarchar](1) NULL,
	[CreatedAt] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Album]  WITH CHECK ADD FOREIGN KEY([BandId])
REFERENCES [dbo].[Band] ([BandId])
GO
ALTER TABLE [dbo].[Band]  WITH CHECK ADD FOREIGN KEY([CountryId])
REFERENCES [dbo].[Country] ([CountryId])
GO
ALTER TABLE [dbo].[TrackAlbum]  WITH CHECK ADD FOREIGN KEY([AlbumId])
REFERENCES [dbo].[Album] ([AlbumId])
GO
ALTER TABLE [dbo].[TrackAlbum]  WITH CHECK ADD FOREIGN KEY([TrackId])
REFERENCES [dbo].[Track] ([TrackId])
GO
ALTER TABLE [dbo].[TracksListened]  WITH CHECK ADD FOREIGN KEY([CountryId])
REFERENCES [dbo].[Country] ([CountryId])
GO
ALTER TABLE [dbo].[TracksListened]  WITH CHECK ADD FOREIGN KEY([TrackAlbumId])
REFERENCES [dbo].[TrackAlbum] ([TrackAlbumId])
GO
ALTER TABLE [dbo].[TracksListened]  WITH CHECK ADD FOREIGN KEY([UserId])
REFERENCES [dbo].[User] ([UserId])
GO
