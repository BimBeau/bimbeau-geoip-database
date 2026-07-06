#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK_DIR="${ROOT_DIR}/work"
DIST_DIR="${ROOT_DIR}/dist"
ARCHIVE_PATH="${WORK_DIR}/GeoLite2-City.tar.gz"
MMDB_PATH="${WORK_DIR}/GeoLite2-City.mmdb"
OUTPUT_PATH="${DIST_DIR}/GeoLite2-City.mmdb.gz"
MANIFEST_PATH="${ROOT_DIR}/manifest.json"

DATABASE_DOWNLOAD_URL="https://raw.githubusercontent.com/BimBeau/bimbeau-geoip-database/main/dist/GeoLite2-City.mmdb.gz"

: "${MAXMIND_LICENSE_KEY:?MAXMIND_LICENSE_KEY is required}"

rm -rf "${WORK_DIR}"
mkdir -p "${WORK_DIR}" "${DIST_DIR}"

DOWNLOAD_URL="https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-City&license_key=${MAXMIND_LICENSE_KEY}&suffix=tar.gz"

curl --fail --location --silent --show-error \
  --user-agent "BimBeau GeoIP Database Service" \
  --output "${ARCHIVE_PATH}" \
  "${DOWNLOAD_URL}"

tar -xzf "${ARCHIVE_PATH}" -C "${WORK_DIR}"
FOUND_MMDB="$(find "${WORK_DIR}" -type f -name 'GeoLite2-City.mmdb' | head -n 1)"

if [[ -z "${FOUND_MMDB}" ]]; then
  echo "GeoLite2-City.mmdb was not found in the MaxMind archive." >&2
  exit 1
fi

cp "${FOUND_MMDB}" "${MMDB_PATH}"
gzip -c -9 "${MMDB_PATH}" > "${OUTPUT_PATH}"

SHA256="$(sha256sum "${OUTPUT_PATH}" | awk '{print $1}')"
SIZE="$(wc -c < "${OUTPUT_PATH}" | tr -d ' ')"
UPDATED_AT="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"

cat > "${MANIFEST_PATH}" <<JSON
{
  "schema_version": 1,
  "service": "BimBeau GeoIP Database Service",
  "database": "GeoLite2-City",
  "format": "mmdb.gz",
  "source": "MaxMind GeoLite2 City",
  "license": "GeoLite End User License Agreement",
  "attribution": "This product includes GeoLite2 data created by MaxMind, available from https://www.maxmind.com.",
  "updated_at": "${UPDATED_AT}",
  "download_url": "${DATABASE_DOWNLOAD_URL}",
  "sha256": "${SHA256}",
  "size": ${SIZE},
  "status": "ready"
}
JSON

if grep -q 'cdn.jsdelivr.net' "${MANIFEST_PATH}"; then
  echo "Generated manifest must not use jsDelivr for the GeoIP database archive." >&2
  exit 1
fi

if grep -q '/releases/download/' "${MANIFEST_PATH}"; then
  echo "Generated manifest must not use GitHub release assets unless bbpa-unified explicitly allowlists them." >&2
  exit 1
fi

if ! grep -q "\"download_url\": \"${DATABASE_DOWNLOAD_URL}\"" "${MANIFEST_PATH}"; then
  echo "Generated manifest does not contain the expected download_url." >&2
  echo "Expected: ${DATABASE_DOWNLOAD_URL}" >&2
  exit 1
fi

rm -rf "${WORK_DIR}"

echo "Updated ${OUTPUT_PATH}"
echo "download_url=${DATABASE_DOWNLOAD_URL}"
echo "sha256=${SHA256}"
echo "size=${SIZE}"
