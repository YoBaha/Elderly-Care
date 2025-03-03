import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'secrets.dart';

class UploadUserVoiceScreen extends StatefulWidget {
  const UploadUserVoiceScreen({super.key});

  @override
  _UploadUserVoiceScreenState createState() => _UploadUserVoiceScreenState();
}

class _UploadUserVoiceScreenState extends State<UploadUserVoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _voiceNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<PlatformFile> _selectedFiles = [];
  bool _isUploading = false;

  Future<void> _pickFiles() async {
    try {
      var result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav'],
        allowMultiple: true,
      );
      if (result != null) {
        setState(() => _selectedFiles = result.files);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error picking files: $e');
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one audio file')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.elevenlabs.io/v1/voices/add'),
      );

      // Add audio files
      for (final file in _selectedFiles) {
        request.files.add(await http.MultipartFile.fromPath(
          'files',
          file.path!,
          filename: file.name,
        ));
      }

      // Add metadata
      request.fields['name'] = _voiceNameController.text;
      request.fields['description'] = _descriptionController.text;

      // Add headers
      request.headers['xi-api-key'] = ELEVEN_LABS_API_KEY;
      request.headers['Accept'] = 'application/json';

      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final voiceId = jsonDecode(body)['voice_id'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('selected_voice', voiceId);

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Voice cloned successfully!')),
        );
      } else {
        final errorMessage =
            jsonDecode(body)['detail']['message'] ?? 'Unknown error';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $errorMessage')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Voice Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _voiceNameController,
                decoration: const InputDecoration(
                  labelText: 'Voice Name',
                  prefixIcon: Icon(Icons.voice_chat),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter voice name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 4,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter description' : null,
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: const Text('Select Audio Files (3+ recommended)'),
                onPressed: _pickFiles,
              ),
              const SizedBox(height: 8),
              Text(
                'Selected files: ${_selectedFiles.length}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isUploading ? null : _submitForm,
                child: _isUploading
                    ? const CircularProgressIndicator()
                    : const Text('Create Voice'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
