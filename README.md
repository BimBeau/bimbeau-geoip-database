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

Current database URL:

```text
https://raw.githubusercontent.com/BimBeau/bimbeau-geoip-database/main/dist/GeoLite2-City.mmdb.gz
```

The database archive is larger than 20 MB. It must not be served through jsDelivr's GitHub CDN endpoint because that endpoint can reject large files with `File size exceeded the configured limit of 20 MB.`

The plugin should read `manifest.json`, validate the expected metadata, download the archive, verify the `sha256` checksum, decompress the archive, and store the resulting `.mmdb` file locally.

## Publishing a release asset

The preferred long-term distribution channel for the `.mmdb.gz` archive is a GitHub Release asset.

Run the `Publish GeoIP release asset` workflow manually after updating `dist/GeoLite2-City.mmdb.gz`. The workflow creates or updates a release, uploads the archive as a release asset, recalculates `sha256` and `size`, and updates `manifest.json` so `download_url` points to the release asset.

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
