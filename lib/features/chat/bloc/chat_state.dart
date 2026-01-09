import 'package:equatable/equatable.dart';
import 'package:travel_planner/features/chat/models/chat_message.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}

class SendMessage extends ChatEvent {
  final String text;
  const SendMessage({required this.text});
  @override
  List<Object?> get props => [text];
}

abstract class ChatState extends Equatable {
  const ChatState();
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatMessage> messages;
  final bool isTyping;

  const ChatLoaded({required this.messages, this.isTyping = false});

  @override
  List<Object?> get props => [messages, isTyping];
}

class ChatError extends ChatState {
  final String message;
  const ChatError({required this.message});
  @override
  List<Object?> get props => [message];
}
