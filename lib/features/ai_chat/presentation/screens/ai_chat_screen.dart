import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/l10n/l10n.dart';
import '../../application/ai_chat_notifier.dart';
import '../widgets/ai_chat_composer.dart';
import '../widgets/ai_message_bubble.dart';
import '../widgets/ai_suggestion_card.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _onSend(String text) async {
    final locale =
        Localizations.localeOf(context).languageCode == 'ru' ? 'ru' : 'en';
    try {
      await ref
          .read(aiChatNotifierProvider.notifier)
          .send(text, locale: locale);
      _scrollToBottom();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.aiChatSendError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final state = ref.watch(aiChatNotifierProvider);

    ref.listen(aiChatNotifierProvider, (_, __) => _scrollToBottom());

    return Scaffold(
      appBar: AppBar(title: Text(l.aiChatTitle)),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(l.aiChatLoadError)),
        data: (view) {
          if (view.messages.isEmpty) {
            return Column(
              children: [
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.smart_toy_outlined,
                            size: 56,
                            color: AppColors.accent,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l.aiChatEmptyTitle,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l.aiChatEmptyBody,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (view.limitReached)
                  _LimitBanner(text: l.aiChatLimitReached),
                AiChatComposer(
                  onSend: _onSend,
                  disabled: view.sending || view.limitReached,
                ),
              ],
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount:
                      view.messages.length + (view.sending ? 1 : 0),
                  itemBuilder: (ctx, i) {
                    if (i == view.messages.length) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const SizedBox(
                              height: 12,
                              width: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l.aiChatThinking,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    final msg = view.messages[i];
                    return Column(
                      children: [
                        AiMessageBubble(message: msg),
                        if (msg.suggestion != null)
                          AiSuggestionCard(suggestion: msg.suggestion!),
                      ],
                    );
                  },
                ),
              ),
              if (view.limitReached)
                _LimitBanner(text: l.aiChatLimitReached),
              AiChatComposer(
                onSend: _onSend,
                disabled: view.sending || view.limitReached,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LimitBanner extends StatelessWidget {
  const _LimitBanner({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.warning.withValues(alpha: 0.18),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }
}
