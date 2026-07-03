# SWIface #

This repo contains the interface between the [Silent Wings](http://www.silentwings.no) either Studio or Viewer with the [OGN network](http://wiki.glidernet.org).

The main task is to collect all the **OGN APRS** data for a defined competition area and store it on a [SQLITE 3](https://sqlite.org) or [MySQL](https://www.mysql.com/products/) database.

File  |  Description
---- | ----
SWiface.py | 		Is the data collector. It gathers all the fixes on the competition area until the sunset
DBcreate.py |		Script to create the SWiface database, using the DBschema.sql file
DBschema.sql |		Database schema used in this application
parserfuncs.py	|	The set of routines to extract the main data from the APRS packets
SWSconfig.ini	|	The settings used by this application. You need to define here if your are using MySQL or not and the name of the user/password and host, This file is in /etc/local

Originally  the system was running on a [Raspberry Pi 3](https://www.raspberrypi.org/products/raspberry-pi-3-model-b/) with a HDD SDD of 128 Gb, using [Raspbian Jessie](https://www.raspberrypi.org/downloads/raspbian/) distro. The MySQL version uses a [Oracle's MySQL](https://www.oracle.com/mysql/index.html) database hosted on a WDC Mirror nas/nfs server. 
Nowadays the system is running in a [Intel NUC] (http://www.intel.com/nuc) under [Ubuntu 16.04.2 LTS (Xenial)] (http://www.ubuntu.com) and also running under a virtual machine [VirtualBox] (http://www.virtualbox.org) and [Vagrant] (https://www.vagrantup.com/) in a Windows 10 environment. See INSTALL.md for more details

For any bug please report it thru the GitHub account, open an issue and I will try to solve it.

**Angel Casado**

[acasado (at) acm.org](acasado (at) acm.org)



# SWIface Documentation

## Overview

**SWIface** is a Python-based daemon designed to bridge the gap between the [Silent Wings](http://www.silentwings.no) software suite (Studio or Viewer) and the [OGN (Open Glider Network)](http://wiki.glidernet.org) APRS network. 

Its primary mission is to continuously monitor the OGN network for a specific geographic area (e.g., a glider competition zone), capture all relevant **APRS (Automatic Packet Reporting System)** telemetry, and persist this data into a structured database (MySQL or SQLite3) for later analysis and visualization by Silent Wings.

---

## Architecture

SWIface operates as an event-driven daemon using a layered processing architecture.

### System Diagram

```text
┌─────────────────────────────────────────────────────────────┐
│                    SWIface Daemon (Main Loop)               │
│                      `src/SWiface.py`                       │
├──────────────────┬──────────────────┬───────────────────────┤
│   Packet Parser  │  Data Processing │    Database Layer     │
│  `parserfuncs.py`│   `SWiface.py`   │ `ognddbfuncs.py` etc.  │
└────────┬─────────┴────────┬─────────┴──────────┬────────────┘
         │                  │                     │
         ▼                  ▼                     ▼
┌─────────────────────────────────────────────────────────────┐
│                    External APRS Network                    │
│                 (TCP Socket / APRS Server)                  │
└─────────────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────┐
│                    Persistent Storage                       │
│             (MySQL or SQLite3 - `OGNDATA` table)            │
└─────────────────────────────────────────────────────────────┘
```

### Processing Layers

1.  **Ingestion Layer (`SWiface.py`)**: 
    *   Maintains a persistent TCP socket connection to the APRS server.
    *   Handles authentication (user/passcode) and periodic "keep-alive" messages.
    *   Manages the lifecycle of the daemon, including graceful shutdown on `SIGTERM`.

2.  **Parsing Layer (`parserfuncs.py`)**: 
    *   Receives raw ASCII strings from the socket.
    *   Uses specialized routines (and often the `ogn.parser` library) to decode unstructured APRS packets into structured Python dictionaries.
    *   Identifies packet types (position, status, etc.) and aircraft/station identities.

3.  **Processing Layer (`SWiface.py`)**: 
    *   **Geographic Filtering**: Validates that the received coordinates fall within the configured competition area or bounding box.
    *   **Identity Unification**: Cross-references OGN tracker IDs with FLARM IDs using a pairing table (`ognttable`) to ensure consistent aircraft tracking.
    *   **Validation**: Filters out invalid data (e.g., unrealistic altitudes, bad GPS quality).

4.  **Persistence Layer (`ognddbfuncs.py`, `ogntfuncs.py`)**: 
    *   Translates the enriched data dictionaries into SQL commands.
    *   Handles insertion of telemetry into the `OGNDATA` table.
    *   Updates station/receiver information in the `RECEIVERS` table.

---

## Core Components

| Component | File(s) | Description |
| :--- | :--- | :--- |
| **Main Daemon** | `SWiface.py` | The orchestrator. Manages the socket, the main loop, and the overall state. |
| **Parsing Engine** | `parserfuncs.py` | Contains the logic to turn raw text into usable data structures. |
| **Configuration** | `config.py`, `SWSconfig.ini` | Centralized management of server credentials, database settings, and geographic filters. |
| **Database Helpers** | `ognddbfuncs.py`, `ogntfuncs.py` | Abstraction layer for all SQL interactions. |
| **Identity Mapping** | `ksta.py`, `ogntfuncs.py` | Maintains lists of known gliders and the OGN-to-FLARM ID mapping. |
| **Utilities** | `dtfuncs.py`, `flarmfuncs.py` | Helper functions for date/time manipulation and FLARM-specific logic. |

---

## Data Flow

1.  **Ingestion**: `SWiface.py` reads a raw ASCII packet from the TCP socket.
2.  **Parsing**: The packet is passed to `parserfuncs.py`, which returns a structured dictionary (`msg`).
3.  **Filtering**: `SWiface.py` checks if the message's latitude/longitude is within the configured bounds.
4.  **Enrichment**: If the ID is an OGN tracker, it is mapped to its corresponding FLARM ID via the `ognttable`.
5.  **Storage**: The final, enriched data is written to the `OGNDATA` table in the configured database.

---

## Configuration

The application is configured via `SWSconfig.ini`, which is typically located in `/etc/local/`. 

### Key Configuration Sections

*   **`[APRS]`**:
    *   `APRS_SERVER_HOST`: The hostname of the APRS server.
    *   `APRS_SERVER_PORT`: The port to connect to.
    *   `APRS_USER` / `APRS_PASSCODE`: Credentials for the APRS network.
    *   `APRS_FILTER_DETAILS`: Optional custom APRS filter string.
*   **`[location]`**:
    *   `location_name`: Name of the airport/site (used to resolve lat/lon).
    *   `location_latitude` / `location_longitude`: Manual coordinates if name resolution fails.
    *   `SPOT` / `LT24` / `SKYLINE` / `OGNT`: Boolean flags to enable/disable integration with other services.
*   **`[filter]`**:
    *   `FILTER_LATI1` through `FILTER_LATI4`: Defines the geographic bounding box for data collection.
*   **`[server]`**:
    *   `MySQL`: `True` to use MySQL, `False` for SQLite3.
    *   `DBhost`, `DBuser`, `DBpasswd`, `DBname`: Database connection details.
    *   `DBpath`: Path to the SQLite database file if not using MySQL.

---

## Installation & Setup

### Prerequisites
*   Python 3
*   Required dependencies listed in `requirements.txt`

### Deployment Options
1.  **Manual Installation**: Follow the steps in `INSTALL.md`.
2.  **Docker**: Use the configurations provided in the `dockerfiles/` directory.
3.  **Vagrant**: Use the `provisioning/` directory for automated environment setup.

---

*Documentation generated on 2026-07-03*
