# Deployment architecture and authority boundaries

## What the iPhone can and cannot deploy

The iPhone is the owner-facing release console. It can fetch the signed catalog, download and hash
all artifacts, verify an OBD `.vhosota` package with its pinned Ed25519 key, and deliver that package
to a compatible ESP32 over an authenticated local OTA session. It can also share a verified Android
APK or its HTTPS installation URL.

iOS cannot silently install an APK on another device. Android must download or receive the APK,
verify its package/signing identity, and present the operating system's owner-approved installer.
The A/C recovery image still requires a Mac/PC USB serial flasher; listing it in the catalog does not
pretend that mobile OTA exists.

## Data and control flow

```text
GitHub Releases ---- HTTPS ----> iPhone Release Hub
       |                              |-- verify catalog signature
       |                              |-- verify artifact hash/type
       |                              |-- verify .vhosota Ed25519 signature
       |                              |-- share Android install URL/artifact
       |                              `-- BLE approval + temporary Wi-Fi --> OBD ESP32 inactive slot
       |
       `---------- HTTPS --------> Android Release Hub
                                      |-- verify catalog signature
                                      |-- verify APK hash/package/certificate
                                      `-- Android owner-approved installer

A/C merged recovery image ----> Mac/PC USB serial flasher ----> A/C ESP32-S3
```

Neither ESP32 polls GitHub or joins a general-purpose LAN. This keeps firmware distribution,
vehicle-bus access, and public networking separate. A mobile client may fetch while it has normal
internet, then create a short-lived local transfer session only after device identity, PARKED state,
supply, capture-flush, hardware compatibility, signature, and rollback gates pass.

## Trust layers

1. The exact catalog bytes carry a detached P-256 ECDSA signature and monotonically generated time.
2. Every artifact has a declared SHA-256 and byte count.
3. Android verifies package ID and APK signing-certificate continuity before asking the OS to install.
4. OBD firmware uses an Ed25519-signed `.vhosota` container plus native ESP-IDF signed-image checks.
5. The A/C recovery artifact is explicitly checksum-only and USB-only until its signed OTA firmware exists.

No catalog field can override a device safety gate or convert a recovery artifact into an OTA image.
