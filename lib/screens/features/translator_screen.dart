import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../services/translation_service.dart';

class TranslatorScreen extends StatefulWidget {
  const TranslatorScreen({super.key});

  @override
  State<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen> {
  final _textController = TextEditingController();
  final _translationService = TranslationService();
  String _selectedFromLanguage = 'English';
  String _selectedToLanguage = 'Sinhala';
  String _translatedText = '';
  bool _isLoading = false;

  final List<String> _languages = ['English', 'Sinhala', 'Tamil', 'Spanish', 'French'];

  static const Map<String, String> _langCodes = {
    'English': 'en',
    'Sinhala': 'si',
    'Tamil': 'ta',
    'Spanish': 'es',
    'French': 'fr',
  };

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _translate() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter text to translate')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _translationService.translate(
        text,
        _langCodes[_selectedFromLanguage]!,
        _langCodes[_selectedToLanguage]!,
      );
      setState(() {
        _translatedText = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Translation failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
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
              onPressed: _isLoading ? null : _translate,
              icon: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.translate),
              label: Text(_isLoading ? 'Translating...' : 'Translate'),
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
                  SizedBox(
                    height: 120,
                    child: _translatedText.isEmpty
                        ? const Center(
                            child: Text(
                              'Translation will appear here',
                              style: TextStyle(
                                color: AppColors.textTertiary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            child: SelectableText(
                              _translatedText,
                              style: Theme.of(context).textTheme.bodyLarge,
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
