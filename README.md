# XBee 802.15.4 + BME (Cities PRO) – WSN Mini Project

Small wireless sensing demo using **Libelium/Waspmote**, **XBee 802.15.4 (Series 1)**, and **Cities PRO (BME/BME280)** to transmit temperature, humidity, and pressure.
This repository contains two sketches: **sender** and **receiver**.

## Repo Structure

```
.
├─ sender/      # sender.ino
├─ receiver/    # receiver.ino
└─ README.md
```

## Hardware

* Waspmote + XBee 802.15.4 (Series 1)
* Cities PRO board with **BME/BME280** sensor (socket A)
* USB programmer / Waspmote IDE

## Network Config

* **PAN ID:** `0x1234`
* **Channel:** `0x0F`
* **AES Encryption:** `0` (disabled)  ← enable for non-demo use
* **Node IDs:** `node_TX` (sender), `node_RX` (receiver)

> Adjust in code: `panID`, `channel`, `encryptionMode`, `encryptionKey`, `setNodeIdentifier()`.

## Sketches

* `sender/sender.ino`: reads BME (temperature, humidity, pressure), builds ASCII frame, sends via XBee to `node_RX`.
* `receiver/receiver.ino`: receives frames, parses values, stores last 10 packets, prints **median** and **average**.

## Payload Format

Recommended ASCII format with tags:

```
TEMP:23.67#HUM:42.91#PRES:98820.40#
```

> Parsing by **splitting** on `#`/`:` is safer than hard-coded byte offsets.

## Quickstart (Build & Upload)

1. Open sketches in **Waspmote IDE**.
2. Select the correct board/port.
3. Upload `sender.ino` to the TX node and `receiver.ino` to the RX node.
4. Open Serial Monitor to view logs.

## Output (Receiver)

* Prints each received frame.
* Calculates **median** & **average** over batches of 10 packets for:

  * Temperature (°C)
  * Humidity (%)
  * Pressure (Pa) — tip: you can also display **hPa** (Pa/100)

## Notes

* Don’t commit vendor SDK/libraries; install Libelium libraries from the official source.
* If you change the payload format, update the receiver parsing accordingly.
* For security, set `encryptionMode = 1` and use a proper 16-byte `encryptionKey`.

