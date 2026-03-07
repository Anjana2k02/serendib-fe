import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../services/artifact_service.dart';
import '../../services/artifact_identify_service.dart';
import '../../services/artifact_obj_service.dart';
import '../../models/artifact_info_response.dart';
import 'object_viewer_screen.dart';

class ARVRScreen extends StatefulWidget {
  const ARVRScreen({super.key});

  @override
  State<ARVRScreen> createState() => _ARVRScreenState();
}

class _ARVRScreenState extends State<ARVRScreen> {
  final PredictionService _predictionService = PredictionService();
  final Model3DService _model3DService = Model3DService();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isLoading = false;
  String _loadingMessage = '';
  PredictionResponse? _predictionResult;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
  }

  /// Converts prediction label to asset image path
  String _getAssetImagePath(String predLabel) {
    // Images in assets use spaces in filenames, e.g., "Statue of Ramesses II.jpg"
    return 'assets/artifacts/base_images/$predLabel.jpg';
  }

  Future<void> _pickImageAndGenerate3D(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: source);
      if (image == null) return;

      setState(() {
        _isLoading = true;
        _loadingMessage = 'Generating 3D model...\nThis may take 3-4 minutes';
      });

      print('Generating 3D model from image...');
      final glbPath = await _model3DService.generate3DModel(File(image.path));
      print('3D model generated: $glbPath');

      setState(() {
        _isLoading = false;
        _loadingMessage = '';
      });

      if (mounted) {
        // Navigate to 3D viewer screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ObjectViewerScreen(glbFilePath: glbPath),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('Error generating 3D model: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _isLoading = false;
        _loadingMessage = '';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating 3D model: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _show3DImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImageAndGenerate3D(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImageAndGenerate3D(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndPredictImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: source);
      if (image == null) return;

      setState(() {
        _isLoading = true;
        _selectedImage = File(image.path);
        _predictionResult = null;
      });

      print('Calling prediction service...');
      final result = await _predictionService.predictArtifact(File(image.path));
      print('Got result: ${result.predLabel}');

      setState(() {
        _predictionResult = result;
        _isLoading = false;
      });

      print('About to show dialog...');
      if (mounted) {
        _showPredictionDialog(result);
      }
    } catch (e, stackTrace) {
      print('Error in _pickAndPredictImage: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showPredictionDialog(PredictionResponse result) async {
    try {
      final assetPath = _getAssetImagePath(result.predLabel);
      final artifact = result.artifact;

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (dialogContext) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Artifact Identified',
                      style: Theme.of(dialogContext).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Builder( builder: (context) { try {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        assetPath,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          final fallbackPath = assetPath.replaceAll('.jpg', '.JPG');
                          return Image.asset(
                              fallbackPath,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                print('Error loading fallback image: $error');
                                return Container(
                                  height: 220,
                                  width: double.infinity,
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Icon(
                                        Icons.image_not_supported, size: 48),
                                  ),
                                );
                              }
                          );
                        },
                      ),
                    );
                  } catch (e, stackTrace) {
                    return Center(
                      child: Container(
                        height: 250,
                        width: 300,
                        color: Colors.grey[300],
                        child: Center( child: Text('Error: $e'), ), ), );
                  }
                  }
                  ),
                  const SizedBox(height: 20),

                  Center(
                    child: Text(
                      artifact?.artifactName ?? result.predLabel,
                      style: Theme.of(dialogContext).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBrown,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  _buildInfoRow('Category', artifact?.category ?? 'Not available'),
                  _buildInfoRow('Era', artifact?.era ?? 'Not available'),
                  _buildInfoRow('Material', artifact?.material ?? 'Not available'),

                  const SizedBox(height: 16),

                  Text(
                    'Artifact Details',
                    style: Theme.of(dialogContext).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    artifact?.artifactDetails ??
                        'Detailed information is not available for this artifact.',
                    style: Theme.of(dialogContext).textTheme.bodyMedium,
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } catch (e, stackTrace) {
      print('Error showing dialog: $e');
      print('Stack trace: $stackTrace');
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.of(context).pop();
                _pickAndPredictImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.of(context).pop();
                _pickAndPredictImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AR/VR Experience'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hero Image
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.accentGold,
                        AppColors.primaryBrown,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.view_in_ar,
                      size: 80,
                      color: AppColors.offWhite,
                    ),
                  ),
                ),

                const SizedBox(height: AppConstants.spacingXl),

                Text(
                  'Augmented Reality',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingMd),
                Text(
                  'Experience historical sites and artifacts in augmented reality. Point your camera at landmarks to see additional information and historical reconstructions.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),

                const SizedBox(height: AppConstants.spacingLg),

                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('AR feature coming soon'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Launch AR Experience'),
                ),

                const SizedBox(height: AppConstants.spacingXl),
                const Divider(),
                const SizedBox(height: AppConstants.spacingXl),

                Text(
                  'Virtual Reality',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingMd),
                Text(
                  'Immerse yourself in 360° virtual tours of Sri Lankan heritage sites and museums from the comfort of your home.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),

                const SizedBox(height: AppConstants.spacingLg),

                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('VR tours coming soon'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.vrpano),
                  label: const Text('Browse VR Tours'),
                ),

                const SizedBox(height: AppConstants.spacingXl),

                // Features List
                _FeatureItem(
                  icon: Icons.image_search,
                  title: 'Original View',
                  description: 'View artifacts real image',
                  onTap: _showImageSourceDialog,
                ),
                _FeatureItem(
                  icon: Icons.threed_rotation,
                  title: '3D Models',
                  description: 'View artifacts in 3D',
                  onTap: _show3DImageSourceDialog,
                ),
                const _FeatureItem(
                  icon: Icons.panorama,
                  title: '360° Views',
                  description: 'Explore locations fully',
                ),
                const _FeatureItem(
                  icon: Icons.history_edu,
                  title: 'Historical Info',
                  description: 'Learn as you explore',
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      color: AppColors.accentGold,
                    ),
                    if (_loadingMessage.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        _loadingMessage,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback? onTap;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              decoration: BoxDecoration(
                color: AppColors.creamWhite,
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              ),
              child: Icon(icon, color: AppColors.primaryBrown),
            ),
            const SizedBox(width: AppConstants.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.primaryBrown,
              ),
          ],
        ),
      ),
    );
  }
}

Widget _buildInfoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    ),
  );
}