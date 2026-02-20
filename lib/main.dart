import 'package:flutter/material.dart';
import 'package:vosk_flutter/vosk_flutter.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'dart:io';

void main() {
  runApp(const OfflineTranslatorApp());
}

class OfflineTranslatorApp extends StatelessWidget {
  const OfflineTranslatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TranslatePage(),
    );
  }
}

class TranslatePage extends StatefulWidget {
  const TranslatePage({super.key});

  @override
  State<TranslatePage> createState() => _TranslatePageState();
}

class _TranslatePageState extends State<TranslatePage> {
  late final VoskFlutterPlugin _vosk;

  Model? _model;
  Recognizer? _recognizer;
  SpeechService? _speech;

  FlutterTts _tts = FlutterTts();
  OnDeviceTranslator? _translator;

  String srcLang = 'en';
  String tgtLang = 'hi';

  bool _isListening = false;
  bool _isLoading = true;
  bool _isSpeaking = false;

  String detectedText = "Loading...";
  String translatedText = "";

  final Map<String, String> voskModels = {
    'en': 'vosk-model-small-en-us-0.15',
    'hi': 'vosk-model-small-hi-0.22',
    'te': 'vosk-model-small-te-0.42',
  };

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  // ================= INITIALIZE =================

  Future<void> _initialize() async {
    await Permission.microphone.request();
    await Permission.manageExternalStorage.request();

    _vosk = VoskFlutterPlugin.instance();

    await _loadVoskModel(srcLang);
    await _initializeTranslator();

    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);

    setState(() {
      detectedText = "Tap mic to start";
      _isLoading = false;
    });
  }

  // ================= LOAD VOSK MODEL =================

  Future<void> _loadVoskModel(String languageCode) async {
    try {
      setState(() {
        _isLoading = true;
        detectedText = "Loading model...";
      });

      await _disposeVosk();

      final modelFolder = voskModels[languageCode];
      final modelPath = "/storage/emulated/0/$modelFolder";

      if (!Directory(modelPath).existsSync()) {
        throw Exception("Model not found at $modelPath");
      }

      _model = await _vosk.createModel(modelPath);

      _recognizer = await _vosk.createRecognizer(
        model: _model!,
        sampleRate: 16000,
      );

      _speech = await _vosk.initSpeechService(_recognizer!);
      _speech!.onResult().listen(_onSpeechResult);

      setState(() {
        detectedText = "Model ready!";
        _isLoading = false;
      });

      print("✅ Loaded Vosk model for $languageCode");
    } catch (e) {
      setState(() {
        detectedText = "Model load failed: $e";
        _isLoading = false;
      });
    }
  }

  // ================= DISPOSE VOSK SAFELY =================

  Future<void> _disposeVosk() async {
    if (_speech != null) {
      try {
        await _speech!.stop();
        await _speech!.dispose();
      } catch (_) {}
      _speech = null;
    }

    if (_recognizer != null) {
      try {
        _recognizer!.dispose();
      } catch (_) {}
      _recognizer = null;
    }

    if (_model != null) {
      try {
        _model!.dispose();
      } catch (_) {}
      _model = null;
    }

    await Future.delayed(const Duration(milliseconds: 400));
  }

  // ================= SPEECH RESULT =================

  void _onSpeechResult(String raw) {
    if (_isSpeaking) return;

    try {
      final decoded = json.decode(raw);
      if (decoded is Map && decoded.containsKey('text')) {
        final text = decoded['text'].toString().trim();
        if (text.isNotEmpty) {
          setState(() => detectedText = text);
          _translate(text);
        }
      }
    } catch (_) {}
  }

  // ================= TRANSLATION =================

  Future<void> _initializeTranslator() async {
    await _translator?.close();

    _translator = OnDeviceTranslator(
      sourceLanguage: _getLanguage(srcLang),
      targetLanguage: _getLanguage(tgtLang),
    );

    final manager = OnDeviceTranslatorModelManager();
    await manager.downloadModel(srcLang);
    await manager.downloadModel(tgtLang);
  }

  Future<void> _translate(String text) async {
    if (_translator == null) return;

    final result = await _translator!.translateText(text);
    setState(() => translatedText = result);
    _speak(result);
  }

  // ================= TEXT TO SPEECH =================

  Future<void> _speak(String text) async {
    if (text.isEmpty) return;

    _isSpeaking = true;

    if (_isListening) {
      await _speech?.stop();
      _isListening = false;
    }

    await _tts.setLanguage(tgtLang);
    await _tts.speak(text);

    _isSpeaking = false;
  }

  // ================= LANGUAGE SWITCH =================

  Future<void> _changeLanguages(String newSrc, String newTgt) async {
    setState(() {
      srcLang = newSrc;
      tgtLang = newTgt;
      translatedText = "";
    });

    await _loadVoskModel(srcLang);
    await _initializeTranslator();
  }

  // ================= LANGUAGE MAPPING =================

  TranslateLanguage _getLanguage(String code) {
    switch (code) {
      case 'hi':
        return TranslateLanguage.hindi;
      case 'te':
        return TranslateLanguage.telugu;
      case 'en':
      default:
        return TranslateLanguage.english;
    }
  }

  // ================= MIC =================

  void toggleListening() async {
    if (_speech == null) return;

    if (_isListening) {
      await _speech!.stop();
      setState(() => _isListening = false);
    } else {
      await _speech!.start();
      setState(() => _isListening = true);
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Offline Speech Translator"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButton<String>(
                value: srcLang,
                items: ['en', 'hi', 'te']
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.toUpperCase()),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) _changeLanguages(val, tgtLang);
                },
              ),
              const SizedBox(width: 30),
              DropdownButton<String>(
                value: tgtLang,
                items: ['en', 'hi', 'te']
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.toUpperCase()),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) _changeLanguages(srcLang, val);
                },
              ),
            ],
          ),
          const SizedBox(height: 30),
          Expanded(
            child: Center(
              child: Text(
                detectedText,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                translatedText,
                style: const TextStyle(
                    fontSize: 18, color: Colors.deepPurple),
              ),
            ),
          ),
          const SizedBox(height: 20),
          FloatingActionButton(
            onPressed: toggleListening,
            backgroundColor:
                _isListening ? Colors.red : Colors.deepPurple,
            child: Icon(_isListening ? Icons.stop : Icons.mic),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}