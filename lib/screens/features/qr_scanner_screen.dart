import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

class QRScannerScreen extends StatelessWidget {
  const QRScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingLg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // QR Scanner Frame
              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.primaryBrown,
                    width: 4,
                  ),
                  borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                ),
                child: Center(
                  child: Icon(
                    Icons.qr_code_scanner,
                    size: 100,
                    color: AppColors.primaryBrown.withOpacity(0.3),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacingXl),
              Text(
                'QR Code Scanner',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spacingMd),
              Text(
                'Scan QR codes to get instant information about locations, artifacts, and more.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spacingXl),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Camera permission required. QR scanning coming soon.'),
                    ),
                  );
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('Start Scanning'),
              ),
              const SizedBox(height: AppConstants.spacingMd),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Image picker coming soon'),
                    ),
                  );
                },
                icon: const Icon(Icons.photo_library),
                label: const Text('Scan from Gallery'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
