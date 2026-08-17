#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: $0 /absolute/path/to/catalog-private-key.pem" >&2
  exit 2
fi

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
catalog_path="${repository_root}/catalog/v1/releases.json"
signature_path="${catalog_path}.sig"
temporary_signature="$(mktemp)"
trap 'rm -f "${temporary_signature}"' EXIT

openssl dgst -sha256 -sign "$1" -out "${temporary_signature}" "${catalog_path}"
openssl base64 -A -in "${temporary_signature}" -out "${signature_path}"
echo "signed ${catalog_path} -> ${signature_path}"
