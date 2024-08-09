# Rumos Data Engineer Academy: MusicStreaming Project

## Introduction
This repository countains parts of the project *MusicStreaming* developed during RUMOS Data Engineer Academy course.

The main objective of this project is to design and implement a conceptual, logical, and physical architecture for a music streaming platform, including solutions for data storage (relational database and data warehousing) data handling (ETL processes), and data analysis.

The project starts with the design of a relational database that would meet all the specified criteria, starting with the definition of an ER model.

This database was then implemented in MS SQL Server. To populate the database, data was imported from CSV files using Visual Studio with Integration Services (SSIS).

Subsequently, the database was migrated to a cloud environment (Azure SQL Database), along with the SSIS packages, which were transitioned to Azure Data Factory.

## Table of Contents

- [Project Requirements](#Project-Requirements)
- [Relational Database](#Relational-Database)
- [Data Sources](#Data-Sources)
- [Database Views, Triggers and Stored Procedures](#Database-Views-Triggers-and-Stored-Procedures)
- [Data Warehouse](#Data-Warehouse)
- [ETL Processes](#ETL-Processes)
- [Data Analysis](#Data-Analysis)

## Project Requirements

Regarding the development of the relational database (structured information), besides handling the most basic information (users, bands, albums, tracks, etc) it was also required that it would provide the following information reports:

- Alphabetical list of bands, by country
- Alphabetical list of bands, label, genre, album name
- List of the 5 countries with the most bands
- List of the 10 bands with the most albums
- List of the 5 music genres with the most albums
- List of the 20 longest albuns (total playtime)
- What are the most listened-to songs and music genre, by country, between a time period (ex. 4:00 PM and 12:00 AM)
- Information on users listening patterns
- ...

These specifications were taken into account during the conceptual phase of development, so that the data model would be able to capture all this information.

## Relational Database
### Database Schema
After developing the conceptual model, it was then materialized into a normalized relational database, assigning attributes to entities, and establishing relationships between entities (Primary and Foreign keys definition).

Choosing a data type (integer, nvarchar, ...) and constrains for the attributes was also necessary.

![MusicStreaming_DB](https://github.com/user-attachments/assets/83fa296f-6e94-48f4-a48e-7f2adfa19c18)

The database schema can be further explored here: [dbdiagram](https://dbdiagram.io/d/66a7bdb38b4bb5230ea778af)

### Database Implementation
The database was implemented in MS SQL server, here is part of the code used to create tables and define constrains:

```sql
-- Create Album table
CREATE TABLE [Album] (
  [AlbumId] integer PRIMARY KEY,
  [BandId] integer,
  [AlbumName] nvarchar,
  [MusicType] nvarchar,
  [Label] nvarchar,
  [Genre] nvarchar
)
GO

-- Create Bands table
CREATE TABLE [Band] (
  [BandId] integer PRIMARY KEY,
  [CountryId] integer,
  [BandName] nvarchar
)
GO

-- Add foreign key to table Album, referencing a Band
ALTER TABLE [Album] ADD FOREIGN KEY ([BandId]) REFERENCES [Band] ([BandId])
GO

-- Add constrains so that the band names are unique(as an example)
ALTER TABLE [Band] ADD CONSTRAINT unique_band_name UNIQUE ([BandName]);
GO

-- Add cconstrains so that a certain input is whithin a predetermined list
ALTER TABLE Album
ADD CONSTRAINT chk_genre CHECK (genre in ('rock','metal','blues'));
GO
```

### Conceptual Model 

Taking into account the project requirements a conceptual model of the database was delevoped, using an *Entity-Relationship Diagram*. This type of diagram allows to specify the different entities that compose the data model and the relationship between them.

During this conceptual model development, since there is not a single correct solution, some assumptions need to be made:

- An album has only one genre.
- A track can have multiple bands (as long as they are in different albums).
- An album has only one band.
- The time used is from the database.
- ...

The ER diagram is as follows.

<img src="https://github.com/user-attachments/assets/472b9e1c-eee0-4523-b8d7-be38b249f399" alt="drawing" width="600">

The relatioship between tracks and albuns is a many-to-many type since an album as multiple tracks, and a track can appear in several albuns.

To achieve this relation a join table (or junction) was used, as it can be seen here.

![many-to-many](https://github.com/user-attachments/assets/0b8b448e-be33-4e45-a96e-682441cef3d1)

This join table transforms the many-to-may relationship in two many-to-one relationships, containing two foreign keys from the album and tracks tables.
The join table also has a primary key, since it needs to be referenced in the TracksListened table, to keep a clear record of users listening sessions. This primary key could also be defined as a composite key, using track and album foreign keys.

## Data Sources
### Public Repositories

Part of the data used to populate the database was retrieved from public repositorys in CSV format. Taking into account project specifications and to keep a reasonable amount of complexity, the raw data was selected using the following entities and amount of records:

| Entity         | Records       |
| ------------- |:-------------|
| Countries      | 245 |
| Bands      | 143.031      |
| Albuns | 89.088     |
| Tracks | 738.591     |
| Users | 1.000 |
| Track_Album* | 1.034.755 |
*This includes tracks that repeat in different albuns

This data also required some pre-processing, since it contained characters that were not suported by SQL server default collation. A basic phyton script was developed to search and remove this characters.

### Data Generation

Regarding the listening sessions data, since its not easily found, or its not in a apropriate format for this project, it was decided that it would be generated using pyhton scripts.

The developed script generates listening sessions, for a set of users. It randomly selects a certain amount of tracks per session, user and country (each session is associated only with a user in a certain country, and the amount of tracks listened is also random). It also includes the date and hour that each track started.

This script takes as input the ID's of the users, countries and tracks that currently exist in the database. It is also possible to adjust the maximum number of tracks per session (max_tracks_per_session) and the maximum number of sessions (max_sessions).

```python
# Parameters for generating dataset
num_users = 1000
max_tracks_per_session = 10
country_id_interval = (1, 245)
track_id_interval = (1, 1035030)
max_sessions = 10000
```

For this project, the maximum number of sessions was set at 10K generating a dataset with aproximatly 55k entries.

The script generates the dataset as a CSV file, and is also required that it reads a file (also csv) with each track duration, so it can calculate the date and hour that each track is started for each listening session.

The full script is presented bellow.

```python

import csv
import random
from datetime import datetime, timedelta

# Function to read TrackID and TrackDuration from a CSV file
def read_track_durations(filename):
    track_durations = {}
    with open(filename, "r") as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            track_id = int(row["TrackID"])
            duration = int(row["TrackDuration"])
            track_durations[track_id] = duration
    return track_durations

# Function to generate random listening sessions dataset
def generate_listening_sessions(
    num_users,
    max_tracks_per_session,
    country_id_interval,
    track_id_interval,
    max_sessions,
    track_durations,
):
    data = []

    for session in range(1, max_sessions + 1):
        user_id = random.randint(1, num_users)
        country_id = random.randint(country_id_interval[0], country_id_interval[1])
        num_tracks = random.randint(1, max_tracks_per_session)

        # Randomly select a starting time for the first track of each session
        start_time = datetime.now() - timedelta(days=random.randint(1, 365))

        for track_order in range(1, num_tracks + 1):
            track_id = random.randint(track_id_interval[0], track_id_interval[1])
            duration = track_durations.get(
                track_id, 180
            )  # Default duration is 3 minutes if not provided

            # Calculate DateHour for each track based on the duration
            date_hour = start_time.strftime("%Y-%m-%d %H:%M:%S")
            start_time += timedelta(seconds=duration)

            data.append(
                [session, user_id, country_id, track_order, track_id, date_hour]
            )

    return data

# Function to write data to a CSV file
def write_to_csv(data, filename):
    with open(filename, "w", newline="") as csvfile:
        fieldnames = [
            "SessionID",
            "UserID",
            "CountryID",
            "TrackOrder",
            "TrackAlbumID",
            "DateHour",
        ]
        writer = csv.writer(csvfile)
        writer.writerow(fieldnames)
        writer.writerows(data)

# Parameters for generating dataset
num_users = 1000
max_tracks_per_session = 10
country_id_interval = (1, 245)
track_id_interval = (1, 1035030)
max_sessions = 10000

# Filename for TrackID and TrackDuration CSV
track_durations_filename = "track_durations.csv"

# Generate dataset
track_durations = read_track_durations(track_durations_filename)
listening_sessions_data = generate_listening_sessions(
    num_users,
    max_tracks_per_session,
    country_id_interval,
    track_id_interval,
    max_sessions,
    track_durations,
)

# Output to CSV file
output_filename = "listening_sessions_dataset.csv"
write_to_csv(listening_sessions_data, output_filename)

print(f"Dataset generated and saved to {output_filename}.")

```

Here is a snipet of the output of this script, as its possible to see each session has only a single user and country. The TrackOrder field is just for controlling purposes and the Datehour represents the time that each music started (its assumed that each music is listened until the end).

```python
SessionID,UserID,CountryID,TrackOrder,TrackAlbumID,DateHour
1,766,202,1,207728,2023-06-06 22:06:58
1,766,202,2,559523,2023-06-06 22:16:24
1,766,202,3,587397,2023-06-06 22:18:40
1,766,202,4,520108,2023-06-06 22:19:55

2,993,52,1,618427,2023-07-08 22:06:58
2,993,52,2,816632,2023-07-08 22:10:03
2,993,52,3,136210,2023-07-08 22:13:32
2,993,52,4,508541,2023-07-08 22:18:13
2,993,52,5,635239,2023-07-08 22:22:15

...
```

## Database Views, Triggers and Stored Procedures
### Views

Some views were defined in order to provide information reports, here are some examples:

```sql
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
```

### Triggers
Triggers allow to keep a log of changes in table's records from operations such as delete, insert or update.

```sql
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
```

### Stored Procedures
A couple of stored procedures were also defined, they allow to call select statements taking as input some variables (ex. number of records to show), here is an example:

```sql
--Create a Stored Procedure

CREATE PROCEDURE top_x_bands_most_albums @number_bands integer
AS
SELECT Top (@number_bands) Band.BandID, Band.BandName, Count(Album.AlbumID) as number_of_albums
FROM Band
INNER JOIN Country ON Band.CountryID=Country.CountryID
INNER JOIN Album ON Album.BandID = Band.BandID
Group by Band.BandID, Band.BandName
Order By Count(Album.AlbumID) DESC

EXEC top_x_bands_most_albums @number_bands = 20;
```

## Data Warehouse
*Documentation under development*

## ETL Processes
*Documentation under development*

## Data Analysis
*Documentation under development*
