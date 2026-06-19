import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/l10n/l10n.dart';
import '../../../../../core/widgets/hero_button.dart';
import '../../application/goal_creation_notifier.dart';
import '../../domain/models/goal_create_answers.dart';

class GoalCreateScreen extends ConsumerStatefulWidget {
  const GoalCreateScreen({super.key});

  @override
  ConsumerState<GoalCreateScreen> createState() => _GoalCreateScreenState();
}

class _GoalCreateScreenState extends ConsumerState<GoalCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  int _deadlineDays = 30;
  int _minutesPerDay = 15;
  String _currentLevel = 'beginner';
  bool _hasMaterials = true;

  // Custom deadline date (used when _deadlineDays == 0)
  DateTime? _customDate;

  static const _minuteOptions = [5, 15, 30, 60];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickCustomDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 30)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 730)),
    );
    if (picked != null) {
      setState(() {
        _customDate = picked;
        _deadlineDays = 0;
      });
    }
  }

  int get _resolvedDeadlineDays {
    if (_deadlineDays != 0) return _deadlineDays;
    if (_customDate != null) {
      return _customDate!.difference(DateTime.now()).inDays.clamp(1, 730);
    }
    return 30;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final answers = GoalCreateAnswers(
      title: _titleCtrl.text.trim(),
      description:
          _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      deadlineDays: _resolvedDeadlineDays,
      minutesPerDay: _minutesPerDay,
      currentLevel: _currentLevel,
      hasMaterials: _hasMaterials,
    );
    await ref.read(goalCreationProvider.notifier).analyse(answers);
    if (mounted) {
      final s = ref.read(goalCreationProvider);
      if (s is GoalCreationReview) {
        // ignore: unawaited_futures
        context.push('/goals/review');
      } else if (s is GoalCreationError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.goalAnalyzeError)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final state = ref.watch(goalCreationProvider);
    final isLoading = state is GoalCreationAnalyzing;

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
            const SizedBox(height: 20),

            // ── Deadline ─────────────────────────────────────────
            Text(
              l.goalCreateDeadlineLabel,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _chip(
                  l.goalCreateDeadlineWeek,
                  _deadlineDays == 7,
                  () => setState(() {
                    _deadlineDays = 7;
                    _customDate = null;
                  }),
                ),
                _chip(
                  l.goalCreateDeadlineMonth,
                  _deadlineDays == 30,
                  () => setState(() {
                    _deadlineDays = 30;
                    _customDate = null;
                  }),
                ),
                _chip(
                  l.goalCreateDeadlineThreeMonths,
                  _deadlineDays == 90,
                  () => setState(() {
                    _deadlineDays = 90;
                    _customDate = null;
                  }),
                ),
                _chip(
                  _customDate != null
                      ? '${_customDate!.day}/${_customDate!.month}/${_customDate!.year}'
                      : l.goalCreateDeadlineCustom,
                  _deadlineDays == 0 && _customDate != null,
                  _pickCustomDate,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Minutes per day ───────────────────────────────────
            Text(
              l.goalCreateTimePerDayLabel,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _minuteOptions.map((m) {
                return _chip(
                  l.goalCreateTimePerDay(m),
                  _minutesPerDay == m,
                  () => setState(() => _minutesPerDay = m),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // ── Current level ─────────────────────────────────────
            Text(
              l.goalCreateCurrentLevelLabel,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _chip(
                  l.goalCreateCurrentLevelBeginner,
                  _currentLevel == 'beginner',
                  () => setState(() => _currentLevel = 'beginner'),
                ),
                _chip(
                  l.goalCreateCurrentLevelIntermediate,
                  _currentLevel == 'intermediate',
                  () => setState(() => _currentLevel = 'intermediate'),
                ),
                _chip(
                  l.goalCreateCurrentLevelAdvanced,
                  _currentLevel == 'advanced',
                  () => setState(() => _currentLevel = 'advanced'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Materials ─────────────────────────────────────────
            Text(
              l.goalCreateMaterialsLabel,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _chip(
                  l.goalCreateMaterialsYes,
                  _hasMaterials,
                  () => setState(() => _hasMaterials = true),
                ),
                _chip(
                  l.goalCreateMaterialsNo,
                  !_hasMaterials,
                  () => setState(() => _hasMaterials = false),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // ── Submit ────────────────────────────────────────────
            HeroButton(
              label: l.goalCreateContinue,
              isLoading: isLoading,
              onPressed: isLoading ? null : _submit,
            ),

            if (isLoading) ...[
              const SizedBox(height: 16),
              Center(child: Text(l.goalAnalyzing)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}
