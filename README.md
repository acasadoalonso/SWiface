# SWiface

**SWiface** is the interface between [Silent Wings](http://www.silentwings.no) (Studio or Viewer)
and the [OGN network](http://wiki.glidernet.org).

It is a single-process Python daemon that logs on to an **OGN APRS** server, subscribes to the
traffic around a competition site, decodes every beacon, filters out what is not relevant, and
stores the resulting fixes in a [SQLite 3](https://sqlite.org) or
[MySQL/MariaDB](https://www.mysql.com/products/) database. Silent Wings (and the companion
[SWiface-PHP](https://github.com/glidernet/SWiface-PHP) web front-end) then read that database to
replay or live-stream the competition.

The daemon is designed to be started in the morning and to **exit by itself at dusk** at the
competition location, so it is normally driven from cron rather than run as a service.

---

## Table of contents

- [How it works](#how-it-works)
- [Repository layout](#repository-layout)
- [Configuration](#configuration)
- [Database](#database)
- [Running it](#running-it)
- [Filtering and data selection](#filtering-and-data-selection)
- [Tracker pairing (OGN tracker ↔ FLARM)](#tracker-pairing-ogn-tracker--flarm)
- [Operational scripts](#operational-scripts)
- [Deployment](#deployment)
- [Dependencies](#dependencies)
- [Known gaps](#known-gaps)
- [Contributing / support](#contributing--support)

---

## How it works

```text
        OGN APRS server (aprs.glidernet.org / glidernN.glidernet.org)
                              │  TCP 14580, server-side filter
                              ▼
   ┌───────────────────────────────────────────────────────────┐
   │  SWiface.py — daemon                                      │
   │                                                           │
   │  1. login + keepalive every 180 s                         │
   │  2. readline() ──► raw APRS packet ──► DATA<yymmdd>.log   │
   │  3. parseraprs()  (parserfuncs.py, uses ogn.parser)       │
   │  4. filter: station, source, GPS quality, packet age,     │
   │             latitude bands, black hole, bad values        │
   │  5. enrich:  max altitude / speed / distance per ID,      │
   │              distance to receiver (geopy geodesic),       │
   │              OGN-tracker ID ──► FLARM ID pairing          │
   │  6. INSERT into OGNDATA, commit per record                │
   │  7. at dusk (astral) ──► shutdown(): flush, write         │
   │     RECEIVERS, print the daily report, exit               │
   └───────────────────────────────────────────────────────────┘
                              │
                              ▼
             SQLite 3 file  or  MySQL / MariaDB database
```

Everything runs in **one thread and one loop**. Parsing, filtering and the database write happen
sequentially per packet; per-day statistics live in module-level dictionaries (`fid`, `fsta`,
`fmaxa`, `fsmax`, …) that are dumped in the end-of-day report.

### Processing layers

| Layer | Where | What it does |
|---|---|---|
| Ingestion | `SWiface.py` | Socket to the APRS server, login string with the filter, keepalives, `SIGTERM` handling, PID/alive files, dusk detection. |
| Parsing | `parserfuncs.py` | Wraps `ogn.parser` and adds hand-written extraction for the fields the library does not return. Produces a flat `msg` dict. |
| Processing | `SWiface.py` | Geographic and quality filters, identity unification, running maxima, distance to the receiving station. |
| Persistence | `SWiface.py`, `ognddbfuncs.py`, `ogntfuncs.py`, `flarmfuncs.py` | `OGNDATA` inserts, `RECEIVERS` upsert at shutdown, OGN DDB lookups, FLARM/registration mapping. |

### The `msg` dictionary

`parseraprs(packet_str, msg)` fills `msg` in place and returns it, or `-1` / `-2` on a parse or
timestamp error. Typical keys: `id`, `aprstype`, `path`, `relay`, `station`, `source`, `otime`,
`time`, `latitude`, `longitude`, `altitude`, `speed`, `course`, `roclimb`, `rot`, `sensitivity`,
`gps`, `uniqueid`, `extpos`, `acfttype`. Receiver-status beacons additionally carry `status`,
`version`, `cpu`, `rf`, `temp`; weather beacons carry `wind_speed`, `wind_direction`,
`temperature`, `humidity`, `rainfall_1h`, `rainfall_24h`, `barometric_pressure`.

The `source` is derived from the APRS TOCALL through the `aprssources` table in `parserfuncs.py`,
which maps ~50 TOCALLs (`OGFLR`, `OGNTRK`, `OGADSB`, `OGNSKY`, `OGNMTK`, `OGSPOT`, `OGNDLY`, …) to
short source codes (`OGN`, `ADSB`, `SKYS`, `MTRK`, `SPOT`, `DLYM`, …).

---

## Repository layout

| Path | Description |
|---|---|
| `SWiface.py` | **The daemon.** Socket, main loop, filtering, statistics and DB writes. Also holds `shutdown()`, `blackhole()`, `chkfilati()`, `compbuildtable()`. |
| `parserfuncs.py` | APRS parsing: `parseraprs()` plus the TOCALL/aircraft-type tables, low-level `get_*` helpers, `getinfoairport()`, `SRSSgetjsondata()`, `alive()`. |
| `config.py` | Reads `SWSconfig.ini` into module-level constants and prints the effective configuration at import time. |
| `config.template` | Annotated template for `SWSconfig.ini`. |
| `ognddbfuncs.py` | OGN device database (DDB) client: `getognreg()`, `getogncn()`, `getognmodel()`, `getognchk()`, plus `findfastestaprs()` which pings `glidern1..5`. |
| `ogntfuncs.py` | `ogntbuildtable()` — builds the OGN-tracker ↔ FLARM pairing table from the `TRKDEVICES` table. |
| `flarmfuncs.py` | `getflarmid()` / `chkflarmid()` against the `GLIDERS` table (MySQL only). |
| `ksta.py` | Hard-coded list of known OGN receivers (Spanish, French, Portuguese, Chilean sites) and the `spanishsta()` / `frenchsta()` helpers. |
| `dtfuncs.py` | Timezone-aware / naive UTC helpers, used to keep working after the `datetime.utcnow()` deprecation. |
| `SWcalsunrisesunset.py` | Standalone script that resolves the site coordinates and writes the next sunset epoch to `<DBpath>/SWS.sunset`. Run before the daemon by `sh/SWlive.sh`. |
| `DBschema.sql`, `DBschema.sqlite3` | SQLite schema (tables, index, view). |
| `SWIFACE.sql` | MySQL/MariaDB schema dump — same tables plus the stored functions `GETBEARING`, `GETBEARINGROSE`, `GETDISTANCE`. |
| `sh/` | Operational shell wrappers (start, daily/weekly/monthly/yearly rollup, backup, health checks) and `crontab.data`. |
| `dockerfiles/` | Container build: `Dockerfile`, `Makefile`, MariaDB / phpMyAdmin helper scripts, standalone and networked start scripts. |
| `provisioning/` | Vagrant + Ansible playbooks (`main.yml`, `lamp.yml`, `docker.yml`, `fail2ban.yml`, `basicpak.yml`) and setup shell scripts. |
| `doc/` | SQL snippets: `adduser.sql`, `OGNDDB.sql`, sample `.my.cnf`. |
| `utils/` | Throwaway scripts used to compare sunset/dusk libraries (`suntime`, `suntimes`, `astral`). |
| `install.sh`, `commoninstall.sh` | Bare-metal / VM installation of the whole stack (Apache, DB, Python deps, cron). |
| `INSTALL.md`, `INSTALL.txt` | Older installation notes (Vagrant / Scotch Box based). |
| `ogn.pull.php` | GitHub post-receive hook endpoint that runs `git pull` on the web server. |
| `aliases`, `html.dir`, `robots.txt`, `Capfile`, `package.json`, `composer.json` | Web-host / shell convenience files, not used by the daemon. |

---

## Configuration

All runtime settings come from a single INI file, **`SWSconfig.ini`**.

- Default location: `/etc/local/SWSconfig.ini`
- Override the directory with the `CONFIGDIR` environment variable (`config.py` reads
  `CONFIGDIR` and appends `SWSconfig.ini`). The `sh/` scripts default `CONFIGDIR` to `/etc/local/`
  when it is unset.
- Start from `config.template`:

  ```bash
  sudo mkdir -p /etc/local
  sudo cp config.template /etc/local/SWSconfig.ini
  sudo $EDITOR /etc/local/SWSconfig.ini
  ```

If the file is missing, `config.py` prints an error and exits.

### `[server]`

| Key | Meaning | Default if absent |
|---|---|---|
| `MySQL` | `True` → MySQL/MariaDB, anything else → SQLite 3 | required |
| `DBhost`, `DBuser`, `DBpasswd`, `DBname` | MySQL connection | required |
| `DBuserread`, `DBpasswdread` | Read-only credentials (used by the web front-end) | required |
| `DBpath` | Directory for the SQLite file, the daily `DATA*.log` and `SWS.sunset` | required |
| `pid` | PID lock file | `/tmp/SWS.pid` |
| `prt` | Verbose printing in the helper modules | `True` |
| `cucFileLocation` | Directory scanned for `*competitiongliders.lst` | `/var/www/html/cuc/` |
| `DELAY` | Seconds added to the fix time for `DLYM` (IGC-mandated delayed) sources | `0` |
| `DDBhost`, `DDBport`, `DDBurl1`, `DDBurl2` | OGN device-database endpoints (primary + fallback) | `ddb.acasado.name:60082`, `DDB.glidernet.org` |

> Note: `config.py` reads all `DB*` keys unconditionally, so they must be present even when running
> on SQLite.

### `[APRS]`

| Key | Meaning |
|---|---|
| `APRS_SERVER_HOST` | APRS server hostname. If set to a single space, `findfastestaprs()` pings `glidern1..5.glidernet.org` and picks the fastest. |
| `APRS_SERVER_PORT` | Usually `14580`. |
| `APRS_USER` | APRS callsign/username (must be longer than 3 characters). |
| `APRS_PASSCODE` | APRS passcode, or `-1` for an unverified (receive-only) login. |
| `APRS_FILTER_DETAILS` | Optional raw APRS filter string, e.g. `filter r/44.11/5.56/100`. Optional — see [Filtering](#filtering-and-data-selection). |

### `[location]`

| Key | Meaning |
|---|---|
| `location_name` | Airport code resolved through `airportsdata`. When it resolves, its coordinates, city, country and timezone win over the manual values. |
| `location_latitude`, `location_longitud` | Manual coordinates, used when the airport code does not resolve. (The key really is `location_longitud`, without the trailing `e`.) |
| `SPOT`, `LT24`, `SKYLINE`, `SPIDER`, `OGNT` | Integration flags, read as the strings `True`/`False`. |
| `LT24username` / `LT24password`, `SPIuser` / `SPIpassword` / `SPISYSid` | Credentials for the corresponding services. |

### `[filter]`

`FILTER_LATI1`…`FILTER_LATI4` define up to two latitude bands used as a client-side post-filter.
`0` disables a band. See below.

---

## Database

The same logical schema is used on both engines.

### `OGNDATA` — one row per accepted fix

`idflarm`, `date` (`yymmdd`), `time` (`hhmmss`), `station`, `latitude`, `longitude`, `altitude`
(metres MSL, clamped to `0` outside `0..15000`), `speed`, `course`, `roclimb`, `rot`,
`sensitivity`, `gps`, `uniqueid`, `distance` (km to the receiving station, or to the home base for
non-OGN sources, `-1` when the station is not yet known), `extpos`, `source`.

Indexed by `(idflarm, date)` on SQLite; MySQL adds `(date,time)`, `(time)`, `(idflarm,date,time)`
and `(idflarm)`.

### `RECEIVERS` — OGN ground stations

`idrec`, `descri`, `lati`, `longi`, `alti`. Written (insert or update) during `shutdown()` from the
station positions collected during the day.

### `GLIDERS` — aircraft registry

`idglider`, `registration`, `cn`, `type`, `source`, `flarmtype`. Read by `flarmfuncs.py`; populated
externally (see `provisioning/GLIDERS.sh`, `doc/OGNDDB.sql`).

### `TRKDEVICES` — tracker pairing / SPOT-LT24 devices

`id`, `owner`, `spotid`, `spotpasswd`, `compid`, `model`, `registration`, `active`, `devicetype`,
`flarmid`. Rows with `active = 1` and a non-empty `flarmid` feed the OGN-tracker pairing table.

### `OGNDATAREG` — view

`OGNDATA` joined with the glider registration and the receiver description.

### Creating the database

```bash
# SQLite 3 — the file must be named SWiface.db inside DBpath
mkdir -p /nfs/OGN/SWdata
sqlite3 /nfs/OGN/SWdata/SWiface.db < DBschema.sql

# MySQL / MariaDB
mysql -u root -p -e "CREATE DATABASE SWIFACE;"
mysql -u root -p SWIFACE < SWIFACE.sql
```

The SQLite database file path is built as `DBpath + "SWiface.db"`, so `DBpath` must end with a
separator.

---

## Running it

```bash
python3 -m pip install -r requirements.txt   # see Dependencies for the extras
python3 SWiface.py            # normal run
python3 SWiface.py prt        # verbose: prints every packet, parse result and SQL statement
```

The only argument understood is the literal string `prt`.

At startup the daemon:

1. refuses to start if `config.PIDfile` already exists (unless `$USER` is `docker`), then writes its
   PID there and registers an `atexit` hook to remove it;
2. resolves the site coordinates and timezone, and computes today's **dusk** with `astral`;
3. builds the tracker pairing table;
4. connects and logs in to the APRS server;
5. opens the raw capture file `<DBpath>/DATA<yymmdd>.log` in append mode;
6. creates `SWS.alive` in the **current working directory** and appends a timestamp to it on every
   keepalive. The `sh/` wrappers `cd $DBpath` first, which is why the liveness checks look for it at
   `$DBpath/SWS.alive`.

Every 180 seconds it sends a keepalive, flushes the socket, the capture file and stdout/stderr, and
rebuilds the pairing table if the competition file changed.

It exits with code `0` once the local hour passes the dusk hour, after `shutdown()` has committed
the database, written the `RECEIVERS` rows, and printed the day's report: per-ID fix counts and
maxima, per-station coverage, the day's maximum altitude and distance, the sources seen, and the
aircraft types seen. `SIGTERM` triggers the same orderly shutdown; `Ctrl-C` is ignored during the
loop and falls through to `shutdown()` when the loop ends.

Typical unattended operation (`sh/crontab.data`):

```cron
00 09 * * * /bin/sh ~/src/SWSsrc/sh/SWlive2.sh      # start for the day
00 23 * * * /bin/sh ~/src/SWSsrc/sh/SWidaily.sh     # daily rollup
45 23 * * 1 /bin/sh ~/src/SWSsrc/sh/SWweekly.sh
00 00 1 * * /bin/sh ~/src/SWSsrc/sh/SWmonthlylog.sh
*/10 10-17 * * * /bin/bash ~/src/SWSsrc/sh/SWtest.sh  # liveness check
```

---

## Filtering and data selection

Filtering happens twice: once **on the APRS server** (to limit what is sent at all) and once
**locally** (to limit what is stored).

### Server-side, chosen at login time

1. If a competition glider list was found, the login carries a `filter b/<id>/<id>/…` budlist of
   exactly the competing FLARM IDs (plus the paired tracker IDs when `OGNT` is on).
2. Otherwise, if `APRS_FILTER_DETAILS` is set, that string is used verbatim.
3. Otherwise, a `filter r/<lat>/<lon>/250` range filter around the site is used.

### Client-side, per packet

| Check | Effect |
|---|---|
| `oksta()` | Drops anything received via the `FLYMASTER` pseudo-station. |
| Source whitelist | Only `OGN`, `MTRK`, `NAVI` and `ADSB` fixes are stored; `SPOT` is explicitly skipped. |
| Beacon type | Receiver/TCPIP and tracker-status beacons are used for bookkeeping only, never stored as fixes. Receiver callsigns starting `BSKY`, `FNB1` or `AIRS` are ignored entirely. |
| GPS quality | Drops fixes whose `gps` accuracy field exceeds 10 in either dimension. |
| Packet age | Drops fixes whose timestamp is more than 3 seconds ahead of the server clock. |
| `chkfilati()` | Drops fixes outside `FILTER_LATI1..2` (and, when set, also outside `FILTER_LATI3..4`). Handles both hemispheres. |
| `blackhole()` | Drops fixes inside a hard-coded box over the Pyrenees (42.578–42.727 N, 0.1025 W–0.183 E) and logs them as `BH:`. |
| Sanity | Drops `latitude == -1`, `longitude == -1` or `altitude == 0`. Distances above 299.9 km are logged as suspect but kept. |

Note that the latitude bands and the black hole are **hard filters**: `FILTER_LATI3/4` are only
honoured when `FILTER_LATI1` is also non-zero, and the black-hole box is not configurable.

---

## Tracker pairing (OGN tracker ↔ FLARM)

A glider may be seen twice — once by its FLARM and once by an OGN tracker or Microtrack device
carrying a different ID. SWiface rewrites the tracker ID to the FLARM ID before the insert, so both
streams land on the same aircraft. Two sources feed the pairing table, tried in this order:

1. **Competition file.** `compbuildtable()` scans `cucFileLocation` for any file whose name contains
   `competitiongliders.lst` and reads it as a JSON list. When the second element starts with `OGN`
   the list is read in pairs (`flarmid, ognid`); when it starts with `MTK` it is read in triples
   (`flarmid, mtkid, mtkid2`). The file's mtime is remembered, so the table is only rebuilt when the
   file actually changes. The same list also becomes the APRS budlist filter.
2. **`TRKDEVICES` table.** If no competition file yielded pairs, `ogntbuildtable()` reads active
   rows from the database instead.

The rewrite only applies to IDs beginning `OGN` or `MTK`.

---

## Operational scripts

All `sh/` scripts read `DBuser` / `DBpasswd` / `DBpath` straight out of `$CONFIGDIR/SWSconfig.ini`
with `grep`+`sed`, so they follow the same configuration file as the daemon.

| Script | Purpose |
|---|---|
| `SWlive.sh` | Runs `SWcalsunrisesunset.py`, then launches `SWiface.py` in the background, logging to `SWproc.log`. |
| `SWlive2.sh` | Same, with a wait for `DBpath` to appear — the variant used from cron. |
| `SWtest.sh`, `SWScheck.sh` | Liveness check: if sunset is still more than 30 minutes away and `SWS.alive` is missing, kill the stale PID and re-run `SWlive.sh`. Deletes `SWS.alive` afterwards so the next run has to recreate it. |
| `SWtestnoip.sh` | Restarts the `noip2` dynamic-DNS client if it died. |
| `SWkillandgo.sh` | Kills every `python3` process and restarts the collector. |
| `SWidaily.sh` | End of day: dumps `OGNDATA` into the archive database, empties and vacuums the live one, refreshes `GLIDERS` from `SAROGN.db`, mails `SWproc.log`, and moves the `DATA*.log` and `cuc/` files to `archive/`. |
| `SWweekly.sh`, `SWmonthlylog.sh`, `SWyearly.sh` | Rollups; the yearly one copies the SQLite DB to `archive/SWiface.Y<yy>.db` and vacuums it. |
| `SWsyncDB.sh` | Dumps the SQLite database and reloads it into MySQL. |
| `SWbkup.sh` | Tars the home directory and `DBpath` onto an NFS backup mount. |
| `SWhealth.sh`, `SWpihealth.sh` | Collect `ifconfig`/`df`/`lsusb`/`uptime` and mail the report. |
| `SWqbr.sh` | Quick registration lookup in the `GLIDERS` table. |
| `calcelestial.sh`, `mailcatcher.install`, `nfs.sh`, `SWppa-remove.sh` | One-off host setup helpers. |

`crontab.data` is a ready-to-paste crontab; `mailnames.template` holds the notification addresses
(`mailnames.txt` is git-ignored).

---

## Deployment

### Docker

```bash
cd dockerfiles
make dev            # build the `swiface` image
# or: make build    # build and tag 0.2.0 / 0.2 / 0
```

The image is Debian-based, clones this repository into `/var/www/main`, copies `config.docker` to
`/etc/local/SWSconfig.ini`, exposes ports 22/80/81, declares volumes for `/var/www`, `/etc/local`
and `/nfs`, and runs `python3 SWiface.py` as its command. `mariadb.sh`, `mariadbnet.sh` and
`mariadbpma.sh` bring up a companion database (and phpMyAdmin) container;
`swiface.standalone.sh` runs the collector with SQLite only. `Mariadb.debian/` contains an
ARM/Raspberry-Pi-specific MariaDB build.

### Vagrant / Ansible

`provisioning/` holds a `Vagrantfile` plus Ansible playbooks — `main.yml` (entry point), `lamp.yml`,
`docker.yml`, `basicpak.yml`, `fail2ban.yml`, `setup.yml` — and the shell helpers `bootstrap.sh`,
`init.sh`, `install.sh`, `SWIFACE.sh`, `ADDUSER.sh`, `CRONTAB.sh`, `GLIDERS.sh`. Run
`provisioning/install.sh` on the target VM.

### Bare metal

`install.sh` (which calls `commoninstall.sh`) installs the LAMP stack, the Python dependencies, the
database and the Apache configuration on Debian/Ubuntu, and takes an optional argument of
`MySQL`, `Mariadb`, `VM` or `docker` to pick the database host. `INSTALL.md` and `INSTALL.txt`
describe the older Vagrant/Scotch-Box route and are partly out of date.

### Where it runs

Originally a Raspberry Pi 3 with a 128 GB SSD under Raspbian Jessie; later an
[Intel NUC](http://www.intel.com/nuc) under Ubuntu, and inside VirtualBox/Vagrant on Windows.
Nothing in the code is platform-specific beyond the shell scripts' assumptions about NFS mounts and
Debian package names.

---

## Dependencies

Python 3 (3.9+ recommended — `zoneinfo` falls back to `backports.zoneinfo` otherwise).

`requirements.txt` currently pins:

```
airportsdata==20241001
geopy==2.4.1
ogn_client==1.2.1
ping3==4.0.8
pytz==2024.1
suntime==1.3.2
```

The daemon additionally imports packages that are **not** listed there, and which you must install
by hand:

```bash
python3 -m pip install astral timezonefinder requests
python3 -m pip install mysqlclient          # only when MySQL = True
python3 -m pip install backports.zoneinfo   # only on Python < 3.9
python3 -m pip install suntimes             # only for utils/testsunset.py
```

External services used at runtime: the OGN APRS servers, the OGN device database
(`DDBurl1` with `DDBurl2` as fallback), and `api.sunrise-sunset.org` for the sunset marker
(`suntime` is used as the fallback when that API is unreachable).

---

## Known gaps

Documented so nobody rediscovers them the hard way:

- **`DBcreate.py` does not exist** in this repository, although `INSTALL.txt` and
  `.github/copilot-instructions.md` still tell you to run it. Create the database directly from
  `DBschema.sql` (SQLite) or `SWIFACE.sql` (MySQL), as shown above.
- **`requirements.txt` is incomplete** — see [Dependencies](#dependencies).
- **The `OGNT` configuration flag is ignored.** `SWiface.py` sets `OGNT = True` unconditionally
  right after reading it from the configuration, so tracker pairing is always enabled.
- **Two exception handlers name undefined classes** (`except exception as e` around the parser call,
  `except Except as e` around the altitude check). If either handler is ever reached it raises
  `NameError` instead of recovering.
- **No automated tests.** `utils/` holds ad-hoc comparison scripts, not a test suite. Linting is
  whatever you bring: `flake8 --max-line-length=120` is what the Copilot instructions suggest.
- Several helper modules (`parserfuncs.py`, `ognddbfuncs.py`, …) may be symlinked into a shared
  `/nfs/OGN/src/funcs/` tree on the production hosts. Check with `readlink` before editing them
  there — other projects consume the same files.

---

## Contributing / support

Please report bugs through the [GitHub issue tracker](https://github.com/acasadoalonso/SWiface/issues).

**Angel Casado** — [acasado (at) acm.org](mailto:acasado@acm.org)

Licensed under the **GNU General Public License, version 2** — see [COPYING](COPYING).
(`package.json` still says ISC; `COPYING` is authoritative.)
