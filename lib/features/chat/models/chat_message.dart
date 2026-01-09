import 'package:equatable/equatable.dart';

enum MessageRole { user, model }

class ChatMessage extends Equatable {
  final String text;
  final MessageRole role;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.role,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  List<Object?> get props => [text, role, timestamp];
}
