# offline_translator

Offline Real-Time Speech-to-Speech Translation (Android)
This project implements a fully offline, real-time speech-to-speech translation system for Android devices powered by Arm-based CPUs. The application captures spoken input, converts it into text using on-device speech recognition, translates it into a target language using a local neural translation model, and generates spoken output using an offline text-to-speech engine. The entire pipeline runs locally on the device, ensuring zero dependency on internet connectivity, cloud services, or external APIs, while maintaining complete user privacy.
Core Components:
Speech-to-Text (STT): Vosk engine with lightweight Kaldi-based models optimized for mobile
Translation: Google ML Kit on-device Neural Machine Translation
Text-to-Speech (TTS): Android native TTS via Flutter TTS plugin
Supported Languages:
English
Hindi
Telugu
Processing Pipeline:
Capture speech input via microphone
Convert speech to text using Vosk
Translate recognized text using ML Kit
Generate translated speech output using TTS
Key Features:
Fully offline (no internet or cloud dependency)
Privacy-preserving (no data transmission)
Real-time processing with low latency
Lightweight models for stable mobile performance
Background execution to prevent UI blocking
Technical Highlights:
Audio format: 16 kHz, PCM 16-bit mono
Models stored and executed locally
CPU-based inference (no GPU required)
Efficient memory and resource management
Use Cases:
Communication in low or no network environments
Privacy-sensitive applications
Edge AI and on-device ML demonstrations
Conclusion:
Demonstrates feasibility of real-time, offline AI translation on mobile devices
Provides a scalable, privacy-first solution for multilingual communication