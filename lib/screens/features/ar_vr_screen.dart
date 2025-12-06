import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

class ARVRScreen extends StatelessWidget {
  const ARVRScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AR/VR Experience'),
      ),
      body: SingleChildScrollView(
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
            const _FeatureItem(
              icon: Icons.threed_rotation,
              title: '3D Models',
              description: 'View artifacts in 3D',
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
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingMd),
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
        ],
      ),
    );
  }
}
