import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';

class ARViewerScreen extends StatefulWidget {
  final String glbFilePath;

  const ARViewerScreen({
    super.key,
    required this.glbFilePath,
  });

  @override
  State<ARViewerScreen> createState() => _ARViewerScreenState();
}

class _ARViewerScreenState extends State<ARViewerScreen> {
  static const platform = MethodChannel('com.serendib/ar_viewer');
  bool _isLaunching = false;

  @override
  void initState() {
    super.initState();
    _launchARViewer();
  }

  Future<void> _launchARViewer() async {
    setState(() {
      _isLaunching = true;
    });

    try {
      print('Launching AR viewer with file: ${widget.glbFilePath}');

      // Check if file exists
      final file = File(widget.glbFilePath);
      if (!await file.exists()) {
        throw Exception('GLB file not found');
      }

      // For Android, use Scene Viewer intent
      if (Platform.isAndroid) {
        await _launchAndroidARViewer();
      }
      // For iOS, use Quick Look
      else if (Platform.isIOS) {
        await _launchIOSARViewer();
      } else {
        throw Exception('AR viewing is not supported on this platform');
      }
    } catch (e) {
      print('Error launching AR viewer: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
        // Go back if AR launch failed
        Navigator.pop(context);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLaunching = false;
        });
      }
    }
  }

  Future<void> _launchAndroidARViewer() async {
    try {
      final result = await platform.invokeMethod('launchSceneViewer', {
        'filePath': widget.glbFilePath,
      });

      if (result != true) {
        throw Exception(
            'Failed to launch Scene Viewer. Make sure Google AR Services is installed.');
      }

      // Scene Viewer was launched successfully, go back to previous screen
      if (mounted) {
        Navigator.pop(context);
      }
    } on PlatformException catch (e) {
      throw Exception('AR not available: ${e.message}');
    }
  }

  Future<void> _launchIOSARViewer() async {
    try {
      final result = await platform.invokeMethod('launchQuickLook', {
        'filePath': widget.glbFilePath,
      });

      if (result != true) {
        throw Exception('Failed to launch Quick Look AR');
      }

      // Quick Look was launched successfully, go back to previous screen
      if (mounted) {
        Navigator.pop(context);
      }
    } on PlatformException catch (e) {
      throw Exception('AR not available: ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AR Viewer'),
        backgroundColor: AppColors.primaryBrown,
        foregroundColor: AppColors.offWhite,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLaunching) ...[
              const CircularProgressIndicator(
                color: AppColors.accentGold,
              ),
              const SizedBox(height: 24),
              const Text(
                'Launching AR Viewer...',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  'This will open your camera to place the 3D model in your space',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ] else ...[
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.orange,
              ),
              const SizedBox(height: 24),
              const Text(
                'AR Viewer',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  'AR viewing requires Google AR Services (Android) or iOS 12+ (iPhone)',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
