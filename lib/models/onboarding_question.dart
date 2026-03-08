enum QuestionType {
  singleChoice,
  multiChoice,
  conditional,
}

class OnboardingQuestion {
  final String id;
  final String question;
  final List<String> options;
  final QuestionType type;
  final bool allowMultiple;

  OnboardingQuestion({
    required this.id,
    required this.question,
    required this.options,
    this.type = QuestionType.singleChoice,
    this.allowMultiple = false,
  });

  static List<OnboardingQuestion> getQuestions() {
    return [
      // Question 1: Visitor Type
      OnboardingQuestion(
        id: 'q1',
        question: 'Are you from this country or a foreign visitor?',
        options: [
          'Local (Sri Lankan)',
          'Foreign Visitor',
        ],
        type: QuestionType.conditional,
      ),

      // Question 2: User Type
      OnboardingQuestion(
        id: 'q2',
        question: 'What describes you best?',
        options: [
          'Student',
          'Teacher',
          'Professor',
          'Researcher',
          'Tourist',
          'History Enthusiast',
          'Local Visitor',
          'Other',
        ],
      ),

      // Question 3: Interests (Multi-select)
      OnboardingQuestion(
        id: 'q3',
        question: 'What are you interested in? (Select all that apply)',
        options: [
          'Coins',
          'Ancient Artifacts',
          'Kandy Era',
          'Kings & Royalty',
          'Agriculture',
          'Statues',
          'Culture',
          'Technology',
          'Architecture',
          'Traditional Arts',
        ],
        type: QuestionType.multiChoice,
        allowMultiple: true,
      ),

      // Question 4: Time to Spend
      OnboardingQuestion(
        id: 'q4',
        question: 'How much time would you like to spend in the museum?',
        options: [
          'Below 1 hour',
          '1 - 2 hours',
          '2 - 3 hours',
          'Above 3 hours',
        ],
      ),

      // Question 5: Language/Region
      OnboardingQuestion(
        id: 'q5',
        question: 'What is your preferred language?',
        options: [
          'Sinhala',
          'Tamil',
          'English',
          'Other',
        ],
      ),
    ];
  }
}

class OnboardingResponse {
  final String questionId;
  final dynamic selectedOption; // Can be String or List<String>

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
      selectedOption: json['selectedOption'],
    );
  }
}
