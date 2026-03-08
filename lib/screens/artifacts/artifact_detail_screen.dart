import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/artifact.dart';
import '../../providers/artifact_provider.dart';
import '../../providers/auth_provider.dart';

class ArtifactDetailScreen extends StatelessWidget {
  final Artifact? artifact;

  const ArtifactDetailScreen({super.key, this.artifact});

  @override
  Widget build(BuildContext context) {
    if (artifact == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Artifact Detail')),
        body: const Center(child: Text('No artifact data provided')),
      );
    }

    final user = context.watch<AuthProvider>().user;
    final isAdmin = user?.role == 'ADMIN';
    final isCurator = user?.role == 'CURATOR';
    final canEdit = isAdmin || isCurator;

    return Scaffold(
      appBar: AppBar(
        title: Text(artifact!.name),
        actions: [
          if (canEdit)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.of(context).pushNamed(
                  '/artifacts/create',
                  arguments: artifact,
                );
              },
            ),
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(context),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name & Category header
            Text(
              artifact!.name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.primaryBrown,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppConstants.spacingSm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingMd,
                vertical: AppConstants.spacingXs,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryBrown.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusSm),
              ),
              child: Text(
                artifact!.category,
                style: const TextStyle(
                  color: AppColors.primaryBrown,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: AppConstants.spacingLg),

            // Display status
            if (artifact!.isOnDisplay)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingMd,
                  vertical: AppConstants.spacingSm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                  border: Border.all(color: AppColors.success.withOpacity(0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.visibility, color: AppColors.success, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Currently On Display',
                      style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: AppConstants.spacingLg),

            // Description
            if (artifact!.description != null && artifact!.description!.isNotEmpty) ...[
              _SectionTitle(title: 'Description'),
              const SizedBox(height: AppConstants.spacingSm),
              Text(
                artifact!.description!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: AppConstants.spacingLg),
            ],

            // Details grid
            _SectionTitle(title: 'Details'),
            const SizedBox(height: AppConstants.spacingMd),
            _DetailRow(
              label: 'Origin Country',
              value: artifact!.originCountry ?? 'Unknown',
            ),
            _DetailRow(
              label: 'Date Acquired',
              value: artifact!.dateAcquired != null
                  ? '${artifact!.dateAcquired!.year}-${artifact!.dateAcquired!.month.toString().padLeft(2, '0')}-${artifact!.dateAcquired!.day.toString().padLeft(2, '0')}'
                  : 'Unknown',
            ),
            _DetailRow(
              label: 'Estimated Value',
              value: artifact!.estimatedValue != null
                  ? '\$${artifact!.estimatedValue!.toStringAsFixed(2)}'
                  : 'Not appraised',
            ),
            _DetailRow(
              label: 'Location in Museum',
              value: artifact!.locationInMuseum ?? 'Not assigned',
            ),

            const SizedBox(height: AppConstants.spacingLg),

            // Audit info
            ExpansionTile(
              title: const Text(
                'Audit Information',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppConstants.spacingMd),
                  child: Column(
                    children: [
                      _DetailRow(
                        label: 'Created',
                        value: artifact!.createdAt?.toString() ?? 'Unknown',
                      ),
                      _DetailRow(
                        label: 'Last Updated',
                        value: artifact!.updatedAt?.toString() ?? 'Unknown',
                      ),
                      _DetailRow(
                        label: 'Created By',
                        value: artifact!.createdBy ?? 'Unknown',
                      ),
                      _DetailRow(
                        label: 'Updated By',
                        value: artifact!.updatedBy ?? 'Unknown',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Artifact'),
        content: Text('Are you sure you want to delete "${artifact!.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final provider = context.read<ArtifactProvider>();
              final success = await provider.deleteArtifact(artifact!.id!);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Artifact deleted successfully')),
                );
                Navigator.of(context).pop();
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(provider.error ?? 'Failed to delete artifact'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.primaryBrown,
            fontWeight: FontWeight.bold,
          ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingSm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
