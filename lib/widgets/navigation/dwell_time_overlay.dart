import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/dev_options_provider.dart';

/// Live dwell time overlay displayed at the bottom-right corner of the screen.
/// Only visible when developer options are enabled and the user is in "Standing" mode.
class DwellTimeOverlay extends StatelessWidget {
  const DwellTimeOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DevOptionsProvider>(
      builder: (context, devOptions, child) {
        // Only show when developer options are enabled
        if (!devOptions.developerOptionsEnabled) {
          return const SizedBox.shrink();
        }

        final isStanding =
            devOptions.selectedActivity.toLowerCase() == 'standing';
        final dwellMs = devOptions.dwellTimeMs;
        final nearbyArtifact = devOptions.nearbyArtifactName;
        final nearbyCategoryId = devOptions.nearbyCategoryId;

        return Positioned(
          bottom: AppConstants.spacingLg,
          right: AppConstants.spacingMd,
          child: AnimatedOpacity(
            opacity: 1.0,
            duration: AppConstants.animationNormal,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 220),
              decoration: BoxDecoration(
                color: isStanding
                    ? AppColors.darkBrown.withOpacity(0.95)
                    : Colors.grey.shade800.withOpacity(0.9),
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                border: Border.all(
                  color: isStanding
                      ? AppColors.accentGold.withOpacity(0.6)
                      : Colors.grey.shade600,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingSm + 2,
                      vertical: AppConstants.spacingXs + 2,
                    ),
                    decoration: BoxDecoration(
                      color: isStanding
                          ? AppColors.accentGold.withOpacity(0.15)
                          : Colors.grey.withOpacity(0.15),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(AppConstants.radiusMd - 1),
                        topRight: Radius.circular(AppConstants.radiusMd - 1),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.developer_mode,
                          color: AppColors.accentGold,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'DWELL TIME',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const Spacer(),
                        // Live indicator
                        if (isStanding && nearbyArtifact != null)
                          _PulsingDot(color: AppColors.success),
                      ],
                    ),
                  ),
                  // Body
                  Padding(
                    padding: const EdgeInsets.all(AppConstants.spacingSm + 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Timer display
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isStanding ? Icons.timer : Icons.timer_off,
                              color: isStanding
                                  ? AppColors.accentGold
                                  : Colors.grey.shade500,
                              size: 22,
                            ),
                            const SizedBox(width: AppConstants.spacingSm),
                            Text(
                              _formatDwellTime(dwellMs),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Milliseconds
                        Text(
                          '${dwellMs}ms',
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 10,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacingSm),
                        // Status row
                        _InfoRow(
                          label: 'Activity',
                          value: devOptions.selectedActivity,
                          valueColor: isStanding
                              ? AppColors.success
                              : AppColors.warning,
                        ),
                        const SizedBox(height: 3),
                        _InfoRow(
                          label: 'Artifact',
                          value: nearbyArtifact ?? '—',
                          valueColor: nearbyArtifact != null
                              ? Colors.white
                              : Colors.white38,
                        ),
                        const SizedBox(height: 3),
                        _InfoRow(
                          label: 'Cat. ID',
                          value: nearbyCategoryId != null
                              ? '#$nearbyCategoryId'
                              : '—',
                          valueColor: nearbyCategoryId != null
                              ? AppColors.softGold
                              : Colors.white38,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDwellTime(int ms) {
    final totalSeconds = ms ~/ 1000;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final millis = (ms % 1000) ~/ 10; // show hundredths
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}.'
        '${millis.toString().padLeft(2, '0')}';
  }
}

/// A simple info row with label: value.
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 11,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// A small pulsing green dot to indicate live tracking.
class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withOpacity(_animation.value),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(_animation.value * 0.5),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        );
      },
    );
  }
}
