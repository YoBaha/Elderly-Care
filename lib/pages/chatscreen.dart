import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:logger/Logger.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'secrets.dart';
import 'upload_user_voice_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late stt.SpeechToText _speech;
  bool _speechInitialized = false;
  var logger = Logger();
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _selectedVoice;

  final List<Map<String, dynamic>> _messages = [];

  final Map<String, String> _languages = {
    'English': 'en-US',
    'French': 'fr-FR',
    'Spanish': 'es-ES',
    'German': 'de-DE',
    'Arabic': 'ar-TN',
  };

  String _selectedLanguage = 'fr-FR';
  late GenerativeModel _generativeModel;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initializeGemini();
    _loadSelectedVoice();
  }

  Future<void> _loadSelectedVoice() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedVoice = prefs.getString('selected_voice');
    });
  }

  void _initializeGemini() {
    final apiKey = OPEN_API_KEY;
    if (apiKey.isEmpty) {
      logger.e('No API_KEY found in secrets.dart');
      return;
    }

    _generativeModel = GenerativeModel(
      model: 'gemini-2.0-flash', // Updated model name
      apiKey: apiKey,

      // apiVersion: 'v1beta',     // Explicitly specify API version
    );
  }

  void _initSpeech() async {
    _speech = stt.SpeechToText();
    bool initialized = await _speech.initialize(
      onStatus: (status) => logger.i("Status: $status"),
      onError: (error) => logger.e("Initialization Error: $error"),
    );
    setState(() => _speechInitialized = initialized);
  }

  void _startListening() {
    if (!_speechInitialized) {
      _addMessage("Speech recognition not available.", true);
      return;
    }

    _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          String userText = result.recognizedWords;
          _addMessage(userText, true);
          _generateResponse(userText);
        }
      },
      listenFor: const Duration(seconds: 180),
      localeId: _selectedLanguage,
    );
  }

  void _stopListening() => _speech.stop();

  void _addMessage(String text, bool isUser) {
    setState(() {
      _messages.insert(0, {
        'text': text,
        'isUser': isUser,
        'timestamp': DateTime.now(),
        'audioPath': null,
      });
    });
  }

  Future<void> _generateResponse(String prompt) async {
    final prefs = await SharedPreferences.getInstance();
    final voiceId = prefs.getString('selected_voice');

    if (voiceId == null) {
      _addMessage("Please create a voice first", false);
      return;
    }

    try {
      final content = [Content.text(prompt)];
      final response = await _generativeModel.generateContent(content);
      final aiResponse = response.text ?? "No response generated";

      _addMessage(aiResponse, false);

      // ElevenLabs TTS Request
      final ttsResponse = await http.post(
        Uri.parse('https://api.elevenlabs.io/v1/text-to-speech/$voiceId'),
        headers: {
          'xi-api-key': ELEVEN_LABS_API_KEY,
          'Content-Type': 'application/json',
          'Accept': 'audio/mpeg',
        },
        body: jsonEncode({
          'text': aiResponse,
          'model_id': 'eleven_multilingual_v2',
          'voice_settings': {'stability': 0.5, 'similarity_boost': 0.75}
        }),
      );

      logger.i('ElevenLabs Status Code: ${ttsResponse.statusCode}');
      logger.i('ElevenLabs Headers: ${ttsResponse.headers}');

      if (ttsResponse.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final fileName =
            'response_${DateTime.now().millisecondsSinceEpoch}.mp3';
        final file = File('${tempDir.path}/$fileName');

        try {
          await file.writeAsBytes(ttsResponse.bodyBytes);
          logger.i('Audio file saved to: ${file.path}');

          // Verify file existence
          if (await file.exists()) {
            logger.i('File exists, attempting playback...');

            // Update UI and play audio
            setState(() {
              final messageIndex = _messages.indexWhere(
                  (m) => m['text'] == aiResponse && m['audioPath'] == null);
              if (messageIndex != -1) {
                _messages[messageIndex]['audioPath'] = file.path;
              }
            });

            await _audioPlayer.play(DeviceFileSource(file.path));
            logger.i('Playback started successfully');
          } else {
            logger.e('File not found after writing!');
            _addMessage("Audio file creation failed", false);
          }
        } catch (e) {
          logger.e('File write error: $e');
          _addMessage("Audio file creation error", false);
        }
      } else {
        // Log detailed error response
        final errorBody = utf8.decode(ttsResponse.bodyBytes);
        logger.e('ElevenLabs Error: $errorBody');
        _addMessage(
            "Audio generation failed: ${ttsResponse.statusCode}", false);
      }
    } catch (e) {
      logger.e("General Error: $e");
      _addMessage("Error generating response", false);
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat Vocal"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const UploadUserVoiceScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedLanguage,
                    items: _languages.entries
                        .map((e) => DropdownMenuItem(
                              value: e.value,
                              child: Text(e.key),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedLanguage = v!),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    _selectedVoice != null
                        ? 'Voice: ${_selectedVoice!}' // Display voice ID
                        : 'No voice selected',
                    style: TextStyle(
                      color: _selectedVoice != null ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment: message['isUser']
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () async {
                      if (!message['isUser'] && message['audioPath'] != null) {
                        final file = File(message['audioPath']);
                        if (await file.exists()) {
                          await _audioPlayer.play(DeviceFileSource(file.path));
                        }
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: message['isUser']
                            ? const Color(0xFF199A8E)
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        message['text'],
                        style: TextStyle(
                          color:
                              message['isUser'] ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: IconButton(
              icon: Icon(
                _speech.isListening ? Icons.mic : Icons.mic_none,
                size: 50,
                color: _speech.isListening ? Colors.red : Colors.blue,
              ),
              onPressed: _speech.isListening ? _stopListening : _startListening,
            ),
          ),
        ],
      ),
    );
  }
}
