import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  // Basic response patterns - TODO: Replace with actual AI backend
  final Map<String, String> _responses = {
    'hello':
        'Hello! Welcome to Serendib Guide. I\'m here to help you explore the rich cultural heritage of Sri Lanka. How can I assist you today?',
    'hi':
        'Hi there! I\'m your Serendib Guide assistant. Ask me anything about Sri Lankan heritage, artifacts, or historical sites!',
    'help':
        'I can help you with:\n• Information about historical artifacts\n• Details about heritage sites\n• Cultural traditions of Sri Lanka\n• Navigation within the app\n• Tour recommendations\n\nJust ask me anything!',
    'artifact':
        'Sri Lanka has a rich collection of artifacts dating back over 2,500 years. From ancient Buddha statues to intricate moonstones, each piece tells a unique story. Would you like to know about a specific artifact or visit our artifacts gallery?',
    'sigiriya':
        'Sigiriya, the Lion Rock, is a 5th-century rock fortress built by King Kashyapa. It features stunning frescoes, the famous mirror wall, and beautiful water gardens. It\'s a UNESCO World Heritage Site and one of Sri Lanka\'s most iconic landmarks!',
    'kandy':
        'Kandy is the cultural capital of Sri Lanka, home to the sacred Temple of the Tooth Relic (Sri Dalada Maligawa). The city is surrounded by mountains and hosts the famous Esala Perahera festival annually.',
    'anuradhapura':
        'Anuradhapura was the first capital of ancient Sri Lanka, established in the 4th century BC. It\'s home to sacred Bodhi Tree, massive dagobas (stupas), and ancient monasteries. A UNESCO World Heritage Site with over 2,000 years of history!',
    'polonnaruwa':
        'Polonnaruwa served as the second capital of Sri Lanka (11th-13th century). Famous for the Gal Vihara Buddha statues, the Royal Palace, and the Vatadage circular relic house. Another magnificent UNESCO World Heritage Site!',
    'tour':
        'I can help you plan the perfect heritage tour! Popular routes include:\n• Cultural Triangle (Anuradhapura, Polonnaruwa, Sigiriya)\n• Hill Country Heritage (Kandy, Nuwara Eliya)\n• Southern Heritage (Galle Fort, Matara)\n\nWhich interests you?',
    'default':
        'That\'s an interesting question! I\'m still learning about Sri Lankan heritage. For more detailed information, you might want to explore our artifacts gallery or visit the heritage sites section. Is there something specific about Sri Lankan culture I can help you with?',
  };

  @override
  void initState() {
    super.initState();
    // Add welcome message
    _messages.add(ChatMessage(
      text:
          'Welcome to Serendib Guide! 🏛️\n\nI\'m your AI assistant for exploring Sri Lankan heritage. Ask me about historical sites, artifacts, cultural traditions, or get tour recommendations!\n\nHow can I help you today?',
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // Simulate AI thinking delay
    Future.delayed(const Duration(milliseconds: 800), () {
      _generateResponse(text);
    });
  }

  void _generateResponse(String userMessage) {
    // TODO: Replace with actual AI backend call
    final lowerMessage = userMessage.toLowerCase();
    String response = _responses['default']!;

    // Check for keyword matches
    for (final entry in _responses.entries) {
      if (lowerMessage.contains(entry.key)) {
        response = entry.value;
        break;
      }
    }

    setState(() {
      _messages.add(ChatMessage(
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      ));
      _isTyping = false;
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Clear Chat'),
        content: const Text('Are you sure you want to clear the conversation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _messages.clear();
                _messages.add(ChatMessage(
                  text:
                      'Chat cleared! How can I help you explore Sri Lankan heritage?',
                  isUser: false,
                  timestamp: DateTime.now(),
                ));
              });
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accentGold.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy,
                color: AppColors.accentGold,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Serendib AI',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Your Heritage Guide',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _clearChat,
            tooltip: 'Clear chat',
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick suggestion chips
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingMd,
              vertical: AppConstants.spacingSm,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildSuggestionChip('Tell me about Sigiriya'),
                  _buildSuggestionChip('Heritage tour'),
                  _buildSuggestionChip('Ancient artifacts'),
                  _buildSuggestionChip('Help'),
                ],
              ),
            ),
          ),

          const Divider(height: 1),

          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == _messages.length) {
                  return _buildTypingIndicator();
                }
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),

          // Input area
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: AppColors.darkOverlay.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Ask about Sri Lankan heritage...',
                        filled: true,
                        fillColor: AppColors.creamWhite,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusLg),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spacingMd,
                          vertical: AppConstants.spacingSm,
                        ),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingSm),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryBrown,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: AppConstants.spacingSm),
      child: ActionChip(
        label: Text(text),
        backgroundColor: AppColors.creamWhite,
        side: BorderSide(color: AppColors.primaryBrown.withOpacity(0.3)),
        labelStyle: TextStyle(
          color: AppColors.primaryBrown,
          fontSize: 12,
        ),
        onPressed: () {
          _messageController.text = text;
          _sendMessage();
        },
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingMd),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryBrown,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: AppConstants.spacingSm),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              decoration: BoxDecoration(
                color: message.isUser
                    ? AppColors.primaryBrown
                    : AppColors.creamWhite,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(AppConstants.radiusMd),
                  topRight: const Radius.circular(AppConstants.radiusMd),
                  bottomLeft: Radius.circular(
                      message.isUser ? AppConstants.radiusMd : 4),
                  bottomRight: Radius.circular(
                      message.isUser ? 4 : AppConstants.radiusMd),
                ),
                border: message.isUser
                    ? null
                    : Border.all(color: AppColors.divider),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: AppConstants.spacingSm),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accentGold,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingMd),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryBrown,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: AppConstants.spacingSm),
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            decoration: BoxDecoration(
              color: AppColors.creamWhite,
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                const SizedBox(width: 4),
                _buildTypingDot(1),
                const SizedBox(width: 4),
                _buildTypingDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 200)),
      builder: (context, value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.primaryBrown.withOpacity(0.4 + (value * 0.6)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
