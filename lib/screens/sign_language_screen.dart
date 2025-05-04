import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class SignLanguageScreen extends StatefulWidget {
  const SignLanguageScreen({Key? key}) : super(key: key);

  @override
  _SignLanguageScreenState createState() => _SignLanguageScreenState();
}

class _SignLanguageScreenState extends State<SignLanguageScreen> {
  CameraController? _cameraController;
  List<Map<String, dynamic>> detectedSigns = []; // Store signs with metadata
  bool _isProcessing = false;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    initializeCamera();
    startPolling();
  }

  Future<void> initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _cameraController =
            CameraController(cameras[0], ResolutionPreset.medium);
        await _cameraController!.initialize();
        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No cameras found')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Camera initialization failed: $e')),
      );
    }
  }

  Future<void> fetchDetectionResults() async {
    if (_isProcessing ||
        _cameraController == null ||
        !_cameraController!.value.isInitialized) {
      print(
          'Skipping detection: Processing=$_isProcessing, CameraInitialized=${_cameraController?.value.isInitialized}');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Capture frame
      final image = await _cameraController!.takePicture();
      final bytes = await image.readAsBytes();
      print('Captured image size: ${bytes.length} bytes');

      // Send frame to server
      final url = 'http://192.168.1.14:5000/detect';
      final response = await http.post(
        Uri.parse(url),
        body: bytes,
        headers: {'Content-Type': 'image/jpeg'},
      );

      print('Server response status: ${response.statusCode}');
      print('Server response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Parsed response data: $data');
        setState(() {
          String newSign = data['sign']?.toString() ?? '';
          double confidence = (data['confidence'] ?? 0.0).toDouble();
          if (newSign.isNotEmpty) {
            detectedSigns.add({
              'sign': newSign,
              'confidence': confidence,
              'timestamp': DateTime.now(),
            });
            // Limit to last 10 signs to prevent overflow
            if (detectedSigns.length > 10) {
              detectedSigns.removeAt(0);
            }
          }
          print('Added sign: $newSign, confidence: $confidence');
        });
      } else {
        print('Server error: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error fetching detection: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Detection failed: $e')),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void startPolling() {
    _pollingTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      fetchDetectionResults();
    });
  }

  @override
  Widget build(BuildContext context) {
    print('Rendering UI: detectedSigns=${detectedSigns.length}');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Language Detection'),
      ),
      body: _cameraController == null || !_cameraController!.value.isInitialized
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                // Camera feed (left side)
                Expanded(
                  flex: 2,
                  child: Stack(
                    children: [
                      CameraPreview(_cameraController!),
                      if (_isProcessing)
                        const Center(child: CircularProgressIndicator()),
                    ],
                  ),
                ),
                // Chat-like layout (right side)
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors.grey[200],
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Detected Signs',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ListView.builder(
                            reverse: true, // Newest signs at bottom
                            itemCount: detectedSigns.length,
                            itemBuilder: (context, index) {
                              final signData = detectedSigns[
                                  detectedSigns.length - 1 - index];
                              final sign = signData['sign'];
                              final confidence = signData['confidence'];
                              final timestamp =
                                  signData['timestamp'] as DateTime;
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 1,
                                      blurRadius: 3,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      sign,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Confidence: ${(confidence * 100).toStringAsFixed(2)}%',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    Text(
                                      '${timestamp.hour}:${timestamp.minute}:${timestamp.second}',
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }
}
