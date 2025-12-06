import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/onboarding_question.dart';
import '../../services/storage_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final List<OnboardingQuestion> _questions = OnboardingQuestion.getQuestions();
  final Map<String, String> _responses = {};
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _selectOption(String questionId, String option) {
    setState(() {
      _responses[questionId] = option;
    });

    // Auto-advance to next question after short delay
    Future.delayed(AppConstants.animationNormal, () {
      if (_currentPage < _questions.length - 1) {
        _pageController.nextPage(
          duration: AppConstants.animationNormal,
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _completeOnboarding() async {
    final responses = _responses.entries
        .map((e) => OnboardingResponse(
              questionId: e.key,
              selectedOption: e.value,
            ))
        .toList();

    final storage = StorageService();
    await storage.saveOnboardingResponses(responses);
    await storage.setOnboardingCompleted(true);

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header with progress
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacingLg),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Getting Started',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppColors.primaryBrown,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        '${_currentPage + 1}/${_questions.length}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  // Progress bar
                  LinearProgressIndicator(
                    value: (_currentPage + 1) / _questions.length,
                    backgroundColor: AppColors.creamWhite,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBrown),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                  ),
                ],
              ),
            ),

            // Questions
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  final question = _questions[index];
                  return _buildQuestionPage(question);
                },
              ),
            ),

            // Bottom navigation
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacingLg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  if (_currentPage > 0)
                    OutlinedButton.icon(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: AppConstants.animationNormal,
                          curve: Curves.easeInOut,
                        );
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back'),
                    )
                  else
                    const SizedBox(width: 100),

                  // Next/Complete button
                  if (_currentPage == _questions.length - 1 && _responses.length == _questions.length)
                    ElevatedButton.icon(
                      onPressed: _completeOnboarding,
                      icon: const Icon(Icons.check),
                      label: const Text('Complete'),
                    )
                  else
                    const SizedBox(width: 120),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionPage(OnboardingQuestion question) {
    final selectedOption = _responses[question.id];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppConstants.spacingXl),

          // Question
          Text(
            question.question,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(height: AppConstants.spacingXl),

          // Options
          ...question.options.map((option) {
            final isSelected = selectedOption == option;

            return Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.spacingMd),
              child: _OptionCard(
                option: option,
                isSelected: isSelected,
                onTap: () => _selectOption(question.id, option),
              ),
            );
          }),

          const SizedBox(height: AppConstants.spacingXl),
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String option;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppConstants.animationFast,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          child: Container(
            padding: const EdgeInsets.all(AppConstants.spacingLg),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.lightBrown : AppColors.surface,
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              border: Border.all(
                color: isSelected ? AppColors.primaryBrown : AppColors.divider,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primaryBrown.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                // Radio indicator
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.offWhite : AppColors.textTertiary,
                      width: 2,
                    ),
                    color: isSelected ? AppColors.offWhite : Colors.transparent,
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryBrown,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: AppConstants.spacingMd),

                // Option text
                Expanded(
                  child: Text(
                    option,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: isSelected ? AppColors.offWhite : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
