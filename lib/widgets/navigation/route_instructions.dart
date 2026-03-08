import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/map_navigation_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

class RouteInstructions extends StatelessWidget {
  const RouteInstructions({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MapNavigationProvider>(
      builder: (context, provider, child) {
        if (provider.activeRoute == null) return const SizedBox.shrink();

        final route = provider.activeRoute!;

        return Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Material(
            elevation: AppConstants.elevationLg,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppConstants.radiusLg),
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.creamWhite,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppConstants.radiusLg),
                ),
              ),
              padding: const EdgeInsets.all(AppConstants.spacingLg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppConstants.spacingMd),
                        decoration: BoxDecoration(
                          color: AppColors.accentGold,
                          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                        ),
                        child: const Icon(
                          Icons.navigation,
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
                              'Route to ${route.end.name}',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkBrown,
                                  ),
                            ),
                            const SizedBox(height: AppConstants.spacingXs),
                            Text(
                              '${route.stepCount} stops along the way',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        color: AppColors.textSecondary,
                        onPressed: () {
                          provider.clearRoute();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spacingMd),
                    decoration: BoxDecoration(
                      color: AppColors.offWhite,
                      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppColors.primaryBrown,
                          size: 20,
                        ),
                        const SizedBox(width: AppConstants.spacingSm),
                        Expanded(
                          child: Text(
                            'Follow the golden path on the map',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  Wrap(
                    spacing: AppConstants.spacingSm,
                    runSpacing: AppConstants.spacingSm,
                    children: route.waypoints.asMap().entries.map((entry) {
                      final index = entry.key;
                      final waypoint = entry.value;
                      final isStart = index == 0;
                      final isEnd = index == route.waypoints.length - 1;

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spacingMd,
                          vertical: AppConstants.spacingSm,
                        ),
                        decoration: BoxDecoration(
                          color: isStart || isEnd
                              ? AppColors.accentGold.withAlpha(51)
                              : AppColors.offWhite,
                          borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                          border: Border.all(
                            color: isStart || isEnd
                                ? AppColors.accentGold
                                : AppColors.divider,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isStart
                                  ? Icons.location_on
                                  : isEnd
                                      ? Icons.flag
                                      : Icons.circle,
                              size: 16,
                              color: isStart || isEnd
                                  ? AppColors.accentGold
                                  : AppColors.textTertiary,
                            ),
                            const SizedBox(width: AppConstants.spacingXs),
                            Text(
                              waypoint.name,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: isStart || isEnd
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
