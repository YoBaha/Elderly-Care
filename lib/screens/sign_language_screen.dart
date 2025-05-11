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
  bool _isPollingPaused = false;
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
        _isPollingPaused ||
        _cameraController == null ||
        !_cameraController!.value.isInitialized) {
      print(
          'Skipping detection: Processing=$_isProcessing, Paused=$_isPollingPaused, CameraInitialized=${_cameraController?.value.isInitialized}');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final image = await _cameraController!.takePicture();
      final bytes = await image.readAsBytes();
      print('Captured image size: ${bytes.length} bytes');

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

  void togglePolling() {
    setState(() {
      _isPollingPaused = !_isPollingPaused;
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF199A8E);
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 800;
          return Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                color: primaryColor,
                child: Text(
                  'Sign Language Detection',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              // Main Content
              Expanded(
                child: _cameraController == null ||
                        !_cameraController!.value.isInitialized
                    ? Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      )
                    : isWideScreen
                        ? Row(
                            children: [
                              // Camera Feed (Left)
                              Expanded(
                                flex: 3,
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Card(
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(color: primaryColor),
                                    ),
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child:
                                              CameraPreview(_cameraController!),
                                        ),
                                        if (_isProcessing)
                                          Center(
                                            child: CircularProgressIndicator(
                                              color: primaryColor,
                                              strokeWidth: 6,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Detected Signs (Right)
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Card(
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Text(
                                            'Detected Signs',
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: primaryColor,
                                            ),
                                          ),
                                        ),
                                        // Control Bar
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0),
                                          child: ElevatedButton.icon(
                                            onPressed: togglePolling,
                                            icon: Icon(
                                              _isPollingPaused
                                                  ? Icons.play_arrow
                                                  : Icons.pause,
                                              color: Colors.white,
                                            ),
                                            label: Text(
                                              _isPollingPaused
                                                  ? 'Resume Detection'
                                                  : 'Pause Detection',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: primaryColor,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                      horizontal: 16),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Expanded(
                                          child: ListView.builder(
                                            padding: const EdgeInsets.all(16.0),
                                            itemCount: detectedSigns.length,
                                            itemBuilder: (context, index) {
                                              final signData =
                                                  detectedSigns[index];
                                              final sign = signData['sign'];
                                              final confidence =
                                                  signData['confidence'];
                                              final timestamp =
                                                  signData['timestamp']
                                                      as DateTime;
                                              return AnimatedOpacity(
                                                opacity: 1.0,
                                                duration:
                                                    Duration(milliseconds: 300),
                                                child: Container(
                                                  margin: const EdgeInsets
                                                      .symmetric(vertical: 8.0),
                                                  padding: const EdgeInsets.all(
                                                      12.0),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    border: Border.all(
                                                        color: primaryColor
                                                            .withOpacity(0.2)),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        sign,
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: primaryColor,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        'Confidence: ${(confidence * 100).toStringAsFixed(2)}%',
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors
                                                                .grey[600]),
                                                      ),
                                                      Text(
                                                        '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}',
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors
                                                                .grey[600]),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              // Camera Feed (Top)
                              Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(color: primaryColor),
                                  ),
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child:
                                            CameraPreview(_cameraController!),
                                      ),
                                      if (_isProcessing)
                                        Center(
                                          child: CircularProgressIndicator(
                                            color: primaryColor,
                                            strokeWidth: 6,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              // Detected Signs (Bottom)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Card(
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Text(
                                            'Detected Signs',
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: primaryColor,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0),
                                          child: ElevatedButton.icon(
                                            onPressed: togglePolling,
                                            icon: Icon(
                                              _isPollingPaused
                                                  ? Icons.play_arrow
                                                  : Icons.pause,
                                              color: Colors.white,
                                            ),
                                            label: Text(
                                              _isPollingPaused
                                                  ? 'Resume Detection'
                                                  : 'Pause Detection',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: primaryColor,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                      horizontal: 16),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Expanded(
                                          child: ListView.builder(
                                            padding: const EdgeInsets.all(16.0),
                                            itemCount: detectedSigns.length,
                                            itemBuilder: (context, index) {
                                              final signData =
                                                  detectedSigns[index];
                                              final sign = signData['sign'];
                                              final confidence =
                                                  signData['confidence'];
                                              final timestamp =
                                                  signData['timestamp']
                                                      as DateTime;
                                              return AnimatedOpacity(
                                                opacity: 1.0,
                                                duration:
                                                    Duration(milliseconds: 300),
                                                child: Container(
                                                  margin: const EdgeInsets
                                                      .symmetric(vertical: 8.0),
                                                  padding: const EdgeInsets.all(
                                                      12.0),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    border: Border.all(
                                                        color: primaryColor
                                                            .withOpacity(0.2)),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        sign,
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: primaryColor,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        'Confidence: ${(confidence * 100).toStringAsFixed(2)}%',
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors
                                                                .grey[600]),
                                                      ),
                                                      Text(
                                                        '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}',
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors
                                                                .grey[600]),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
              ),
            ],
          );
        },
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
