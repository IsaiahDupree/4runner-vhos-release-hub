# Release Hub agent rules

- Never commit a private signing key.
- Every catalog byte change requires a new detached signature.
- Catalog entries must reference an existing public artifact and exact observed byte count/hash.
- APK entries require the Android package ID and signing-certificate SHA-256.
- `.vhosota` entries remain independently Ed25519 verified by the mobile client.
- A recovery-only merged ESP32 image must never be labeled OTA-capable.
- Do not give an ESP32 unrestricted internet access; mobile clients fetch and deliver artifacts.
- Android installation must remain owner-approved unless a separately documented managed-device
  policy exists.
