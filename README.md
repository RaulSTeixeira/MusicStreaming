# Rumos Data Engineer Academy: MusicStreaming Project

## Introduction
This repository countains parts of the project *MusicStreaming* developed during RUMOS Data Engineer Academy course.

The main objective of this project is to design and implement a conceptual, logical, and physical architecture for a music streaming platform, including solutions for data storage (relational database and data warehousing) and data handling (ETL processes).

The project starts with the design of a relational database that would meet all the specified criteria, starting with the definition of an ER model.

This database was then implemented in MS SQL Server. To populate the database, data was imported from CSV files using Visual Studio with Integration Services (SSIS).

Subsequently, the database was migrated to a cloud environment (Azure SQL Database), along with the SSIS packages, which were transitioned to Azure Data Factory.

## Table of Contents

- [Project Requirements](#Project-Requirements)
- [Relational Database](#Relational-Database)
- [Data Generation](#Data-Generation)

## Project Requirements



## Relational Database

### Conceptual Model (Entity-Relationship Diagram)

### Database Schema
[dbdiagram](https://dbdiagram.io/d/66a7bdb38b4bb5230ea778af)


## Data Generation

Part of the data used to populate the database was retrieved from public repositorys in CSV format. Taking into account project specifications and to keep a reasonable amount of complexity, the raw data was selected using the following entries and amount of records:

| Entry         | Records       |
| ------------- |:-------------|
| Countries      | 245 |
| Bands      | 143.031      |
| Albuns | 89.088     |
| Tracks | 738.591     |
| Users | 1.001 |


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
