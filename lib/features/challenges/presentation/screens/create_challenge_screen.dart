import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/widgets/hero_button.dart';
import '../../application/challenges_notifier.dart';

/// Minimal author-your-own-challenge form. Calls the
/// `create_user_challenge` RPC behind the scenes and pops with the new
/// challenge id so the caller can navigate into the detail screen.
class CreateChallengeScreen extends ConsumerStatefulWidget {
  const CreateChallengeScreen({super.key});

  @override
  ConsumerState<CreateChallengeScreen> createState() =>
      _CreateChallengeScreenState();
}

class _CreateChallengeScreenState
    extends ConsumerState<CreateChallengeScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _targetCtrl = TextEditingController(text: '10');
  String _metric = 'count';
  DateTime _endAt = DateTime.now().add(const Duration(days: 30));
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _targetCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickEndAt() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endAt,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _endAt = picked);
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    final target = num.tryParse(_targetCtrl.text.replaceAll(',', '.'));
    if (title.length < 2 || target == null || target <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.challengeCreateInvalid)),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final client = ref.read(supabaseClientProvider);
      final raw = await client.rpc<dynamic>(
        'create_user_challenge',
        params: {
          'p_title': title,
          'p_description':
              _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
          'p_metric_type': _metric,
          'p_target_value': target,
          'p_end_at': _endAt.toUtc().toIso8601String(),
          'p_reward_xp': 100,
        },
      );
      final map = (raw as Map).cast<String, dynamic>();
      final ok = map['ok'] == true;
      final id = map['challenge_id'] as String?;
      if (!mounted) return;
      if (ok && id != null) {
        // Refresh both lists so the new entry shows up immediately.
        ref.invalidate(systemChallengesNotifierProvider);
        ref.invalidate(myChallengesNotifierProvider);
        context.go('/challenges/$id');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.challengeCreateError)),
        );
      }
    } on PostgrestException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${context.l10n.challengeCreateError}: ${e.message}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.challengeCreateError)),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l.challengeCreateTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: InputDecoration(
                labelText: l.challengeCreateTitleLabel,
                hintText: l.challengeCreateTitleHint,
                border: const OutlineInputBorder(),
              ),
              maxLength: 100,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              decoration: InputDecoration(
                labelText: l.challengeCreateDescriptionLabel,
                border: const OutlineInputBorder(),
              ),
              maxLines: 2,
              maxLength: 300,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _metric,
              decoration: InputDecoration(
                labelText: l.challengeCreateMetricLabel,
                border: const OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                  value: 'count',
                  child: Text(l.challengeMetricCount),
                ),
                DropdownMenuItem(
                  value: 'activity_day',
                  child: Text(l.challengeMetricActivityDay),
                ),
                DropdownMenuItem(
                  value: 'streak',
                  child: Text(l.challengeMetricStreak),
                ),
                DropdownMenuItem(
                  value: 'xp',
                  child: Text(l.challengeMetricXp),
                ),
              ],
              onChanged: (v) => setState(() => _metric = v ?? 'count'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _targetCtrl,
              decoration: InputDecoration(
                labelText: l.challengeCreateTargetLabel,
                border: const OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: false),
            ),
            const SizedBox(height: 12),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Theme.of(context).dividerColor),
              ),
              leading: const Icon(Icons.calendar_today_outlined),
              title: Text(l.challengeCreateEndAtLabel),
              subtitle: Text(
                '${_endAt.year}-${_endAt.month.toString().padLeft(2, '0')}'
                '-${_endAt.day.toString().padLeft(2, '0')}',
              ),
              onTap: _pickEndAt,
            ),
            const SizedBox(height: 24),
            HeroButton(
              label: l.challengeCreateSubmit,
              isLoading: _saving,
              onPressed: _saving ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
