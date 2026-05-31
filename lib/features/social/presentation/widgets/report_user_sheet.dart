import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n.dart';
import '../../data/supabase_social_repository.dart';

/// Bottom sheet: pick reason → optional details → submit.
/// Returns true if a report was successfully sent.
class ReportUserSheet {
  ReportUserSheet._();

  static Future<bool> show(
    BuildContext context,
    WidgetRef ref, {
    required String userId,
  }) async {
    final res = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _Body(userId: userId),
    );
    return res ?? false;
  }
}

class _Body extends ConsumerStatefulWidget {
  const _Body({required this.userId});
  final String userId;

  @override
  ConsumerState<_Body> createState() => _BodyState();
}

class _BodyState extends ConsumerState<_Body> {
  String _reason = 'spam';
  final _details = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _details.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_sending) return;
    setState(() => _sending = true);
    final l = context.l10n;
    try {
      await ref.read(socialRepositoryProvider).reportUser(
            widget.userId,
            _reason,
            _details.text.isEmpty ? null : _details.text,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.reportSent)),
      );
      Navigator.of(context).pop(true);
    } on SocialFriendException catch (e) {
      if (!mounted) return;
      final msg = e.code == 'rate_limited'
          ? l.reportRateLimited
          : l.friendActionError;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Widget _radio(String value, String label) {
    final selected = _reason == value;
    return ListTile(
      title: Text(label),
      leading: Icon(
        selected
            ? Icons.radio_button_checked
            : Icons.radio_button_unchecked,
        color: selected ? Theme.of(context).colorScheme.primary : null,
      ),
      onTap: () => setState(() => _reason = value),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          16 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.reportTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l.reportReason,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            _radio('spam', l.reportReasonSpam),
            _radio('harassment', l.reportReasonHarassment),
            _radio('inappropriate', l.reportReasonInappropriate),
            _radio('other', l.reportReasonOther),
            const SizedBox(height: 12),
            TextField(
              controller: _details,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l.reportDetailsLabel,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _sending ? null : _submit,
              child: Text(l.reportSubmit),
            ),
          ],
        ),
      ),
    );
  }
}
