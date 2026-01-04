import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/map_navigation_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import 'poi_info_sheet.dart';

class POISearchBar extends StatefulWidget {
  const POISearchBar({super.key});

  @override
  State<POISearchBar> createState() => _POISearchBarState();
}

class _POISearchBarState extends State<POISearchBar> {
  final TextEditingController _controller = TextEditingController();
  bool _showResults = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: AppConstants.spacingMd,
      left: AppConstants.spacingMd,
      right: AppConstants.spacingMd,
      child: Consumer<MapNavigationProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              Material(
                elevation: AppConstants.elevationMd,
                borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.creamWhite,
                    borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                  ),
                  child: TextField(
                    controller: _controller,
                    onChanged: (value) {
                      provider.searchPOIs(value);
                      setState(() {
                        _showResults = value.isNotEmpty;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search locations...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.primaryBrown),
                      suffixIcon: _controller.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                              onPressed: () {
                                _controller.clear();
                                provider.clearSearch();
                                setState(() {
                                  _showResults = false;
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingMd,
                        vertical: AppConstants.spacingMd,
                      ),
                    ),
                  ),
                ),
              ),
              if (_showResults && provider.filteredPOIs.isNotEmpty)
                const SizedBox(height: AppConstants.spacingSm),
              if (_showResults && provider.filteredPOIs.isNotEmpty)
                Material(
                  elevation: AppConstants.elevationMd,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 300),
                    decoration: BoxDecoration(
                      color: AppColors.creamWhite,
                      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppConstants.spacingSm,
                      ),
                      itemCount: provider.filteredPOIs.length,
                      separatorBuilder: (context, index) => const Divider(
                        height: 1,
                        indent: AppConstants.spacingMd,
                        endIndent: AppConstants.spacingMd,
                      ),
                      itemBuilder: (context, index) {
                        final poi = provider.filteredPOIs[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primaryBrown,
                            child: Icon(
                              _getIconForCategory(poi.category),
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            poi.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkBrown,
                            ),
                          ),
                          subtitle: Text(
                            poi.category,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          onTap: () {
                            provider.selectPOI(poi.id);
                            setState(() {
                              _showResults = false;
                            });
                            _controller.clear();
                            provider.clearSearch();
                            showPOIInfo(context, poi);
                          },
                        );
                      },
                    ),
                  ),
                ),
            ],
          );
        },
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
}
