import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/supabase_ai_chat_repository.dart';
import '../domain/ai_chat_repository.dart';
import '../domain/models/ai_message.dart';

class AiChatView {
  const AiChatView({
    required this.conversationId,
    required this.messages,
    required this.sending,
    this.limitReached = false,
  });

  final String? conversationId;
  final List<AiMessage> messages;
  final bool sending;
  final bool limitReached;

  AiChatView copyWith({
    String? conversationId,
    List<AiMessage>? messages,
    bool? sending,
    bool? limitReached,
  }) {
    return AiChatView(
      conversationId: conversationId ?? this.conversationId,
      messages: messages ?? this.messages,
      sending: sending ?? this.sending,
      limitReached: limitReached ?? this.limitReached,
    );
  }
}

class AiChatNotifier extends AsyncNotifier<AiChatView> {
  AiChatRepository get _repo => ref.read(aiChatRepositoryProvider);

  @override
  Future<AiChatView> build() async {
    final conv = await _repo.getOrCreateActive();
    if (conv == null) {
      return const AiChatView(
        conversationId: null,
        messages: [],
        sending: false,
      );
    }
    final msgs = await _repo.listMessages(conv.id);
    return AiChatView(
      conversationId: conv.id,
      messages: msgs,
      sending: false,
    );
  }

  Future<void> send(String text, {required String locale}) async {
    final current = state.value;
    if (current == null || current.sending || text.trim().isEmpty) return;

    final tempId = 'temp-${DateTime.now().millisecondsSinceEpoch}';
    final tempUserMsg = AiMessage(
      id: tempId,
      conversationId: current.conversationId ?? 'pending',
      role: AiMessageRole.user,
      content: text.trim(),
      createdAt: DateTime.now(),
    );
    state = AsyncData(
      current.copyWith(
        messages: [...current.messages, tempUserMsg],
        sending: true,
      ),
    );

    try {
      final res = await _repo.sendMessage(
        conversationId: current.conversationId,
        text: text.trim(),
        locale: locale,
      );
      final newMsgs = state.value!.messages
          .where((m) => m.id != tempId)
          .toList()
        ..add(res.userMessage)
        ..add(res.assistantMessage);
      state = AsyncData(
        state.value!.copyWith(
          conversationId: res.conversationId,
          messages: newMsgs,
          sending: false,
        ),
      );
    } on AiChatDailyLimitException {
      final rolled =
          state.value!.messages.where((m) => m.id != tempId).toList();
      state = AsyncData(
        state.value!.copyWith(
          messages: rolled,
          sending: false,
          limitReached: true,
        ),
      );
    } catch (e) {
      final rolled =
          state.value!.messages.where((m) => m.id != tempId).toList();
      state = AsyncData(
        state.value!.copyWith(messages: rolled, sending: false),
      );
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final conv = await _repo.getOrCreateActive();
      if (conv == null) {
        return const AiChatView(
          conversationId: null,
          messages: [],
          sending: false,
        );
      }
      final msgs = await _repo.listMessages(conv.id);
      return AiChatView(
        conversationId: conv.id,
        messages: msgs,
        sending: false,
      );
    });
  }
}

final aiChatNotifierProvider =
    AsyncNotifierProvider<AiChatNotifier, AiChatView>(AiChatNotifier.new);
