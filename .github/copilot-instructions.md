# Copilot instructions for SWIface (SWSsrc)

Purpose: concise, actionable guidance for Copilot sessions working on this repository — exact commands, high-level architecture, and repo-specific conventions.

---

1) Build, test, and lint commands

- Python deps (recommended venv):
  - python3 -m pip install --upgrade pip
  - python3 -m pip install -r requirements.txt

- Linting (install flake8 separately):
  - pip install flake8
  - flake8  # default rules; run from repo root
  - Lint a single file: flake8 path/to/file.py --max-line-length=120

- Run the main daemon:
  - From repository root: python3 SWiface.py
  - Use the provided wrapper scripts in sh/ where available: bash sh/<script>.sh

- Database schema / creation:
  - Initialize DB (SQLite/MySQL) using DBcreate.py and DBschema.sql
  - Example (SQLite): python3 DBcreate.py --sqlite /path/to/SWiface.db
  - Example (MySQL): mysql -u <user> -p < DBschema.sql  (ensure credentials from SWSconfig.ini)

- Packaging:
  - composer.json exists for optional PHP tooling: composer install
  - No dedicated test runner found; if tests are added, use pytest and run single tests with:
    - pytest tests/test_mod.py::test_name
    - pytest -k "keyword"

---

2) High-level architecture (big picture)

- Purpose: collect APRS telemetry for a competition area and persist it to SQLite3 or MySQL for Silent Wings consumers.

- Core components:
  - SWiface.py — main daemon: TCP socket to APRS server, main loop, filtering, and persistence.
  - parserfuncs.py — parsing layer that decodes APRS packets into structured dicts.
  - ognddbfuncs.py / ogntfuncs.py — DB helpers and identity mapping (OGN-to-FLARM)
  - DBschema.sql & DBcreate.py — database schema and initialisation scripts.
  - config.py & config.template — runtime configuration (SWSconfig.ini).
  - sh/ — operational wrappers used to start/monitor processes.
  - provisioning/ & dockerfiles/ — deployment options (Vagrant/Docker).

- Data flow: APRS TCP → parserfuncs → SWiface processing (filtering, enrichment) → DB (OGNDATA, RECEIVERS, etc.).

---

3) Key conventions and repo-specific patterns

- Config location & override:
  - Default config: /etc/local/SWSconfig.ini (template: config.template)
  - Override with CONFIGDIR environment variable (config.py honors CONFIGDIR).

- PID/ALIVE files:
  - PIDfile is set in config (default /tmp/SWS.pid). Processes write pid/alive markers; graceful shutdown handlers remove them.

- DB selection:
  - `MySQL` in SWSconfig.ini controls MySQL vs SQLite. DBpath controls SQLite location.

- Feature toggles:
  - SPIDER, SPOT, LT24, SKYLINE, OGNT flags in config enable/disable integrations. Treat these flags as primary runtime feature switches.

- Symlinked/shared code:
  - Several helper modules (parserfuncs, ognddbfuncs, etc.) may be symlinked to a shared /nfs/OGN/src/funcs/ tree. Editing such modules impacts other projects — inspect with `readlink` before modifying.

- Global state & star-imports:
  - Modules use module-level globals and sometimes `from X import *`. Be cautious changing global caches or initialization order.

- Run from repo root:
  - Many scripts and the daemon expect to be executed from the repository root so relative paths (sh/, DBschema.sql, config.template) resolve correctly.

---

4) Useful file pointers
- Main daemon: SWiface.py
- Parser: parserfuncs.py
- DB schema/init: DBschema.sql, DBcreate.py
- Config: config.template, config.py (reads SWSconfig.ini)
- Operational scripts: sh/*
- Deployment: dockerfiles/, provisioning/

---

Summary: added concise Copilot instructions with concrete commands, architecture overview, and repository conventions (config override, PID lifecycle, feature flags, symlinked modules). If you want this file committed and pushed to origin/master, choose to commit now.
