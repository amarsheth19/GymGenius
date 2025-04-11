import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:video_player/video_player.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});
  final user = FirebaseAuth.instance.currentUser;


  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  CameraController? _cameraController;
  late Future<void> _initializeCameraFuture;
  bool _isRecording = false;
  bool _isCameraReady = false;
  Timer? _timer;
  int _secondsElapsed = 0;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      firstCamera,
      ResolutionPreset.medium,
    );

    _initializeCameraFuture = _cameraController!.initialize().then((_) {
      if (!mounted) return;
      setState(() => _isCameraReady = true);
    });
  }

  Future<void> _toggleRecording() async {
    if (!_isCameraReady) return;

    if (!_isRecording) {
      await _cameraController!.startVideoRecording();
      _startTimer();
    } else {
      final file = await _cameraController!.stopVideoRecording();
      _stopTimer();
      _previewVideo(file);
    }

    setState(() => _isRecording = !_isRecording);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _secondsElapsed++);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _previewVideo(XFile file) {
    _videoController = VideoPlayerController.file(File(file.path))
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        _videoController!.play();
      });
  }

  String _formatTime(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _videoController?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Widget _cameraPreview() {
    if (!_isCameraReady) {
      return const Center(child: CircularProgressIndicator());
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
        height: MediaQuery.of(context).size.width * 0.8 * (9 / 16), // Maintain 16:9 aspect
        child: CameraPreview(_cameraController!),
      ),
    );
  }

  Widget _videoPreview() {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return Container();
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.width * 0.8 * (9 / 16),
        child: AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: VideoPlayer(_videoController!),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Record Workout')),
      body: Column(
        children: [
          // Timer Display
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _formatTime(_secondsElapsed),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ),
          
          // Centered Camera/Video Preview with constrained size
          Expanded(
            child: Center(
              child: _videoController != null && _videoController!.value.isInitialized
                  ? _videoPreview()
                  : _cameraPreview(),
            ),
          ),
          
          // Control Button
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: FloatingActionButton(
              backgroundColor: _isRecording ? Colors.red : Colors.green,
              onPressed: _toggleRecording,
              child: Icon(_isRecording ? Icons.stop : Icons.videocam),
            ),
          ),
        ],
      ),
    );
  }
}