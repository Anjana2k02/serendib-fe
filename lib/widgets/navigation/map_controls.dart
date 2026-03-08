import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

class MapControls extends StatelessWidget {
  final VoidCallback? onZoomIn;
  final VoidCallback? onZoomOut;
  final VoidCallback? onReset;
  final VoidCallback? onCenterUser;

  const MapControls({
    super.key,
    this.onZoomIn,
    this.onZoomOut,
    this.onReset,
    this.onCenterUser,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: AppConstants.spacingMd,
      bottom: 100,
      child: Column(
        children: [
          _ControlButton(
            icon: Icons.add,
            onPressed: onZoomIn,
            tooltip: 'Zoom In',
          ),
          const SizedBox(height: AppConstants.spacingSm),
          _ControlButton(
            icon: Icons.remove,
            onPressed: onZoomOut,
            tooltip: 'Zoom Out',
          ),
          const SizedBox(height: AppConstants.spacingMd),
          _ControlButton(
            icon: Icons.refresh,
            onPressed: onReset,
            tooltip: 'Reset View',
          ),
          if (onCenterUser != null) ...[
            const SizedBox(height: AppConstants.spacingSm),
            _ControlButton(
              icon: Icons.my_location,
              onPressed: onCenterUser,
              tooltip: 'Center on Location',
            ),
          ],
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;

  const _ControlButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        elevation: AppConstants.elevationMd,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        color: AppColors.creamWhite,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            ),
            child: Icon(
              icon,
              color: AppColors.primaryBrown,
              size: AppConstants.iconSizeMd,
            ),
          ),
        ),
      ),
    );
  }
}
