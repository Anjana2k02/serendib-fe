import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/point_of_interest.dart';
import '../../providers/map_navigation_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

class POIInfoSheet extends StatelessWidget {
  final PointOfInterest poi;

  const POIInfoSheet({super.key, required this.poi});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusLg),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            margin: const EdgeInsets.only(top: AppConstants.spacingSm),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
            alignment: Alignment.center,
          ),
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppConstants.spacingMd),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBrown,
                        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                      ),
                      child: Icon(
                        _getIconForCategory(poi.category),
                        color: Colors.white,
                        size: AppConstants.iconSizeLg,
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            poi.name,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkBrown,
                                ),
                          ),
                          const SizedBox(height: AppConstants.spacingXs),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.spacingSm,
                              vertical: AppConstants.spacingXs,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accentGold.withAlpha(51),
                              borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                            ),
                            child: Text(
                              _getCategoryLabel(poi.category),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.darkBrown,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (poi.description != null) ...[
                  const SizedBox(height: AppConstants.spacingLg),
                  Text(
                    poi.description!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
                const SizedBox(height: AppConstants.spacingLg),
                Consumer<MapNavigationProvider>(
                  builder: (context, provider, child) {
                    if (provider.userPosition == null) {
                      return ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close),
                        label: const Text('Close'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      );
                    }

                    return Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.close),
                            label: const Text('Close'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 50),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppConstants.spacingMd),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              final startPOI = _findNearestPOI(
                                provider.userPosition!.position,
                                provider.pois,
                              );
                              if (startPOI != null) {
                                provider.calculateRoute(startPOI.id, poi.id);
                                Navigator.pop(context);
                              }
                            },
                            icon: const Icon(Icons.directions),
                            label: const Text('Navigate'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(0, 50),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'entrance':
        return Icons.door_front_door;
      case 'artifact':
        return Icons.museum;
      case 'exhibition':
        return Icons.collections;
      case 'amenity':
        return Icons.local_convenience_store;
      default:
        return Icons.location_on;
    }
  }

  String _getCategoryLabel(String category) {
    return category[0].toUpperCase() + category.substring(1);
  }

  PointOfInterest? _findNearestPOI(Offset position, List<PointOfInterest> pois) {
    if (pois.isEmpty) return null;

    PointOfInterest? nearest;
    double minDistance = double.infinity;

    for (final poi in pois) {
      final dx = poi.position.dx - position.dx;
      final dy = poi.position.dy - position.dy;
      final distance = dx * dx + dy * dy;

      if (distance < minDistance) {
        minDistance = distance;
        nearest = poi;
      }
    }

    return nearest;
  }
}

void showPOIInfo(BuildContext context, PointOfInterest poi) {
  final provider = Provider.of<MapNavigationProvider>(context, listen: false);

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => Provider.value(
      value: provider,
      child: POIInfoSheet(poi: poi),
    ),
  );
}
