# Codebase Structure

**Analysis Date:** 2026-07-03

## Directory Layout

```
/tmp/SWiface/
├── SWiface.py          # Main daemon and orchestrator
├── parserfuncs.py      # APRS packet parsing logic
├── config.py           # Application configuration
├── DBschema.sql        # Database schema definition
├── DBschema.sqlite3    # Local SQLite database
├── ksta.py             # Known gliders/stations lookup
├── dtfuncs.py          # Date and time utility functions
├── flarmfuncs.py       # FLARM-specific helper functions
├── ognddbfuncs.py      # OGN Database interaction helpers
├── ogntfuncs.py        # OGN/FLARM pairing logic
├── requirements.txt    # Python dependencies
└── ...                 # Other configuration and utility files
```

## Directory Purposes

**Root Directory:**
- Purpose: Contains the core application logic and configuration.
- Contains: Python source files, database files, and deployment scripts.
- Key files: `SWiface.py`, `parserfuncs.py`, `config.py`.

**doc/**
- Purpose: Documentation and SQL samples.
- Contains: `.sql` files for database setup.

**dockerfiles/**
- Purpose: Containerization configuration.
- Contains: Dockerfiles for various deployment modes (standalone, MariaDB, etc.).

**provisioning/**
- Purpose: Infrastructure setup scripts.
- Contains: Shell scripts for system configuration (crontab, fail2ban, etc.).

**sh/**
- Purpose: Maintenance and operational shell scripts.
- Contains: Backup, health check, and synchronization scripts.

## Key File Locations

**Entry Points:**
- `SWiface.py`: The primary daemon process.

**Configuration:**
- `config.py`: Main application settings.
- `config.template`: Template for configuration.

**Core Logic:**
- `parserfuncs.py`: The parsing engine.
- `ognddbfuncs.py`: Database interaction layer.

**Testing/Utilities:**
- `utils/`: Contains testing scripts for celestial and sunset calculations.

## Naming Conventions

**Files:**
- Python files: `snake_case.py` (e.g., `parserfuncs.py`).
- SQL files: `UPPERCASE.sql` (e.g., `DBschema.sql`).

**Directories:**
- Standard lowercase names (e.g., `dockerfiles`, `provisioning`).

## Where to Add New Code

**New Parsing Logic:**
- Implementation: `parserfuncs.py`

**New Database Operations:**
- Implementation: `ognddbfuncs.py` or `ogntfuncs.py`

**New Utility Functions:**
- Implementation: `dtfuncs.py` or create a new module in the root.

**New Maintenance Scripts:**
- Implementation: `sh/` directory.

---

*Structure analysis: 2026-07-03*
