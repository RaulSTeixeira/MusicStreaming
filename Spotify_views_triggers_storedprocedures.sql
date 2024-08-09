USE Spotify
GO

-- Most Tracks listened
CREATE VIEW most_tracks_listened AS
SELECT TrackAlbumID, COUNT(TrackAlbumID) as number_listening
FROM TracksListened
Group By TrackAlbumID

SELECT *
FROM most_tracks_listened
Order by number_listening desc

-- Alphabetical list of bands, by country
SELECT Band.CountryID, Country.CountryName, Band.BandID, Band.BandName
FROM Band
INNER JOIN Country ON Band.CountryID=Country.CountryID
Order by CountryName DESC, BandName

-- Alphabetical list of bands, label, genre, album name
SELECT Band.BandID, Band.BandName, Album.Label, Album.MusicType, Album.AlbumName 
FROM Band
INNER JOIN Country ON Band.CountryID=Country.CountryID
INNER JOIN Album ON Album.BandID = Band.BandID
Order by BandName

--List of the 10 bands with the most albums
CREATE VIEW top_10_bands_most_albums AS
SELECT Top 10 Band.BandID, Band.BandName, Count(Album.AlbumID) as number_of_albums
FROM Band
INNER JOIN Country ON Band.CountryID=Country.CountryID
INNER JOIN Album ON Album.BandID = Band.BandID
Group by Band.BandID, Band.BandName
Order By Count(Album.AlbumID) DESC

--Create a Stored Procedure
DROP PROCEDURE top_x_bands_most_albums

CREATE PROCEDURE top_x_bands_most_albums @number_bands integer
AS
SELECT Top (@number_bands) Band.BandID, Band.BandName, Count(Album.AlbumID) as number_of_albums
FROM Band
INNER JOIN Country ON Band.CountryID=Country.CountryID
INNER JOIN Album ON Album.BandID = Band.BandID
Group by Band.BandID, Band.BandName
Order By Count(Album.AlbumID) DESC

EXEC top_x_bands_most_albums @number_bands = 20;

-- Create a trigger to record changes on Band Table

-- Create Audit/Log Table
CREATE TABLE dbo.Band_Log(
    ChangeID INT IDENTITY PRIMARY KEY,
    BandID INT NOT NULL,
    BandName VARCHAR(255) NOT NULL,
    CountryID INT NOT NULL,
    UpdatedAt DATETIME NOT NULL,
    operation CHAR(3) NOT NULL,
    CHECK(operation = 'INS' or operation='DEL')
);

-- Create Trigger
CREATE TRIGGER dbo.trg_bands
ON Spotify.dbo.Band
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT OFF;
	INSERT INTO
    dbo.Band_Log
        (
            BandID,
            BandName,
            CountryID,
            UpdatedAt,
            operation
        )
		SELECT
			BandID,
			BandName,
			CountryID,
			GETDATE(),
			'INS'
		FROM
			inserted AS ins
		UNION ALL
			SELECT
			BandID,
			BandName,
			CountryID,
			GETDATE(),
			'DEL'
			FROM
			deleted AS del;
END

-- Tests
DELETE FROM
	dbo.Band
WHERE 
    BandID = 302;

INSERT INTO dbo.Band(
    BandID, 
    BandName, 
    CountryID 
)
VALUES (
    301,
    'TEST_BAND',
    2018
);

UPDATE dbo.Band
SET BandName = 'AAA'
WHERE BandID = 1000;

Select * From spotify.dbo.Band_Log

