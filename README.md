# 4Runner VHOS Release Hub

Public release metadata and installation handoff for the related Vehicle Health OS repositories.
The iPhone and Android head unit consume one signed catalog, verify every downloaded artifact, and
then use a target-specific installation path.

| Target | Delivery path | Current release state |
| --- | --- | --- |
| Android head unit | HTTPS download, APK certificate/hash verification, Android owner-approved installer | Development APK available |
| OBD/CAN ESP32 | Mobile download and Ed25519 verification, encrypted BLE authorization, temporary authenticated Wi-Fi upload | Package available; vehicle safety evidence can still block install |
| A/C ESP32-S3 | HTTPS download and checksum verification, USB serial recovery flash | Recovery-only; BLE/OTA firmware pending |

Neither ESP32 receives unrestricted internet access. Android installation remains controlled by
Android; an iPhone may share a verified APK or installation URL but cannot silently install it.

## Public endpoints

- Catalog: `https://github.com/IsaiahDupree/4runner-vhos-release-hub/releases/latest/download/releases.json`
- Detached signature: append `.sig` to the catalog filename
- Portal: `https://isaiahdupree.github.io/4runner-vhos-release-hub/`
- Current Android APK: [`0.1.0-dev.16`](https://github.com/IsaiahDupree/4runner-vhos-android/releases/download/android-v0.1.0-dev.16/app-debug.apk) — 10,816,489 bytes; SHA-256 `8d8ba19061705d3c3901c749b1a0df1cb7c7c0e626c99676b7655e70441cc9a9`

The detached signature is P-256 ECDSA over the exact catalog bytes. Consumers pin the development
catalog public key from `trust/`; artifacts retain their own target trust checks as defense in
depth.

See [docs/DEPLOYMENT-ARCHITECTURE.md](docs/DEPLOYMENT-ARCHITECTURE.md) for authority boundaries.
