import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/l10n/l10n.dart';
import '../../../../../core/widgets/hero_button.dart';
import '../../application/goal_creation_notifier.dart';

/// Step 1 of goal creation: just the "what" (title + optional why).
/// Picking the archetype, period, time budget and plan mode happens on the
/// next screen ([GoalArchetypeScreen]).
class GoalCreateScreen extends ConsumerStatefulWidget {
  const GoalCreateScreen({super.key});

  @override
  ConsumerState<GoalCreateScreen> createState() => _GoalCreateScreenState();
}

class _GoalCreateScreenState extends ConsumerState<GoalCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _continue() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final desc = _descCtrl.text.trim();
    ref.read(goalCreationProvider.notifier).startArchetypePick(
          title: _titleCtrl.text.trim(),
          description: desc.isEmpty ? null : desc,
        );
    // ignore: unawaited_futures
    context.push('/goals/archetype');
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l.goalCreateTitle)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Title ───────────────────────────────────────────
            TextFormField(
              controller: _titleCtrl,
              decoration: InputDecoration(
                labelText: l.goalCreateTitleLabel,
                hintText: l.goalCreateTitleHint,
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLength: 100,
              validator: (v) =>
                  (v == null || v.trim().length < 3) ? '...' : null,
            ),
            const SizedBox(height: 12),

            // ── Description ──────────────────────────────────────
            TextFormField(
              controller: _descCtrl,
              decoration: InputDecoration(
                labelText: l.goalCreateDescriptionLabel,
              ),
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
              maxLength: 280,
            ),
            const SizedBox(height: 32),

            // ── Continue ──────────────────────────────────────────
            HeroButton(
              label: l.goalCreateContinue,
              onPressed: _continue,
            ),
          ],
        ),
      ),
    );
  }
}
