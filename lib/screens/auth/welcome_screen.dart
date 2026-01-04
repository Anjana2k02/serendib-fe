import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryBrown,
              AppColors.primaryBrown.withOpacity(0.8),
              AppColors.darkBrown,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingXl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),

                // App Icon/Logo
                Container(
                  padding: const EdgeInsets.all(AppConstants.spacingXl),
                  decoration: BoxDecoration(
                    color: AppColors.offWhite.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.explore,
                    size: 120,
                    color: AppColors.offWhite,
                  ),
                ),

                const SizedBox(height: AppConstants.spacingXl),

                // App Name
                Text(
                  'Serendib',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: AppColors.offWhite,
                        fontWeight: FontWeight.bold,
                        fontSize: 48,
                        letterSpacing: 2,
                      ),
                ),

                const SizedBox(height: AppConstants.spacingMd),

                // Tagline
                Text(
                  'Discover the Beauty of Sri Lanka',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.offWhite.withOpacity(0.9),
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.5,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppConstants.spacingSm),

                Text(
                  'Your personal museum guide',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.offWhite.withOpacity(0.7),
                      ),
                  textAlign: TextAlign.center,
                ),

                const Spacer(),

                // Sign Up Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/onboarding');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.offWhite,
                      foregroundColor: AppColors.primaryBrown,
                      elevation: 8,
                      shadowColor: Colors.black45,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.person_add, size: 24),
                        const SizedBox(width: AppConstants.spacingSm),
                        Text(
                          'Sign Up',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppColors.primaryBrown,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppConstants.spacingLg),

                // Sign In Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.offWhite,
                      side: const BorderSide(
                        color: AppColors.offWhite,
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.login, size: 24),
                        const SizedBox(width: AppConstants.spacingSm),
                        Text(
                          'Sign In',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppColors.offWhite,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppConstants.spacingXl),

                // Footer text
                Text(
                  'Experience interactive museum tours\nwith AR/VR and real-time navigation',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.offWhite.withOpacity(0.6),
                        height: 1.5,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppConstants.spacingLg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
