import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();
  String _selectedCategory = 'General';
  int _rating = 5;

  final List<String> _categories = [
    'General',
    'Bug Report',
    'Feature Request',
    'Content Issue',
    'Performance',
  ];

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _submitFeedback() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Send feedback to backend
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 64,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingLg),
                Text(
                  'Thank You!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBrown,
                      ),
                ),
                const SizedBox(height: AppConstants.spacingSm),
                Text(
                  'Your feedback has been submitted successfully. We appreciate you taking the time to help us improve!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog only
                    _resetForm(); // Reset form for new feedback
                  },
                  child: const Text('Done'),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  void _resetForm() {
    setState(() {
      _feedbackController.clear();
      _selectedCategory = 'General';
      _rating = 5;
    });
  }

  // TODO: Implement facial feedback capture
  void _startFacialFeedback() {
    // Placeholder for facial emotion recognition
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Facial feedback coming soon!'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  // TODO: Implement vocal feedback capture
  void _startVocalFeedback() {
    // Placeholder for voice sentiment analysis
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Vocal feedback coming soon!'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                'We value your feedback',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppConstants.spacingSm),
              Text(
                'Help us improve Serendib by sharing your thoughts and suggestions.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),

              const SizedBox(height: AppConstants.spacingXl),

              // Rating
              Text(
                'How would you rate your experience?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppConstants.spacingMd),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: AppColors.accentGold,
                      size: 40,
                    ),
                    onPressed: () {
                      setState(() {
                        _rating = index + 1;
                      });
                    },
                  );
                }),
              ),

              const SizedBox(height: AppConstants.spacingXl),

              // Advanced Feedback Options (Coming Soon)
              Text(
                'Express Your Feedback',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppConstants.spacingMd),
              Row(
                children: [
                  // Facial Feedback Card
                  Expanded(
                    child: _buildAdvancedFeedbackCard(
                      icon: Icons.face,
                      title: 'Facial',
                      subtitle: 'Coming Soon',
                      onTap: _startFacialFeedback,
                      isEnabled: false,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingMd),
                  // Vocal Feedback Card
                  Expanded(
                    child: _buildAdvancedFeedbackCard(
                      icon: Icons.mic,
                      title: 'Vocal',
                      subtitle: 'Coming Soon',
                      onTap: _startVocalFeedback,
                      isEnabled: false,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppConstants.spacingXl),

              // Category
              Text(
                'Category',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppConstants.spacingMd),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
              ),

              const SizedBox(height: AppConstants.spacingLg),

              // Feedback Text
              Text(
                'Your Feedback',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppConstants.spacingMd),
              TextFormField(
                controller: _feedbackController,
                maxLines: 8,
                decoration: const InputDecoration(
                  hintText: 'Tell us what you think...',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your feedback';
                  }
                  if (value.length < 10) {
                    return 'Please provide more detailed feedback';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppConstants.spacingXl),

              // Submit Button
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _submitFeedback,
                  icon: const Icon(Icons.send),
                  label: const Text('Submit Feedback'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdvancedFeedbackCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isEnabled = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        decoration: BoxDecoration(
          color: isEnabled
              ? AppColors.creamWhite
              : AppColors.lightCream.withOpacity(0.5),
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(
            color: isEnabled ? AppColors.primaryBrown : AppColors.divider,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isEnabled
                    ? AppColors.primaryBrown.withOpacity(0.1)
                    : AppColors.textTertiary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color:
                    isEnabled ? AppColors.primaryBrown : AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: AppConstants.spacingSm),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color:
                    isEnabled ? AppColors.textPrimary : AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.accentGold.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
