import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_planner/core/theme.dart';
import 'package:travel_planner/features/chat/bloc/chat_bloc.dart';
import 'package:travel_planner/features/chat/bloc/chat_state.dart';
import 'package:travel_planner/features/chat/models/chat_message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🚀 Build Version: Gemini Hardcode Fix v3.0"),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.blueAccent,
        ),
      );
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Travel AI', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Online Assistant', style: TextStyle(fontSize: 12, color: AppTheme.accentColor)),
          ],
        ),
        backgroundColor: AppTheme.surfaceDark,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ChatBloc, ChatState>(
              listener: (context, state) {
                if (state is ChatLoaded) {
                  _scrollToBottom();
                } else if (state is ChatError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.all(20),
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is ChatLoaded) {
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(20),
                    itemCount: state.messages.length + (state.isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == state.messages.length) {
                        return const TypingIndicator();
                      }
                      final message = state.messages[index];
                      return ChatBubble(message: message);
                    },
                  );
                }
                return const Center(child: CircularProgressIndicator(color: AppTheme.accentColor));
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: TextField(
                  controller: _messageController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Ask about your trip...',
                    hintStyle: TextStyle(color: Colors.white38),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                if (_messageController.text.isNotEmpty) {
                  context.read<ChatBloc>().add(SendMessage(text: _messageController.text));
                  _messageController.clear();
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: AppTheme.accentColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send_rounded, color: AppTheme.primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    return FadeInUp(
      duration: const Duration(milliseconds: 400),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Row(
          mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!isUser) ...[
              const CircleAvatar(
                backgroundColor: AppTheme.accentColor,
                child: Icon(Icons.auto_awesome, color: AppTheme.primaryColor, size: 20),
              ),
              const SizedBox(width: 12),
            ],
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: isUser ? AppTheme.accentColor : AppTheme.surfaceDark,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isUser ? 20 : 0),
                    bottomRight: Radius.circular(isUser ? 0 : 20),
                  ),
                ),
                child: Text(
                  message.text,
                  style: TextStyle(
                    color: isUser ? AppTheme.primaryColor : Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            if (isUser) const SizedBox(width: 40),
            if (!isUser) const SizedBox(width: 40),
          ],
        ),
      ),
    );
  }
}

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: AppTheme.accentColor,
              child: Icon(Icons.auto_awesome, color: AppTheme.primaryColor, size: 20),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: List.generate(3, (index) {
                  return FadeIn(
                    delay: Duration(milliseconds: 200 * index),
                    duration: const Duration(seconds: 1),
                    child: Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: const BoxDecoration(color: AppTheme.accentColor, shape: BoxShape.circle),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
