import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';

class BotScreen extends StatefulWidget {
  const BotScreen({super.key});

  @override
  State<BotScreen> createState() => _BotScreenState();
}

class _BotScreenState extends State<BotScreen> {
  final TextEditingController _userMessage = TextEditingController();

  static const apiKey =
      "AIzaSyDXKTD5R3jCDk1uFUOBmpgCD9_vrEfTPJ0"; // Remplace par ta clé API

  final model = GenerativeModel(
    model: 'gemini-1.5-flash', // Passage à Gemini 2.0 Flash
    apiKey: apiKey,
    generationConfig: GenerationConfig(
      temperature: 1,
      topP: 0.95,
      topK: 40,
      maxOutputTokens: 8192,
    ),
  );

  final List<Message> _messages = [];

  Future<void> sendMessage() async {
    final message = _userMessage.text;
    if (message.isEmpty) return;
    _userMessage.clear();

    setState(() {
      _messages.insert(
          0, Message(isUser: true, message: message, date: DateTime.now()));
    });

    try {
      final content = [Content.text(message)];
      final response = await model.generateContent(content);

      setState(() {
        _messages.insert(
          0,
          Message(
            isUser: false,
            message: response.text ?? "Je n'ai pas compris...",
            date: DateTime.now(),
          ),
        );
      });
    } catch (e) {
      setState(() {
        _messages.insert(
          0,
          Message(
            isUser: false,
            message: "Erreur : Impossible de répondre pour le moment.",
            date: DateTime.now(),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('BROXI'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return Messages(
                    isUser: message.isUser,
                    message: message.message,
                    date: DateFormat('HH:mm').format(message.date),
                  );
                },
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 15),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _userMessage,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        labelText: "Pose ta question à BROXI...",
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    color: Colors.deepPurple,
                    onPressed: sendMessage,
                  ),
                ],
              ),
            )
          ],
        ));
  }
}

class Messages extends StatelessWidget {
  final bool isUser;
  final String message;
  final String date;

  const Messages({
    super.key,
    required this.isUser,
    required this.message,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.symmetric(vertical: 5).copyWith(
        left: isUser ? 100 : 10,
        right: isUser ? 10 : 100,
      ),
      decoration: BoxDecoration(
        color: isUser ? Colors.deepPurple : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message,
              style: TextStyle(color: isUser ? Colors.white : Colors.black)),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              date,
              style: TextStyle(
                  color: isUser ? Colors.white70 : Colors.black54,
                  fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class Message {
  final bool isUser;
  final String message;
  final DateTime date;

  Message({
    required this.isUser,
    required this.message,
    required this.date,
  });
}
