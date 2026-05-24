import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../domain/models/ai_message.dart';

class AiMessageBubble extends StatelessWidget {
  const AiMessageBubble({super.key, required this.message});
  final AiMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == AiMessageRole.user;
    final align =
        isUser ? Alignment.centerRight : Alignment.centerLeft;
    final color = isUser ? AppColors.accent : AppColors.bgCard;
    final textColor =
        isUser ? Colors.white : AppColors.textPrimary;

    return Align(
      alignment: align,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser
                ? const Radius.circular(16)
                : const Radius.circular(4),
            bottomRight: isUser
                ? const Radius.circular(4)
                : const Radius.circular(16),
          ),
          border: isUser ? null : Border.all(color: AppColors.border),
        ),
        child: Text(
          message.content,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            height: 1.35,
          ),
        ),
      ),
    );
  }
}
