#!/usr/bin/env bash
set -euo pipefail

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
catalog_path="${repository_root}/catalog/v1/releases.json"
signature_path="${catalog_path}.sig"
public_key_der="${repository_root}/trust/catalog-development-p256-public.der"
temporary_root="$(mktemp -d)"
trap 'rm -rf "${temporary_root}"' EXIT

if [[ ! -f "${public_key_der}" ]]; then
  openssl base64 -d -A \
    -in "${repository_root}/trust/catalog-development-p256-public.der.base64" \
    -out "${public_key_der}"
fi

openssl pkey -pubin -inform DER -in "${public_key_der}" -out "${temporary_root}/catalog-public.pem"
openssl base64 -d -A -in "${signature_path}" -out "${temporary_root}/catalog.sig.der"
openssl dgst -sha256 -verify "${temporary_root}/catalog-public.pem" \
  -signature "${temporary_root}/catalog.sig.der" "${catalog_path}"

jq -e '
  .contract == "vhos.release-catalog" and
  .contract_version == "1.0.0" and
  (.artifacts | type == "array") and
  ([.artifacts[].artifact_id] | length == (unique | length))
' "${catalog_path}" >/dev/null

index=0
while IFS= read -r artifact; do
  artifact_id="$(jq -r '.artifact_id' <<<"${artifact}")"
  download_url="$(jq -r '.download_url' <<<"${artifact}")"
  expected_sha256="$(jq -r '.sha256' <<<"${artifact}")"
  expected_bytes="$(jq -r '.byte_count' <<<"${artifact}")"
  destination="${temporary_root}/artifact-${index}"
  curl --fail --location --silent --show-error "${download_url}" --output "${destination}"
  actual_sha256="$(shasum -a 256 "${destination}" | awk '{print $1}')"
  actual_bytes="$(wc -c < "${destination}" | tr -d ' ')"
  [[ "${actual_sha256}" == "${expected_sha256}" ]] || {
    echo "${artifact_id}: SHA-256 mismatch" >&2
    exit 1
  }
  [[ "${actual_bytes}" == "${expected_bytes}" ]] || {
    echo "${artifact_id}: byte-count mismatch" >&2
    exit 1
  }
  echo "${artifact_id}: verified ${actual_bytes} bytes"
  index=$((index + 1))
done < <(jq -c '.artifacts[]' "${catalog_path}")
