import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../services/artifact_ml_service.dart';
import '../../services/api_service.dart';
import '../../services/translation_service.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final ArtifactMLService _mlService = ArtifactMLService();
  final ImagePicker _imagePicker = ImagePicker();
  MobileScannerController? _cameraController;
  bool _isScannerActive = false;
  bool _isLoading = false;

  // Role selector for testing different personalized views
  static const _availableRoles = ['tourist', 'student', 'teacher', 'professor', 'citizen'];
  String _selectedRole = 'tourist';

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  void _startScanner() {
    _cameraController = MobileScannerController();
    setState(() => _isScannerActive = true);
  }

  void _stopScanner() {
    _cameraController?.dispose();
    _cameraController = null;
    setState(() => _isScannerActive = false);
  }

  String _getUserRole() {
    return _selectedRole;
  }

  Future<void> _onQRDetected(BarcodeCapture capture) async {
    if (_isLoading) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    final rawValue = barcode.rawValue!;
    _stopScanner();

    // Try to parse as artifact ID (integer)
    final artifactId = int.tryParse(rawValue);
    if (artifactId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid QR code: "$rawValue". Expected an artifact ID.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final role = _getUserRole();
      final result = await _mlService.getArtifactByIdAndRole(artifactId, role);
      if (mounted) {
        _showArtifactResult(result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fetch artifact: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImageAndClassify() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (pickedFile == null) return;

    setState(() => _isLoading = true);

    try {
      final bytes = await pickedFile.readAsBytes();
      final result = await _mlService.predictArtifact(bytes, pickedFile.name);
      if (mounted) {
        _showPredictionResult(result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Classification failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showArtifactResult(Map<String, dynamic> data) {
    final personalized = data['personalized'] as Map<String, dynamic>? ?? {};
    final imageUrl = data['image_url'] as String?;
    final audioUrl = data['audio_url'] as String?;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusLg)),
      ),
      builder: (ctx) => _ArtifactDetailSheet(
        data: data,
        personalized: personalized,
        imageUrl: imageUrl,
        audioUrl: audioUrl,
        formatFieldName: _formatFieldName,
      ),
    );
  }

  void _showPredictionResult(Map<String, dynamic> data) {
    final suggestions = (data['suggested_artifacts'] as List<dynamic>?) ?? [];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusLg)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.85,
        minChildSize: 0.3,
        expand: false,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(AppConstants.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppConstants.spacingMd),
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Classification Result',
                style: Theme.of(ctx).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppConstants.spacingMd),
              Container(
                padding: const EdgeInsets.all(AppConstants.spacingMd),
                decoration: BoxDecoration(
                  color: AppColors.creamWhite,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.category, color: AppColors.primaryBrown),
                    const SizedBox(width: AppConstants.spacingSm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['predicted_category'] ?? 'Unknown',
                            style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            'Confidence: ${data['confidence'] ?? 0}%',
                            style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (suggestions.isNotEmpty) ...[
                const SizedBox(height: AppConstants.spacingLg),
                Text(
                  'Suggested Artifacts',
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: AppConstants.spacingSm),
                ...suggestions.map((s) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primaryBrown,
                        foregroundColor: Colors.white,
                        child: Text('${s['id']}'),
                      ),
                      title: Text(s['title'] ?? 'Unknown'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.pop(ctx);
                        _fetchAndShowArtifact(s['id'] as int);
                      },
                    )),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _fetchAndShowArtifact(int id) async {
    setState(() => _isLoading = true);
    try {
      final role = _getUserRole();
      final result = await _mlService.getArtifactByIdAndRole(id, role);
      if (mounted) {
        _showArtifactResult(result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fetch artifact: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatFieldName(String key) {
    // Convert snake_case field names to Title Case
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
        actions: [
          // Role selector dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: DropdownButton<String>(
              value: _selectedRole,
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              dropdownColor: AppColors.primaryBrown,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              items: _availableRoles.map((role) => DropdownMenuItem(
                value: role,
                child: Text(
                  role[0].toUpperCase() + role.substring(1),
                  style: const TextStyle(color: Colors.white),
                ),
              )).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedRole = value);
              },
            ),
          ),
          if (_isScannerActive)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _stopScanner,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isScannerActive
              ? _buildScannerView()
              : _buildIdleView(),
    );
  }

  Widget _buildScannerView() {
    return Stack(
      children: [
        MobileScanner(
          controller: _cameraController!,
          onDetect: _onQRDetected,
        ),
        // Scan overlay
        Center(
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primaryBrown, width: 3),
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            ),
          ),
        ),
        // Bottom actions
        Positioned(
          bottom: AppConstants.spacingXl,
          left: 0,
          right: 0,
          child: Center(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.9),
              ),
              onPressed: () {
                _stopScanner();
                _pickImageAndClassify();
              },
              icon: const Icon(Icons.photo_library),
              label: const Text('Pick from Gallery'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIdleView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
              'Scan QR codes to get personalized information about artifacts, or classify artifacts from photos.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingXl),
            ElevatedButton.icon(
              onPressed: _startScanner,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Start Scanning'),
            ),
            const SizedBox(height: AppConstants.spacingMd),
            OutlinedButton.icon(
              onPressed: _pickImageAndClassify,
              icon: const Icon(Icons.photo_library),
              label: const Text('Classify from Gallery'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet widget with image display and audio playback for artifact details
class _ArtifactDetailSheet extends StatefulWidget {
  final Map<String, dynamic> data;
  final Map<String, dynamic> personalized;
  final String? imageUrl;
  final String? audioUrl;
  final String Function(String) formatFieldName;

  const _ArtifactDetailSheet({
    required this.data,
    required this.personalized,
    required this.imageUrl,
    required this.audioUrl,
    required this.formatFieldName,
  });

  @override
  State<_ArtifactDetailSheet> createState() => _ArtifactDetailSheetState();
}

class _ArtifactDetailSheetState extends State<_ArtifactDetailSheet> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final TranslationService _translationService = TranslationService();
  final ApiService _apiService = ApiService();
  bool _isPlaying = false;

  // AI-generated description state
  String? _aiDescription;
  String? _translatedAiDescription;
  bool _isGeneratingDescription = false;

  // Translation state
  static const _languages = ['English', 'Sinhala', 'Tamil', 'Spanish', 'French'];
  static const _langCodes = {
    'English': 'en', 'Sinhala': 'si', 'Tamil': 'ta', 'Spanish': 'es', 'French': 'fr',
  };
  String _selectedLanguage = 'English';
  Map<String, dynamic>? _translatedPersonalized;
  bool _isTranslating = false;

  Map<String, dynamic> get _activePersonalized =>
      _translatedPersonalized ?? widget.personalized;

  @override
  void initState() {
    super.initState();
    _fetchAiDescription();
  }

  Future<void> _fetchAiDescription() async {
    final artifactId = widget.data['id'];
    final role = widget.data['role'] as String? ?? 'tourist';
    if (artifactId == null) return;

    setState(() {
      _isGeneratingDescription = true;
      _translatedAiDescription = null;
    });

    try {
      final response = await _apiService.post(
        AppConstants.generateDescriptionEndpoint,
        {'artifact_id': artifactId, 'role': role},
        requiresAuth: false,
      );
      if (mounted) {
        setState(() {
          _aiDescription = response['description'];
          _isGeneratingDescription = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGeneratingDescription = false);
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _translateContent() async {
    final toLang = _langCodes[_selectedLanguage];
    if (toLang == null || toLang == 'en') {
      // Reset to original
      setState(() {
        _translatedPersonalized = null;
        _translatedAiDescription = null;
      });
      return;
    }

    setState(() => _isTranslating = true);

    try {
      final translated = <String, dynamic>{};
      for (final entry in widget.personalized.entries) {
        if (entry.value == null) {
          translated[entry.key] = null;
          continue;
        }
        final text = entry.value.toString();
        if (text.trim().isEmpty) {
          translated[entry.key] = text;
          continue;
        }
        translated[entry.key] = await _translationService.translate(text, 'en', toLang);
      }

      // Also translate the AI-generated description
      String? translatedAi;
      if (_aiDescription != null && _aiDescription!.trim().isNotEmpty) {
        translatedAi = await _translationService.translate(_aiDescription!, 'en', toLang);
      }

      if (mounted) {
        setState(() {
          _translatedPersonalized = translated;
          _translatedAiDescription = translatedAi;
          _isTranslating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isTranslating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Translation failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _toggleAudio() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      setState(() => _isPlaying = false);
    } else {
      if (widget.audioUrl != null) {
        await _audioPlayer.play(UrlSource(widget.audioUrl!));
        setState(() => _isPlaying = true);
        _audioPlayer.onPlayerComplete.listen((_) {
          if (mounted) setState(() => _isPlaying = false);
        });
      }
    }
  }

  Widget _buildRoleContent(BuildContext context) {
    final role = widget.data['role'] as String? ?? '';
    final p = _activePersonalized;
    switch (role) {
      case 'student':
        return _StudentQuizView(
          personalized: p,
          aiDescription: _translatedAiDescription ?? _aiDescription,
          isGenerating: _isGeneratingDescription,
          onRegenerate: _fetchAiDescription,
        );
      case 'tourist':
        return _TouristView(
          personalized: p,
          aiDescription: _translatedAiDescription ?? _aiDescription,
          isGenerating: _isGeneratingDescription,
          onRegenerate: _fetchAiDescription,
        );
      case 'teacher':
        return _TeacherView(
          personalized: p,
          aiDescription: _translatedAiDescription ?? _aiDescription,
          isGenerating: _isGeneratingDescription,
          onRegenerate: _fetchAiDescription,
        );
      case 'professor':
        return _ProfessorView(
          personalized: p,
          aiDescription: _translatedAiDescription ?? _aiDescription,
          isGenerating: _isGeneratingDescription,
          onRegenerate: _fetchAiDescription,
        );
      case 'citizen':
        return _CitizenView(
          personalized: p,
          aiDescription: _translatedAiDescription ?? _aiDescription,
          isGenerating: _isGeneratingDescription,
          onRegenerate: _fetchAiDescription,
        );
      default:
        return _GenericFieldsView(
          personalized: p,
          formatFieldName: widget.formatFieldName,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.3,
      expand: false,
      builder: (ctx, scrollController) => SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppConstants.spacingMd),
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Artifact image
            if (widget.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                child: Image.network(
                  widget.imageUrl!,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: double.infinity,
                    height: 220,
                    color: AppColors.creamWhite,
                    child: const Icon(Icons.image_not_supported, size: 48, color: AppColors.textTertiary),
                  ),
                ),
              ),

            if (widget.imageUrl != null)
              const SizedBox(height: AppConstants.spacingMd),

            // Title + Audio button row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    widget.data['title'] ?? 'Unknown Artifact',
                    style: Theme.of(ctx).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                if (widget.audioUrl != null)
                  IconButton(
                    onPressed: _toggleAudio,
                    icon: Icon(
                      _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                      size: 40,
                      color: AppColors.primaryBrown,
                    ),
                    tooltip: _isPlaying ? 'Pause audio' : 'Play audio guide',
                  ),
              ],
            ),

            const SizedBox(height: AppConstants.spacingSm),

            // Category chip + Hidden Gem badge
            Wrap(
              spacing: AppConstants.spacingSm,
              children: [
                if (widget.data['category'] != null)
                  Chip(
                    label: Text(widget.data['category']),
                    backgroundColor: AppColors.creamWhite,
                  ),
                if (widget.data['view_count'] != null &&
                    (widget.data['view_count'] as num) <= 10)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8E44AD),
                      borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.diamond, size: 16, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'Hidden Gem',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            if (widget.data['tags'] != null) ...[
              const SizedBox(height: AppConstants.spacingSm),
              Text(
                'Tags: ${widget.data['tags']}',
                style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],

            const SizedBox(height: AppConstants.spacingMd),

            // Role badge
            Text(
              'Personalized for: ${widget.data['role'] ?? 'you'}',
              style: Theme.of(ctx).textTheme.labelLarge?.copyWith(
                    color: AppColors.primaryBrown,
                    fontWeight: FontWeight.w600,
                  ),
            ),

            const SizedBox(height: AppConstants.spacingSm),

            // Language selector + translate button
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingSm,
                vertical: AppConstants.spacingXs,
              ),
              decoration: BoxDecoration(
                color: AppColors.creamWhite,
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              ),
              child: Row(
                children: [
                  const Icon(Icons.translate, size: 20, color: AppColors.primaryBrown),
                  const SizedBox(width: AppConstants.spacingSm),
                  Expanded(
                    child: DropdownButton<String>(
                      value: _selectedLanguage,
                      isExpanded: true,
                      underline: const SizedBox(),
                      icon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryBrown),
                      items: _languages.map((lang) => DropdownMenuItem(
                        value: lang,
                        child: Text(lang),
                      )).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedLanguage = value;
                            _translatedPersonalized = null;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingSm),
                  _isTranslating
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : TextButton(
                          onPressed: _selectedLanguage == 'English'
                              ? null
                              : _translateContent,
                          child: Text(
                            _translatedPersonalized != null ? 'Translated' : 'Translate',
                          ),
                        ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.spacingSm),

            // Role-specific interactive content
            _buildRoleContent(ctx),

            const SizedBox(height: AppConstants.spacingMd),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Data classes & parsers
// ---------------------------------------------------------------------------

class _McqQuestion {
  final String id;
  final String questionText;
  final List<String> options;
  final String correctAnswer;

  const _McqQuestion({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctAnswer,
  });
}

List<_McqQuestion> _parseMcqData(String? questions, String? options, String? answers) {
  if (questions == null || options == null || answers == null) return [];

  final questionMap = <String, String>{};
  for (final line in questions.split('\n')) {
    final parts = line.split('|');
    if (parts.length >= 2) {
      questionMap[parts[0].trim()] = parts.sublist(1).join('|').trim();
    }
  }

  final optionMap = <String, List<String>>{};
  for (final line in options.split('\n')) {
    final parts = line.split('|');
    if (parts.length >= 2) {
      optionMap[parts[0].trim()] = parts.sublist(1).map((o) => o.trim()).where((o) => o.isNotEmpty).toList();
    }
  }

  final answerMap = <String, String>{};
  for (final line in answers.split('\n')) {
    final parts = line.split('|');
    if (parts.length >= 2) {
      answerMap[parts[0].trim()] = parts[1].trim();
    }
  }

  final result = <_McqQuestion>[];
  for (final id in questionMap.keys) {
    if (optionMap.containsKey(id) && answerMap.containsKey(id)) {
      result.add(_McqQuestion(
        id: id,
        questionText: questionMap[id]!,
        options: optionMap[id]!,
        correctAnswer: answerMap[id]!,
      ));
    }
  }
  return result;
}

String _extractLetter(String option) {
  final match = RegExp(r'^([A-Za-z])\)').firstMatch(option);
  return match?.group(1)?.toUpperCase() ?? '';
}

List<String> _parseReferences(String? refs) {
  if (refs == null || refs.trim().isEmpty) return [];
  return refs.split(';').map((r) => r.trim()).where((r) => r.isNotEmpty).toList();
}

// ---------------------------------------------------------------------------
// Shared AI Description Card
// ---------------------------------------------------------------------------

class _AiDescriptionCard extends StatelessWidget {
  final String? aiDescription;
  final bool isGenerating;
  final VoidCallback onRegenerate;
  final String? fallbackDescription;

  const _AiDescriptionCard({
    required this.aiDescription,
    required this.isGenerating,
    required this.onRegenerate,
    this.fallbackDescription,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.creamWhite,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, size: 18, color: AppColors.primaryBrown),
              const SizedBox(width: AppConstants.spacingSm),
              Text(
                'AI-Generated Description',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.primaryBrown,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              if (!isGenerating)
                InkWell(
                  onTap: onRegenerate,
                  borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.refresh, size: 20, color: AppColors.primaryBrown),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingSm),
          if (isGenerating)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppConstants.spacingMd),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else if (aiDescription != null)
            Text(aiDescription!, style: Theme.of(context).textTheme.bodyLarge)
          else if (fallbackDescription != null)
            Text(fallbackDescription!, style: Theme.of(context).textTheme.bodyLarge)
          else
            Text(
              'Tap refresh to generate a description',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textTertiary,
                    fontStyle: FontStyle.italic,
                  ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Student Quiz View
// ---------------------------------------------------------------------------

class _StudentQuizView extends StatefulWidget {
  final Map<String, dynamic> personalized;
  final String? aiDescription;
  final bool isGenerating;
  final VoidCallback onRegenerate;
  const _StudentQuizView({
    required this.personalized,
    required this.aiDescription,
    required this.isGenerating,
    required this.onRegenerate,
  });

  @override
  State<_StudentQuizView> createState() => _StudentQuizViewState();
}

class _StudentQuizViewState extends State<_StudentQuizView> {
  late final List<_McqQuestion> _questions;
  final Map<String, String> _selectedAnswers = {};
  final Map<String, bool> _checkedAnswers = {};
  bool _quizComplete = false;

  @override
  void initState() {
    super.initState();
    _questions = _parseMcqData(
      widget.personalized['student_mcq_questions']?.toString(),
      widget.personalized['student_mcq_options']?.toString(),
      widget.personalized['student_mcq_answers']?.toString(),
    );
  }

  void _resetQuiz() {
    setState(() {
      _selectedAnswers.clear();
      _checkedAnswers.clear();
      _quizComplete = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final fallback = widget.personalized['student_description']?.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AiDescriptionCard(
          aiDescription: widget.aiDescription,
          isGenerating: widget.isGenerating,
          onRegenerate: widget.onRegenerate,
          fallbackDescription: fallback,
        ),
        const SizedBox(height: AppConstants.spacingMd),
        if (_questions.isNotEmpty) ...[
          Row(
            children: [
              const Icon(Icons.quiz, color: AppColors.primaryBrown),
              const SizedBox(width: AppConstants.spacingSm),
              Text(
                'Quiz',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMd),
          ..._questions.asMap().entries.map(
                (entry) => _buildQuestionCard(context, entry.key, entry.value),
              ),
          if (_quizComplete) _buildScoreCard(context),
        ],
      ],
    );
  }

  Widget _buildQuestionCard(BuildContext context, int index, _McqQuestion q) {
    final isChecked = _checkedAnswers.containsKey(q.id);
    final selectedOption = _selectedAnswers[q.id];

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMd),
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.creamWhite,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question ${index + 1}',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.primaryBrown,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppConstants.spacingXs),
          Text(
            q.questionText,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppConstants.spacingSm),
          ...q.options.map((option) {
            final letter = _extractLetter(option);
            final isSelected = selectedOption == option;
            final isCorrectOption = letter == q.correctAnswer;

            Color bgColor = AppColors.surface;
            Color borderColor = AppColors.divider;
            IconData? trailingIcon;
            Color? iconColor;

            if (isChecked) {
              if (isCorrectOption) {
                bgColor = AppColors.success.withOpacity(0.15);
                borderColor = AppColors.success;
                trailingIcon = Icons.check_circle;
                iconColor = AppColors.success;
              } else if (isSelected && !isCorrectOption) {
                bgColor = AppColors.error.withOpacity(0.15);
                borderColor = AppColors.error;
                trailingIcon = Icons.cancel;
                iconColor = AppColors.error;
              }
            } else if (isSelected) {
              bgColor = AppColors.lightBrown.withOpacity(0.2);
              borderColor = AppColors.primaryBrown;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.spacingSm),
              child: AnimatedContainer(
                duration: AppConstants.animationFast,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                  border: Border.all(
                    color: borderColor,
                    width: (isSelected || (isChecked && isCorrectOption)) ? 2 : 1,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: isChecked
                        ? null
                        : () => setState(() => _selectedAnswers[q.id] = option),
                    borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              option,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          if (trailingIcon != null)
                            Icon(trailingIcon, color: iconColor, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
          if (selectedOption != null && !isChecked)
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  final letter = _extractLetter(selectedOption);
                  setState(() {
                    _checkedAnswers[q.id] = (letter == q.correctAnswer);
                    if (_checkedAnswers.length == _questions.length) {
                      _quizComplete = true;
                    }
                  });
                },
                child: const Text('Check Answer'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScoreCard(BuildContext context) {
    final correct = _checkedAnswers.values.where((v) => v).length;
    final total = _questions.length;
    final percent = total > 0 ? (correct / total * 100).round() : 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      decoration: BoxDecoration(
        color: percent >= 70
            ? AppColors.success.withOpacity(0.1)
            : AppColors.accentGold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(
          color: percent >= 70 ? AppColors.success : AppColors.accentGold,
        ),
      ),
      child: Column(
        children: [
          Icon(
            percent >= 70 ? Icons.emoji_events : Icons.sentiment_satisfied_alt,
            size: 48,
            color: percent >= 70 ? AppColors.success : AppColors.accentGold,
          ),
          const SizedBox(height: AppConstants.spacingSm),
          Text(
            'Score: $correct / $total',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppConstants.spacingXs),
          Text(
            percent >= 70 ? 'Great job!' : 'Keep learning!',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: AppConstants.spacingMd),
          OutlinedButton.icon(
            onPressed: _resetQuiz,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tourist View
// ---------------------------------------------------------------------------

class _TouristView extends StatelessWidget {
  final Map<String, dynamic> personalized;
  final String? aiDescription;
  final bool isGenerating;
  final VoidCallback onRegenerate;
  const _TouristView({
    required this.personalized,
    required this.aiDescription,
    required this.isGenerating,
    required this.onRegenerate,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = personalized['tourist_description']?.toString();
    final funFacts = personalized['tourist_fun_facts']?.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AiDescriptionCard(
          aiDescription: aiDescription,
          isGenerating: isGenerating,
          onRegenerate: onRegenerate,
          fallbackDescription: fallback,
        ),
        if (funFacts != null) ...[
          const SizedBox(height: AppConstants.spacingMd),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            decoration: BoxDecoration(
              color: AppColors.softGold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              border: Border.all(color: AppColors.accentGold, width: 1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb, color: AppColors.accentGold, size: 24),
                const SizedBox(width: AppConstants.spacingSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fun Fact',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.accentGold,
                            ),
                      ),
                      const SizedBox(height: AppConstants.spacingXs),
                      Text(funFacts, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Teacher View
// ---------------------------------------------------------------------------

class _TeacherView extends StatelessWidget {
  final Map<String, dynamic> personalized;
  final String? aiDescription;
  final bool isGenerating;
  final VoidCallback onRegenerate;
  const _TeacherView({
    required this.personalized,
    required this.aiDescription,
    required this.isGenerating,
    required this.onRegenerate,
  });

  @override
  Widget build(BuildContext context) {
    final lessonPoints = personalized['teacher_lesson_points']?.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AiDescriptionCard(
          aiDescription: aiDescription,
          isGenerating: isGenerating,
          onRegenerate: onRegenerate,
          fallbackDescription: personalized['teacher_description']?.toString(),
        ),
        const SizedBox(height: AppConstants.spacingMd),
        if (lessonPoints != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            decoration: BoxDecoration(
              color: AppColors.creamWhite,
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              border: Border.all(color: AppColors.primaryBrown.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.school, color: AppColors.primaryBrown),
                    const SizedBox(width: AppConstants.spacingSm),
                    Text(
                      'Lesson Points',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingSm),
                ...lessonPoints.split('\n').where((l) => l.trim().isNotEmpty).map(
                      (point) => Padding(
                        padding: const EdgeInsets.only(bottom: AppConstants.spacingXs),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 6),
                              child: Icon(Icons.circle, size: 8, color: AppColors.primaryBrown),
                            ),
                            const SizedBox(width: AppConstants.spacingSm),
                            Expanded(
                              child: Text(point.trim(), style: Theme.of(context).textTheme.bodyMedium),
                            ),
                          ],
                        ),
                      ),
                    ),
              ],
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Professor View
// ---------------------------------------------------------------------------

class _ProfessorView extends StatelessWidget {
  final Map<String, dynamic> personalized;
  final String? aiDescription;
  final bool isGenerating;
  final VoidCallback onRegenerate;
  const _ProfessorView({
    required this.personalized,
    required this.aiDescription,
    required this.isGenerating,
    required this.onRegenerate,
  });

  Future<void> _searchScholar(BuildContext context, String reference) async {
    final query = Uri.encodeComponent(reference);
    final url = Uri.parse('https://scholar.google.com/scholar?q=$query');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not search for "$reference"')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final refsRaw = personalized['professor_references']?.toString();
    final references = _parseReferences(refsRaw);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AiDescriptionCard(
          aiDescription: aiDescription,
          isGenerating: isGenerating,
          onRegenerate: onRegenerate,
          fallbackDescription: personalized['professor_description']?.toString(),
        ),
        const SizedBox(height: AppConstants.spacingMd),
        if (references.isNotEmpty) ...[
          Row(
            children: [
              const Icon(Icons.menu_book, color: AppColors.primaryBrown),
              const SizedBox(width: AppConstants.spacingSm),
              Text(
                'Academic References',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingSm),
          ...references.map(
            (ref) => Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.spacingSm),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _searchScholar(context, ref),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.creamWhite,
                      borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.open_in_new, size: 18, color: AppColors.info),
                        const SizedBox(width: AppConstants.spacingSm),
                        Expanded(
                          child: Text(
                            ref,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.info,
                                  decoration: TextDecoration.underline,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Citizen View
// ---------------------------------------------------------------------------

class _CitizenView extends StatelessWidget {
  final Map<String, dynamic> personalized;
  final String? aiDescription;
  final bool isGenerating;
  final VoidCallback onRegenerate;
  const _CitizenView({
    required this.personalized,
    required this.aiDescription,
    required this.isGenerating,
    required this.onRegenerate,
  });

  @override
  Widget build(BuildContext context) {
    final culturalNote = personalized['citizen_cultural_note']?.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AiDescriptionCard(
          aiDescription: aiDescription,
          isGenerating: isGenerating,
          onRegenerate: onRegenerate,
          fallbackDescription: personalized['citizen_description']?.toString(),
        ),
        const SizedBox(height: AppConstants.spacingMd),
        if (culturalNote != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            decoration: BoxDecoration(
              color: AppColors.warmWhite,
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              border: Border.all(color: AppColors.veryLightBrown, width: 1.5),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.auto_stories, color: AppColors.mediumBrown, size: 24),
                const SizedBox(width: AppConstants.spacingSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cultural Significance',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.mediumBrown,
                            ),
                      ),
                      const SizedBox(height: AppConstants.spacingXs),
                      Text(culturalNote, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Generic Fallback View
// ---------------------------------------------------------------------------

class _GenericFieldsView extends StatelessWidget {
  final Map<String, dynamic> personalized;
  final String Function(String) formatFieldName;
  const _GenericFieldsView({required this.personalized, required this.formatFieldName});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: personalized.entries
          .where((e) => e.value != null)
          .map((e) => Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatFieldName(e.key),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: AppConstants.spacingXs),
                    Text(
                      e.value.toString(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
