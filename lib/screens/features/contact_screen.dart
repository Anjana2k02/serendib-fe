import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Us'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Text(
              'Get in Touch',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppConstants.spacingSm),
            Text(
              'We\'re here to help! Reach out to us through any of the following channels.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            const SizedBox(height: AppConstants.spacingXl),

            // Contact Options
            _ContactCard(
              icon: Icons.email_outlined,
              title: 'Email',
              subtitle: 'support@serendib.lk',
              color: AppColors.primaryBrown,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening email client...')),
                );
              },
            ),

            _ContactCard(
              icon: Icons.phone_outlined,
              title: 'Phone',
              subtitle: '+94 11 234 5678',
              color: AppColors.mediumBrown,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening phone dialer...')),
                );
              },
            ),

            _ContactCard(
              icon: Icons.location_on_outlined,
              title: 'Visit Us',
              subtitle: '123 Main Street, Colombo, Sri Lanka',
              color: AppColors.lightBrown,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening maps...')),
                );
              },
            ),

            _ContactCard(
              icon: Icons.language,
              title: 'Website',
              subtitle: 'www.serendib.lk',
              color: AppColors.accentGold,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening website...')),
                );
              },
            ),

            const SizedBox(height: AppConstants.spacingXl),

            // Social Media
            Text(
              'Follow Us',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppConstants.spacingMd),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _SocialButton(
                  icon: Icons.facebook,
                  label: 'Facebook',
                  onTap: () {},
                ),
                _SocialButton(
                  icon: Icons.camera_alt,
                  label: 'Instagram',
                  onTap: () {},
                ),
                _SocialButton(
                  icon: Icons.chat,
                  label: 'Twitter',
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: AppConstants.spacingXl),

            // Office Hours
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
                        Icons.access_time,
                        color: AppColors.primaryBrown,
                      ),
                      const SizedBox(width: AppConstants.spacingSm),
                      Text(
                        'Office Hours',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  const _OfficeHourRow('Monday - Friday', '9:00 AM - 6:00 PM'),
                  const _OfficeHourRow('Saturday', '10:00 AM - 4:00 PM'),
                  const _OfficeHourRow('Sunday', 'Closed'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ContactCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingLg),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.spacingMd),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                ),
                child: Icon(icon, color: color, size: 28),
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
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.radiusRound),
          child: Container(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            decoration: const BoxDecoration(
              color: AppColors.primaryBrown,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.offWhite, size: 28),
          ),
        ),
        const SizedBox(height: AppConstants.spacingSm),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _OfficeHourRow extends StatelessWidget {
  final String day;
  final String hours;

  const _OfficeHourRow(this.day, this.hours);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            day,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          Text(
            hours,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
