import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../models/point_of_interest.dart';
import '../../providers/map_navigation_provider.dart';
import '../../core/theme/app_colors.dart';
import 'poi_info_sheet.dart';

class POIMarker extends StatelessWidget {
  final PointOfInterest poi;

  const POIMarker({super.key, required this.poi});

  @override
  Widget build(BuildContext context) {
    return Consumer<MapNavigationProvider>(
      builder: (context, provider, child) {
        final isSelected = provider.selectedPOI?.id == poi.id;
        final isOnRoute = provider.activeRoute?.waypoints.any((p) => p.id == poi.id) ?? false;

        return Positioned(
          left: poi.position.dx - 20,
          top: poi.position.dy - 20,
          child: GestureDetector(
            onTap: () {
              provider.selectPOI(poi.id);
              _showPOIInfo(context, poi);
            },
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 300),
              tween: Tween(begin: 1.0, end: isSelected ? 1.3 : 1.0),
              curve: Curves.easeInOut,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: child,
                );
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getMarkerColor(isSelected, isOnRoute),
                  border: Border.all(
                    color: isOnRoute
                        ? AppColors.accentGold
                        : isSelected
                            ? AppColors.accentGold
                            : AppColors.darkBrown,
                    width: isSelected ? 3 : 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: poi.iconPath != null
                    ? Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SvgPicture.asset(
                          poi.iconPath!,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                          placeholderBuilder: (context) => Icon(
                            _getIconForCategory(poi.category),
                            size: 24,
                            color: Colors.white,
                          ),
                          fit: BoxFit.contain,
                        ),
                      )
                    : Icon(
                        _getIconForCategory(poi.category),
                        size: 24,
                        color: Colors.white,
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getMarkerColor(bool isSelected, bool isOnRoute) {
    if (isSelected) return AppColors.accentGold;
    if (isOnRoute) return AppColors.softGold;
    return AppColors.primaryBrown;
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

  void _showPOIInfo(BuildContext context, PointOfInterest poi) {
    showPOIInfo(context, poi);
  }
}
