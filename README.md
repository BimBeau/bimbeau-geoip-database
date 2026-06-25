# BimBeau GeoIP Database Service

This repository provides the public metadata and distribution files used by **BimBeau Privacy Analytics** to update its local GeoIP database.

The goal of this repository is to document the GeoIP database update endpoint clearly for WordPress.org compliance. The WordPress plugin should not depend on undocumented third-party mirrors. It should only contact this documented service when the site administrator enables or triggers GeoIP database updates.

## What this service provides

- A MaxMind-compatible `GeoLite2-City.mmdb.gz` database archive.
- A `manifest.json` file describing the current archive.
- Integrity metadata such as `sha256`, `size`, and `updated_at`.
- Source and license attribution.

## What this service does not do

- It does not perform visitor IP lookups remotely.
- It does not receive visitor IP addresses from local database lookups.
- It does not provide analytics collection.
- It does not unlock paid or Pro functionality.

When BimBeau Privacy Analytics uses local GeoIP database mode, the plugin downloads or updates the database file, stores it in the WordPress uploads directory, and performs lookups locally on the WordPress server.

## Public endpoints

Current manifest URL:

```text
https://cdn.jsdelivr.net/gh/BimBeau/bimbeau-geoip-database@main/manifest.json
```

Current database URL, once published:

```text
https://cdn.jsdelivr.net/gh/BimBeau/bimbeau-geoip-database@main/dist/GeoLite2-City.mmdb.gz
```

The plugin should read `manifest.json`, validate the expected metadata, download the archive, verify the `sha256` checksum, decompress the archive, and store the resulting `.mmdb` file locally.

## Data sent during database updates

When a WordPress site downloads the manifest or database archive, the CDN and repository host may receive normal HTTP request metadata, such as:

- the server IP address making the request;
- request date and time;
- HTTP headers, including the plugin User-Agent if provided;
- requested file URL.

Local GeoIP lookups do **not** send individual visitor IP addresses to this service.

## Data source and license

The database distributed here is intended to be derived from MaxMind GeoLite2 City data.

GeoLite2 data is provided by MaxMind and is subject to MaxMind’s GeoLite End User License Agreement and attribution requirements. MaxMind documents that GeoLite database downloads and web service requests require a MaxMind account and license key, and that GeoLite users must keep their data up to date.

Useful references:

- MaxMind GeoLite information: https://dev.maxmind.com/geoip/geolite2-free-geolocation-data/
- MaxMind database update documentation: https://dev.maxmind.com/geoip/updating-databases/
- MaxMind GeoLite EULA: https://www.maxmind.com/en/geolite/eula
- MaxMind privacy policy: https://www.maxmind.com/en/privacy-policy

## Maintenance policy

This repository is expected to be updated automatically by a GitHub Actions workflow using BimBeau-controlled MaxMind credentials stored as repository secrets.

Expected update frequency: twice per week.

The workflow must:

1. download the official GeoLite2 City database using MaxMind credentials;
2. extract or normalize the database archive;
3. publish `dist/GeoLite2-City.mmdb.gz`;
4. compute `sha256` and file size;
5. update `manifest.json`;
6. commit the updated files.

## Required repository secrets

The update workflow expects the following GitHub repository secrets:

- `MAXMIND_ACCOUNT_ID`
- `MAXMIND_LICENSE_KEY`

Do not commit MaxMind credentials to the repository.

## WordPress.org compliance note

BimBeau Privacy Analytics must document this service in its `readme.txt` before using it from the WordPress.org Free package. The plugin should also make the remote update behavior clear in the admin UI and avoid contacting this service for local lookups after the database has been downloaded.
