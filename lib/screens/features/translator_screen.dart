import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

class TranslatorScreen extends StatefulWidget {
  const TranslatorScreen({super.key});

  @override
  State<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen> {
  final _textController = TextEditingController();
  String _selectedFromLanguage = 'English';
  String _selectedToLanguage = 'Sinhala';

  final List<String> _languages = ['English', 'Sinhala', 'Tamil', 'Spanish', 'French'];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Translator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Language Selection
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              decoration: BoxDecoration(
                color: AppColors.creamWhite,
                borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _LanguageDropdown(
                      value: _selectedFromLanguage,
                      items: _languages,
                      onChanged: (value) {
                        setState(() {
                          _selectedFromLanguage = value!;
                        });
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.swap_horiz),
                    color: AppColors.primaryBrown,
                    onPressed: () {
                      setState(() {
                        final temp = _selectedFromLanguage;
                        _selectedFromLanguage = _selectedToLanguage;
                        _selectedToLanguage = temp;
                      });
                    },
                  ),
                  Expanded(
                    child: _LanguageDropdown(
                      value: _selectedToLanguage,
                      items: _languages,
                      onChanged: (value) {
                        setState(() {
                          _selectedToLanguage = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.spacingLg),

            // Input Text
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedFromLanguage,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  TextField(
                    controller: _textController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'Enter text to translate...',
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.spacingMd),

            // Translate Button
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Translation API integration coming soon'),
                  ),
                );
              },
              icon: const Icon(Icons.translate),
              label: const Text('Translate'),
            ),

            const SizedBox(height: AppConstants.spacingLg),

            // Output Text
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              decoration: BoxDecoration(
                color: AppColors.creamWhite,
                borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedToLanguage,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  const SizedBox(
                    height: 120,
                    child: Center(
                      child: Text(
                        'Translation will appear here',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _LanguageDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: value,
      isExpanded: true,
      underline: const SizedBox(),
      icon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryBrown),
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
