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
  List<Map<String, dynamic>> detectedSigns = [];
  bool _isProcessing = false;
  Timer? _pollingTimer;
  int _retryCount = 0;
  static const int _maxRetries = 2;

  @override
  void initState() {
    super.initState();
    initializeCamera();
    warmUpApi();
    startPolling();
  }

  Future<void> initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        CameraDescription? frontCamera;
        for (var camera in cameras) {
          if (camera.lensDirection == CameraLensDirection.front) {
            frontCamera = camera;
            break;
          }
        }
        _cameraController = CameraController(
          frontCamera ?? cameras[0],
          ResolutionPreset.medium,
        );
        await _cameraController!.initialize();
        print('Camera initialized: ${_cameraController!.value.isInitialized}, '
            'LensDirection: ${_cameraController!.description.lensDirection}');
        setState(() {});
      } else {
        print('No cameras found');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No cameras found')),
        );
      }
    } catch (e) {
      print('Camera initialization failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Camera initialization failed: $e')),
      );
    }
  }

  Future<void> warmUpApi() async {
    try {
      final response = await http
          .get(Uri.parse('https://sign-language-api-a443.onrender.com'))
          .timeout(
            const Duration(seconds: 45),
            onTimeout: () => http.Response('Timeout', 408),
          );
      print('Warm-up request status: ${response.statusCode}');
    } catch (e) {
      print('Warm-up request failed: $e');
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

      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Detecting sign...')),
      );

      // Send frame to server with retries
      bool success = false;
      int attempt = 0;
      http.Response? response;
      while (attempt <= _maxRetries && !success) {
        try {
          final url = 'https://sign-language-api-a443.onrender.com/detect';
          response = await http.post(
            Uri.parse(url),
            body: bytes,
            headers: {'Content-Type': 'image/jpeg'},
          ).timeout(
            const Duration(seconds: 45),
            onTimeout: () {
              throw TimeoutException(
                  'API request timed out (attempt ${attempt + 1})');
            },
          );
          success = response.statusCode == 200;
        } catch (e) {
          print('Attempt ${attempt + 1} failed: $e');
          attempt++;
          if (attempt <= _maxRetries) {
            await Future.delayed(const Duration(seconds: 2));
          }
        }
      }

      // Hide loading indicator
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (success && response != null) {
        print('Server response status: ${response.statusCode}');
        print('Server response body: ${response.body}');
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
            if (detectedSigns.length > 10) {
              detectedSigns.removeAt(0);
            }
          }
          print('Added sign: $newSign, confidence: $confidence');
          _retryCount = 0; // Reset retries on success
        });
      } else {
        final errorMsg = response != null
            ? 'Server error: ${response.statusCode}'
            : 'Failed after $_maxRetries retries';
        print(errorMsg);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
      }
    } catch (e) {
      print('Error fetching detection: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Detection failed: $e')),
      );
    } finally {
      setState(() {
        _isProcessing = false; // Always reset
      });
    }
  }

  void startPolling() {
    _pollingTimer = Timer.periodic(const Duration(milliseconds: 2000), (timer) {
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
                            reverse: true,
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
