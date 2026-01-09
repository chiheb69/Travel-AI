import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:travel_planner/features/chat/bloc/chat_state.dart';
import 'package:travel_planner/features/chat/models/chat_message.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GenerativeModel? _model;
  final List<ChatMessage> _messages = [];

  ChatBloc({String? apiKey})
      : _model = (apiKey != null && apiKey.isNotEmpty)
            ? GenerativeModel(
                model: 'gemini-1.5-flash',
                apiKey: apiKey,
              )
            : null,
        super(ChatInitial()) {
    final keyPreview = (apiKey != null && apiKey.length > 5) 
        ? "${apiKey.substring(0, 5)}***" 
        : "MISSING/INVALID";
    print("ChatBloc v11.0 [CACHE-BUSTER]: Initialized [Model: gemini-1.5-flash] [Key: $keyPreview]");
    on<SendMessage>(_onSendMessage);
    
    // Initial welcome message
    _messages.add(ChatMessage(
      text: "Hello! [STABLE v11.0] I'm your AI Travel Assistant. How can I help you plan your next adventure today?",
      role: MessageRole.model,
    ));
    emit(ChatLoaded(messages: List.from(_messages)));
  }

  Future<void> _onSendMessage(SendMessage event, Emitter<ChatState> emit) async {
    final userMessage = ChatMessage(text: event.text, role: MessageRole.user);
    _messages.add(userMessage);
    emit(ChatLoaded(messages: List.from(_messages), isTyping: true));

    try {
      if (_model == null) {
        throw Exception("AI model not initialized. Please check your API key.");
      }

      final content = [Content.text(event.text)];
      print("ChatBloc: Sending generateContent request...");
      final response = await _model!.generateContent(content);
      
      if (response.text == null || response.text!.isEmpty) {
        throw Exception("The AI returned an empty response. Please try again.");
      }

      final modelMessage = ChatMessage(
        text: response.text!,
        role: MessageRole.model,
      );
      _messages.add(modelMessage);
      emit(ChatLoaded(messages: List.from(_messages), isTyping: false));
    } catch (e) {
      print("ChatBloc Error: $e");
      String errorMessage = "AI Error: ${e.toString()}";
      
      // Still show the helpful tip, but include the technical error for me to see
      if (e.toString().contains("v1beta") || e.toString().contains("not found")) {
        errorMessage = "AI Technical Error: ${e.toString()}\n\nTip: Check if your API key is restricted in AI Studio.";
      }

      emit(ChatError(message: errorMessage));
      emit(ChatLoaded(messages: List.from(_messages), isTyping: false));
    }
  }
}
