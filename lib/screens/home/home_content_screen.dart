import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';

class HomeContentScreen extends StatelessWidget {
  const HomeContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Serendib'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingSm,
                vertical: AppConstants.spacingMd,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: AppConstants.spacingXs),
                  Text(
                    user?.fullName ?? 'Guest',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: AppColors.primaryBrown,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.spacingMd),

            // Feature Cards Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppConstants.spacingMd,
              crossAxisSpacing: AppConstants.spacingMd,
              childAspectRatio: 1.0,
              children: const [
                _FeatureCard(
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> 86d24f3ea2b78182ae6e01fa93920f98ada864ef
                  icon: Icons.smart_toy,
                  title: 'AI Assistant',
                  color: AppColors.accentGold,
                  route: '/ai-assistant',
                ),
                _FeatureCard(
<<<<<<< HEAD
                  icon: Icons.navigation,
                  title: 'Navigation',
=======
                  icon: Icons.map,
                  title: 'Indoor Map',
>>>>>>> 505a37a58330321349a352d64f19bb9bf1216aff
=======
                  icon: Icons.map,
                  title: 'Indoor Map',
>>>>>>> 86d24f3ea2b78182ae6e01fa93920f98ada864ef
                  color: AppColors.primaryBrown,
                  route: '/indoor-map',
                ),
                _FeatureCard(
                  icon: Icons.translate,
                  title: 'Translator',
                  color: AppColors.mediumBrown,
                  route: '/translator',
                ),
                _FeatureCard(
                  icon: Icons.qr_code_scanner,
                  title: 'QR Scanner',
                  color: AppColors.lightBrown,
                  route: '/qr-scanner',
                ),
                _FeatureCard(
                  icon: Icons.view_in_ar,
                  title: 'AR/VR',
                  color: AppColors.darkBrown,
                  route: '/ar-vr',
                ),
                _FeatureCard(
                  icon: Icons.feedback_outlined,
                  title: 'Feedback',
                  color: AppColors.veryLightBrown,
                  route: '/feedback',
                ),
                _FeatureCard(
                  icon: Icons.contact_mail_outlined,
                  title: 'Contact Us',
                  color: AppColors.mediumBrown,
                  route: '/contact',
                ),
              ],
            ),

            const SizedBox(height: AppConstants.spacingXl),

            // Quick Info Section
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingLg),
              decoration: BoxDecoration(
                color: AppColors.creamWhite,
                borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppColors.primaryBrown,
                        size: AppConstants.iconSizeMd,
                      ),
                      const SizedBox(width: AppConstants.spacingSm),
                      Text(
                        'Quick Tips',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.primaryBrown,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  Text(
                    'Explore the features above to get the most out of your Serendib experience. Use the QR scanner to quickly access location information and AR features.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.spacingLg),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final String route;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(route);
        },
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color,
                color.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.spacingMd),
                decoration: BoxDecoration(
                  color: AppColors.offWhite.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: AppConstants.iconSizeXl,
                  color: AppColors.offWhite,
                ),
              ),
              const SizedBox(height: AppConstants.spacingMd),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.offWhite,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
