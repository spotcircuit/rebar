---
name: maps-osm
description: Geocode, find nearby POIs, compute travel distance/time, and get turn-by-turn directions using OpenStreetMap data (Nominatim, Overpass, OSRM) with zero API keys and Python stdlib only. Use when an operator or client task needs maps/location data without paying Google Maps fees — Velocity Electric routing, field-tech directions, "what's near this address," travel-time estimates, timezone lookups, or POI scouting for a region.
type: productivity
---

# maps-osm — OpenStreetMap location intelligence

Adapted from the Hermes Agent `maps` skill. 8 commands, ~46 POI categories, no API key, no pip installs. Backed by Nominatim (geocode), Overpass (POIs), OSRM (routing), and TimeAPI.io (timezone).

When this skill writes outputs (GeoJSON, route files, POI tables), drop them under `clients/{client}/maps-{YYYY-MM-DD}/` or `apps/{app}/maps-{date}/`. Never write to `~/`.

## When to reach for it

- A client (e.g. Velocity Electric) is paying for Google Maps and we want a free swap
- "Find me 20 nearby HVAC contractors within 5 miles of this zip"
- "How long to drive from depot to job site?"
- A Telegram-style location pin (lat/lon) lands in a brief and we need POIs around it
- Building a service-area map for a contractor — `area` + `bbox` to enumerate POIs

## Prerequisites

Python 3.8+ stdlib only. No pip installs.

```bash
MAPS=.claude/skills/productivity/maps-osm/scripts/maps_client.py
```

## Commands

### search — Geocode a place name

```bash
python3 $MAPS search "Eiffel Tower"
python3 $MAPS search "1600 Pennsylvania Ave, Washington DC"
```

Returns: lat, lon, display name, type, bounding box, importance score.

### reverse — Coordinates to address

```bash
python3 $MAPS reverse 48.8584 2.2945
```

Returns: full address breakdown (street, city, state, country, postcode).

### nearby — Find places by category

```bash
# By coordinates
python3 $MAPS nearby 48.8584 2.2945 restaurant --limit 10
python3 $MAPS nearby 40.7128 -74.0060 hospital --radius 2000

# By address / city / zip / landmark — --near auto-geocodes
python3 $MAPS nearby --near "Times Square, New York" --category cafe
python3 $MAPS nearby --near "90210" --category pharmacy

# Multiple categories merged
python3 $MAPS nearby --near "downtown austin" --category restaurant --category bar --limit 10
```

Categories: restaurant, cafe, bar, hospital, pharmacy, hotel, guest_house, camp_site, supermarket, atm, gas_station, parking, museum, park, school, university, bank, police, fire_station, library, airport, train_station, bus_stop, church, mosque, synagogue, dentist, doctor, cinema, theatre, gym, swimming_pool, post_office, convenience_store, bakery, bookshop, laundry, car_wash, car_rental, bicycle_rental, taxi, veterinary, zoo, playground, stadium, nightclub.

Each result includes `name`, `address`, `lat`/`lon`, `distance_m`, `maps_url`, `directions_url`, plus promoted tags (`cuisine`, `hours`, `phone`, `website`) when present.

### distance — Travel distance and time

```bash
python3 $MAPS distance "Paris" --to "Lyon"
python3 $MAPS distance "New York" --to "Boston" --mode driving
python3 $MAPS distance "Big Ben" --to "Tower Bridge" --mode walking
```

Modes: driving (default), walking, cycling. Returns road distance, duration, and straight-line distance.

### directions — Turn-by-turn navigation

```bash
python3 $MAPS directions "Eiffel Tower" --to "Louvre Museum" --mode walking
python3 $MAPS directions "JFK Airport" --to "Times Square" --mode driving
```

Returns numbered steps with instruction, distance, duration, road name, and maneuver type.

### timezone — Timezone for coordinates

```bash
python3 $MAPS timezone 48.8584 2.2945
```

Returns timezone name, UTC offset, and current local time.

### area — Bounding box for a place

```bash
python3 $MAPS area "Manhattan, New York"
```

Returns bounding box, width/height in km, approximate area. Feed the bbox into `bbox`.

### bbox — Search within a bounding box

```bash
python3 $MAPS bbox 40.75 -74.00 40.77 -73.98 restaurant --limit 20
```

## Workflow examples

**"Italian restaurants near the Colosseum":**
1. `nearby --near "Colosseum Rome" --category restaurant --radius 500`

**"Service area POI scout for downtown Seattle":**
1. `area "Downtown Seattle"` → grab bbox
2. `bbox S W N E restaurant --limit 30`
3. Save results to `clients/{client}/maps-{date}/seattle-restaurants.json`

**"Walking directions from hotel to venue":**
1. `directions "Hotel Name" --to "Venue Name" --mode walking`

## Pitfalls

- Nominatim ToS: 1 req/s (handled in the script)
- `nearby` requires lat/lon OR `--near "<address>"`
- OSRM routing coverage is best in Europe and North America
- Overpass can be slow during peak hours — script auto-falls between mirrors
- `distance` and `directions` use `--to` flag (not positional)
- Zip codes alone are globally ambiguous; include state/country when needed

## Verification

```bash
python3 .claude/skills/productivity/maps-osm/scripts/maps_client.py search "Statue of Liberty"
# lat ~40.689, lon ~-74.044

python3 .claude/skills/productivity/maps-osm/scripts/maps_client.py nearby --near "Times Square" --category restaurant --limit 3
```
