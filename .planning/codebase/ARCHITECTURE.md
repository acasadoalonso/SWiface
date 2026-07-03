# Architecture

**Analysis Date:** 2026-07-03

## System Overview

```text
┌─────────────────────────────────────────────────────────────┐
│                    SWiface Daemon (Main Loop)               │
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

## Component Responsibilities

| Component | Responsibility | File |
|-----------|----------------|------|
| **Main Daemon** | Manages socket connection, main event loop, keep-alives, and lifecycle. | `SWiface.py` |
| **APRS Parser** | Decodes raw ASCII APRS packets into structured dictionaries. | `parserfuncs.py` |
| **Data Processor** | Applies geographic filters, handles ID pairing (OGN/FLARM), and manages state. | `SWiface.py` |
| **DB Helpers** | Provides abstraction for database operations (inserting fixes, updating receivers). | `ognddbfuncs.py`, `ogntfuncs.py` |
| **Configuration** | Centralized settings for server, DB, credentials, and filters. | `config.py` |

## Pattern Overview

**Overall:** Event-driven Daemon with Layered Processing

**Key Characteristics:**
- **Socket-based Ingestion:** Continuous stream of data from a remote TCP server.
- **Dictionary-based Messaging:** Internal communication via structured Python dictionaries.
- **Unified Identity:** Mapping multiple tracking IDs (OGN, FLARM) to a single aircraft identity.

## Layers

**Ingestion Layer:**
- Purpose: Maintain connection to the APRS network and receive raw data.
- Location: `SWiface.py`
- Contains: Socket management, login/authentication, keep-alive logic.
- Depends on: `config.py`
- Used by: Main loop.

**Parsing Layer:**
- Purpose: Transform unstructured text into structured data.
- Location: `parserfuncs.py`
- Contains: `parseraprs` function, aircraft type mapping, source identification.
- Depends on: `ogn.parser` (external library), `dtfuncs.py`.
- Used by: `SWiface.py`.

**Processing Layer:**
- Purpose: Validate, filter, and enrich data.
- Location: `SWiface.py`
- Contains: Geographic bounding box checks, ID pairing logic (`ognttable`), station validation.
- Depends on: `parserfuncs.py`, `config.py`, `ksta.py`.
- Used by: Main loop.

**Persistence Layer:**
- Purpose: Store processed telemetry for long-term analysis.
- Location: `ognddbfuncs.py`, `ogntfuncs.py`
- Contains: SQL execution logic for `OGNDATA` and `RECEIVERS` tables.
- Depends on: `sqlite3` or `MySQLdb`.
- Used by: `SWiface.py`.

## Data Flow

### Primary Request Path (Telemetry Ingestion)

1. **Ingestion** (`SWiface.py:621`): A raw ASCII packet string is read from the TCP socket via `sock_file.readline()`.
2. **Parsing** (`SWiface.py:666`): The string is passed to `parseraprs(packet_str, msg)` in `parserfuncs.py`.
3. **Decoding** (`parserfuncs.py:381`): The packet is decomposed using the `ogn.parser` library and mapped into the `msg` dictionary.
4. **Filtering** (`SWiface.py:834`): `SWiface.py` checks if the latitude/longitude falls within the configured geographic bounds.
5. **Identity Unification** (`SWiface.py:907`): If the ID is an OGN tracker, it is cross-referenced with the `ognttable` to find the associated FLARM ID.
6. **Persistence** (`SWiface.py:932`): The enriched `msg` data is inserted into the `OGNDATA` table in the database (MySQL or SQLite).

## Key Abstractions

**Message Dictionary (`msg`):**
- Purpose: Represents a single parsed telemetry event.
- Examples: Created in `parserfuncs.py:381`.
- Pattern: Key-value mapping of telemetry fields (lat, lon, alt, speed, etc.).

**ID Pairing Table (`ognttable`):**
- Purpose: Maps OGN tracker IDs to FLARM IDs to ensure data consistency.
- Examples: Built in `SWiface.py:450`.
- Pattern: Dictionary lookup.

## Entry Points

**Daemon Execution:**
- Location: `SWiface.py`
- Triggers: Manual execution via shell.
- Responsibilities: Connects to APRS, starts the infinite loop, handles signals.

## Architectural Constraints

- **Threading:** Single-threaded event loop. All processing (parsing, DB writes) happens sequentially in the main thread.
- **Global state:** Uses several global dictionaries (`fid`, `fsta`, `fsmax`, etc.) to track real-time statistics and station states.
- **Database Dependency:** Requires either a local SQLite file or a reachable MySQL server as defined in `config.py`.

## Error Handling

**Strategy:** Graceful degradation and logging.

**Patterns:**
- **Parser Errors:** Invalid packets are caught, logged to `stderr`, and added to a `parsererrors` list to prevent repeated attempts on bad data.
- **Socket Errors:** Transient socket errors trigger a short sleep before retrying; persistent errors trigger an orderly shutdown.
- **Database Errors:** Caught via try-except blocks to prevent the daemon from crashing on a single failed write.

---

*Architecture analysis: 2026-07-03*
