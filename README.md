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
- [Data Generation](#Data-Generation)
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

## Data Generation

Part of the data used to populate the database was retrieved from public repositorys in CSV format. Taking into account project specifications and to keep a reasonable amount of complexity, the raw data was selected using the following entries and amount of records:

| Entities         | Records       |
| ------------- |:-------------|
| Countries      | 245 |
| Bands      | 143.031      |
| Albuns | 89.088     |
| Tracks | 738.591     |
| Users | 1.001 |

Regarding the listening sessions data, since its not easily found, or its not in a apropriate format for this project, it was decided that it would be generated using pyhton scripts.

The developed script generates listening sessions, for a set of users. It randomly selects a certain amount of tracks per session, user and country (each session is associated only with a user in a certain country, and the amount of tracks listened is also random). It also includes the date and hour that each track started.

This script takes as input the ID's of the users, countries and tracks that currently exist in the database. It is also possible to adjust the maximum number of tracks per session (max_tracks_per_session) and the maximum number of sessions (max_sessions)

For this project, the maximum number of sessions was set at 10K generating a dataset with aproximatly 55k entries.

The script generates the dataset as a CSV file, and is also required that it reads a file (also csv) with each track duration, so it can calculate the date and hour that each track is started for each listening session.


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

## Data Warehouse
*Documentation under development*

## ETL Processes
*Documentation under development*

## Data Analysis
*Documentation under development*
