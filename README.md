### Offline Real-Time Speech-to-Speech Translation Node

A standalone, mobile edge-computing application designed for low-latency, privacy-preserving translation environments. It integrates on-device acoustic modeling, localized neural machine translation, and native speech synthesis into a unified, zero-connectivity processing pipeline.

---

## Project Overview

EVoice establishes an isolated translation framework utilizing lightweight machine learning models executed directly on host hardware. 

The system consists of three pipelines:
1. **Acoustic Speech Capture (Vosk Engine):** Local real-time speech-to-text decoding using optimized Kaldi-based models to parse raw audio streams into structural text arrays.
2. **On-Device Neural Translation (Google ML Kit):** An offline machine translation layer that maps parsed text values across an internal multilingual dictionary model without cloud handshakes.
3. **Localized Speech Synthesis (Android Native TTS):** A downstream processing sequence that translates completed string translations back into fluid physical audio waves.

---

## System Architecture
┌────────────────────────┐              ┌────────────────────────┐
│    Microphone Input    │              │   Acoustic Pipeline    │
│   (Raw Audio Stream)   │              │     (Vosk Engine)      │
├────────────────────────┤              ├────────────────────────┤
│  • 16 kHz Sampling     │  ──────────► │  • Kaldi Mobile Model  │
│  • PCM 16-bit Mono     │              │  • Real-Time Decoding  │
└────────────────────────┘              └───────────┬────────────┘
│ (Text Array)
▼
┌────────────────────────┐              ┌────────────────────────┐
│    Audio Synthesis     │              │   Neural Translation   │
│   (Native Android)     │              │    (Google ML Kit)     │
├────────────────────────┤              ├────────────────────────┤
│  • Flutter TTS Plugin  │  ◄────────── │  • Offline NMT Engine  │
│  • Multilingual Audio  │ (Target Text)│  • Local Inference     │
└────────────────────────┘              └────────────────────────┘
### 1. Acoustic Speech Pipeline (Vosk)
* **Hardware:** Host Device Microphone Array, Arm-based CPUs.
* **Pipeline Flow:** The system monitors physical audio capture channels, pulling stream packets bound to a strict 16 kHz, PCM 16-bit mono baseline format. The data block passes directly into a locally stored, lightweight Kaldi acoustic model. This model runs continuous, CPU-based inference loops to translate acoustic structures into string characters while maintaining a separate execution context to isolate UI blocking.

### 2. Neural Translation Pipeline (ML Kit)
* **Hardware:** Native Device Storage and CPU.
* **Pipeline Flow:** Operates entirely within the device memory space utilizing pre-downloaded on-device Neural Machine Translation (NMT) files. Once the acoustic pipeline releases a fully generated string array, the translation engine captures it and parses it locally through structural multilingual model blocks. This setup supports immediate translation routing between English, Hindi, and Telugu without cloud dependencies or API calls.

### 3. Localized Speech Synthesis Pipeline (Flutter TTS)
* **Hardware:** Device Audio Hardware / Speaker Output.
* **Pipeline Flow:** Upon receiving the target language string output from the neural machine translation module, the system calls a dedicated platform channel binding interface. It feeds the string parameter straight into the native Android text-to-speech framework using the Flutter TTS plugin, triggering an immediate, low-latency audio transmission of the translated text via the device speakers.

---

## Repository File Structure

| File Name / Path | Placement / Environment | Functional Purpose |
| :--- | :--- | :--- |
| `lib/` | Flutter Framework (Dart) | Core application layer driving UI view trees, audio streaming bindings, and translation state management loops. |
| `pubspec.yaml` | Project Configuration | Declares asset boundaries, package tracking configurations, and strict dependency rules for Vosk and ML Kit plugins. |
| `android/` | Android Platform (Java/Kotlin) | Manages native OS hooks, hardware permission configurations, and low-level platform channel interface mappings. |

---

## Hardware Calibration & System Specifications

### Audio Input Configuration
* **Sampling Rate:** 16,000 Hz
* **Encoding Format:** PCM 16-bit unsigned integer channels
* **Channel Profile:** Mono configuration to minimize memory allocations and inference delays

### Model Footprint Management
* **Inference Platform:** CPU-centric processing (Zero GPU requirements).
* **Storage Distribution:** Acoustic models and language translation profiles are compiled and packed right into local memory space to enforce strict user data privacy.

---

## System Roadmap

### Current Features
* Continuous, zero-connectivity edge speech processing arrays.
* Fully local, privacy-first data persistence layers ensuring no remote packet sniffing risks.
* Multi-threaded pipeline execution loops protecting user interface frames from processing lag.
* Integrated multi-directional translation matrix mapping English, Hindi, and Telugu.

### Future Milestones
* **Adaptive Noise Filtering:** Build software low-pass filter algorithms directly into the microphone capture pipeline to mitigate ambient environment acoustic bleed.
* **Dynamic Model Offloading:** Implement adaptive memory cleanups to gracefully unload unused translation dictionaries when host device RAM headroom shrinks.
* **Expanded Language Matrix:** Expand internal binary configurations to support more regional language tracking sets without ballooning application storage footprint.
