import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import 'ar_viewer_screen.dart';

class ObjectViewerScreen extends StatefulWidget {
  final String glbFilePath;

  const ObjectViewerScreen({
    super.key,
    required this.glbFilePath,
  });

  @override
  State<ObjectViewerScreen> createState() => _ObjectViewerScreenScreenState();
}

class _ObjectViewerScreenScreenState extends State<ObjectViewerScreen> {
  Flutter3DController controller = Flutter3DController();
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeViewer();
  }

  Future<void> _initializeViewer() async {
    try {
      print('Initializing 3D viewer with file: ${widget.glbFilePath}');

      // Verify the file exists
      final file = File(widget.glbFilePath);
      if (!await file.exists()) {
        throw Exception('GLB file not found at: ${widget.glbFilePath}');
      }

      print('File exists, size: ${await file.length()} bytes');

      // Small delay to ensure the widget is built
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error initializing viewer: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('3D Model Viewer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.view_in_ar),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ARViewerScreen(
                    glbFilePath: widget.glbFilePath,
                  ),
                ),
              );
            },
            tooltip: 'View in AR',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              controller.resetCameraOrbit();
            },
            tooltip: 'Reset Camera',
          ),
        ],
      ),
      body: Column(
        children: [
          // 3D Model Viewer
          Expanded(
            child: Container(
              color: AppColors.creamWhite,
              child: _isLoading
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: AppColors.accentGold,
                          ),
                          SizedBox(height: 16),
                          Text('Loading 3D model...'),
                        ],
                      ),
                    )
                  : _errorMessage != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: Colors.red,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Error loading 3D model',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Go Back'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Flutter3DViewer(
                          controller: controller,
                          src: 'file://${widget.glbFilePath}',
                        ),
            ),
          ),

          // Controls
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingLg),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '3D Model Controls',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppConstants.spacingMd),
                Wrap(
                  spacing: AppConstants.spacingMd,
                  runSpacing: AppConstants.spacingSm,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ARViewerScreen(
                              glbFilePath: widget.glbFilePath,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.view_in_ar, size: 18),
                      label: const Text('AR View'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentGold,
                        foregroundColor: Colors.black,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        controller.playAnimation();
                      },
                      icon: const Icon(Icons.play_arrow, size: 18),
                      label: const Text('Play'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBrown,
                        foregroundColor: AppColors.offWhite,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        controller.pauseAnimation();
                      },
                      icon: const Icon(Icons.pause, size: 18),
                      label: const Text('Pause'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBrown,
                        foregroundColor: AppColors.offWhite,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        controller.resetCameraOrbit();
                      },
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Reset'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentGold,
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingSm),
                Text(
                  'Drag to rotate • Pinch to zoom • Two fingers to pan',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
