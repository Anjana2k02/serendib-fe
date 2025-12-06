class OnboardingQuestion {
  final String id;
  final String question;
  final List<String> options;

  OnboardingQuestion({
    required this.id,
    required this.question,
    required this.options,
  });

  static List<OnboardingQuestion> getQuestions() {
    return [
      OnboardingQuestion(
        id: 'q1',
        question: 'What brings you to Serendib?',
        options: [
          'Exploring local attractions',
          'Business travel',
          'Cultural experiences',
          'Adventure and nature',
        ],
      ),
      OnboardingQuestion(
        id: 'q2',
        question: 'How do you prefer to navigate?',
        options: [
          'Digital maps and GPS',
          'Local recommendations',
          'Guided tours',
          'Self-exploration',
        ],
      ),
      OnboardingQuestion(
        id: 'q3',
        question: 'What interests you most?',
        options: [
          'Historical sites',
          'Natural landscapes',
          'Food and cuisine',
          'Modern attractions',
        ],
      ),
      OnboardingQuestion(
        id: 'q4',
        question: 'How long is your visit?',
        options: [
          'Just a few days',
          'A week or two',
          'A month',
          'I live here',
        ],
      ),
      OnboardingQuestion(
        id: 'q5',
        question: 'What language do you prefer?',
        options: [
          'English',
          'Sinhala',
          'Tamil',
          'Other',
        ],
      ),
    ];
  }
}

class OnboardingResponse {
  final String questionId;
  final String selectedOption;

  OnboardingResponse({
    required this.questionId,
    required this.selectedOption,
  });

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'selectedOption': selectedOption,
    };
  }

  factory OnboardingResponse.fromJson(Map<String, dynamic> json) {
    return OnboardingResponse(
      questionId: json['questionId'] as String,
      selectedOption: json['selectedOption'] as String,
    );
  }
}
