import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/l10n/l10n.dart';
import '../../../../../core/widgets/hero_button.dart';
import '../../application/goal_creation_notifier.dart';
import '../../domain/models/goal_archetype.dart';
import '../../domain/models/goal_create_answers.dart';
import '../../domain/models/goal_plan_mode.dart';

/// Step 2 of goal creation: pick an archetype, answer the few questions it
/// implies, choose a period / daily budget / plan mode, then build the plan.
class GoalArchetypeScreen extends ConsumerStatefulWidget {
  const GoalArchetypeScreen({super.key});

  @override
  ConsumerState<GoalArchetypeScreen> createState() =>
      _GoalArchetypeScreenState();
}

class _GoalArchetypeScreenState extends ConsumerState<GoalArchetypeScreen> {
  GoalArchetype _archetype = GoalArchetype.skillLearning;
  GoalPlanMode _planMode = GoalPlanMode.ai;

  // Period: 7 / 30 / 90, or 0 == custom (resolved via _customDate).
  int _periodDays = 30;
  DateTime? _customDate;

  int _minutesPerDay = 15;

  // Archetype-specific answers.
  String _currentLevel = 'beginner';
  bool _hasMaterials = true;
  final _amountCtrl = TextEditingController();
  String _currency = 'USD';
  DateTime? _eventDate;

  static const _currencies = ['USD', 'EUR', 'RUB', 'GBP'];

  // Title/description are captured ONCE from the notifier on entry. We must
  // not keep watching the provider: `analyse()` flips the state to
  // Analyzing/Review, and a rebuild that reacted to that by popping would
  // tear down both this screen and the review screen pushed on top of it.
  late final String? _title;
  late final String? _description;

  @override
  void initState() {
    super.initState();
    final st = ref.read(goalCreationProvider);
    if (st is GoalCreationPickingArchetype) {
      _title = st.title;
      _description = st.description;
    } else {
      _title = null;
      _description = null;
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  int get _resolvedPeriodDays {
    if (_periodDays != 0) return _periodDays;
    if (_customDate != null) {
      return _customDate!.difference(DateTime.now()).inDays.clamp(1, 730);
    }
    return 30;
  }

  bool get _showLevel =>
      _archetype == GoalArchetype.skillLearning ||
      _archetype == GoalArchetype.fitnessHealth;

  bool get _showMaterials =>
      _archetype == GoalArchetype.skillLearning ||
      _archetype == GoalArchetype.projectCreation;

  bool get _showMoney => _archetype == GoalArchetype.moneyPurchase;

  bool get _showEvent => _archetype == GoalArchetype.eventPreparation;

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
        _periodDays = 0;
      });
    }
  }

  Future<void> _pickEventDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 30)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 1095)),
    );
    if (picked != null) setState(() => _eventDate = picked);
  }

  Future<void> _submit(String title, String? description) async {
    final answers = GoalCreateAnswers(
      title: title,
      description: description,
      planPeriodDays: _resolvedPeriodDays,
      minutesPerDay: _minutesPerDay,
      archetype: _archetype,
      planMode: _planMode,
      currentLevel: _showLevel ? _currentLevel : null,
      hasMaterials: _showMaterials ? _hasMaterials : null,
      targetAmount:
          _showMoney ? double.tryParse(_amountCtrl.text.trim()) : null,
      targetCurrency: _showMoney ? _currency : null,
      eventDate: _showEvent ? _eventDate : null,
    );

    // Navigate first; the review screen renders the analyzing / empty-own
    // state itself based on the notifier.
    final notifier = ref.read(goalCreationProvider.notifier);
    // ignore: unawaited_futures
    context.push('/goals/review');
    await notifier.analyse(answers);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    // Reached without a title (e.g. deep-link straight to /goals/archetype)?
    // Bounce back to the start of the flow.
    if (_title == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted && context.canPop()) context.pop();
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final title = _title;
    final description = _description;

    return Scaffold(
      appBar: AppBar(title: Text(l.goalArchetypeScreenTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),

          // ── Archetype grid ──────────────────────────────────────
          Text(l.goalArchetypePrompt,
              style: Theme.of(context).textTheme.titleSmall,),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.95,
            children: GoalArchetype.values.map((a) {
              return _ArchetypeCard(
                icon: _iconFor(a),
                label: _labelFor(l, a),
                selected: _archetype == a,
                onTap: () => setState(() => _archetype = a),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // ── Archetype-specific questions ────────────────────────
          if (_showLevel) ...[
            Text(l.goalCreateCurrentLevelLabel,
                style: Theme.of(context).textTheme.titleSmall,),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: [
              _chip(
                  l.goalCreateCurrentLevelBeginner,
                  _currentLevel == 'beginner',
                  () => setState(() => _currentLevel = 'beginner'),),
              _chip(
                  l.goalCreateCurrentLevelIntermediate,
                  _currentLevel == 'intermediate',
                  () => setState(() => _currentLevel = 'intermediate'),),
              _chip(
                  l.goalCreateCurrentLevelAdvanced,
                  _currentLevel == 'advanced',
                  () => setState(() => _currentLevel = 'advanced'),),
            ],),
            const SizedBox(height: 20),
          ],
          if (_showMaterials) ...[
            Text(l.goalCreateMaterialsLabel,
                style: Theme.of(context).textTheme.titleSmall,),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: [
              _chip(l.goalCreateMaterialsYes, _hasMaterials,
                  () => setState(() => _hasMaterials = true),),
              _chip(l.goalCreateMaterialsNo, !_hasMaterials,
                  () => setState(() => _hasMaterials = false),),
            ],),
            const SizedBox(height: 20),
          ],
          if (_showMoney) ...[
            Text(l.goalMoneyTargetAmountLabel,
                style: Theme.of(context).textTheme.titleSmall,),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _amountCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  decoration: InputDecoration(
                    hintText: '0',
                    labelText: l.goalMoneyTargetAmountLabel,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              DropdownButton<String>(
                value: _currency,
                items: _currencies
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _currency = v ?? _currency),
              ),
            ],),
            const SizedBox(height: 20),
          ],
          if (_showEvent) ...[
            Text(l.goalEventDateLabel,
                style: Theme.of(context).textTheme.titleSmall,),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.event_outlined),
              label: Text(_eventDate != null
                  ? _fmtDate(_eventDate!)
                  : l.goalEventDatePick,),
              onPressed: _pickEventDate,
            ),
            const SizedBox(height: 20),
          ],

          // ── Period ──────────────────────────────────────────────
          Text(l.goalPeriodLabel,
              style: Theme.of(context).textTheme.titleSmall,),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: [
            _chip(
                l.goalPeriod1Week,
                _periodDays == 7,
                () => setState(() {
                      _periodDays = 7;
                      _customDate = null;
                    }),),
            _chip(
                l.goalPeriod1Month,
                _periodDays == 30,
                () => setState(() {
                      _periodDays = 30;
                      _customDate = null;
                    }),),
            _chip(
                l.goalPeriod3Months,
                _periodDays == 90,
                () => setState(() {
                      _periodDays = 90;
                      _customDate = null;
                    }),),
            _chip(
                _customDate != null
                    ? _fmtDate(_customDate!)
                    : l.goalPeriodCustom,
                _periodDays == 0 && _customDate != null,
                _pickCustomDate,),
          ],),
          const SizedBox(height: 24),

          // ── Minutes per day ─────────────────────────────────────
          Row(children: [
            Expanded(
              child: Text(l.goalCreateTimePerDayLabel,
                  style: Theme.of(context).textTheme.titleSmall,),
            ),
            Text(l.goalCreateTimePerDay(_minutesPerDay)),
          ],),
          Slider(
            value: _minutesPerDay.toDouble(),
            min: 5,
            max: 120,
            divisions: 23,
            label: '$_minutesPerDay',
            onChanged: (v) =>
                setState(() => _minutesPerDay = (v / 5).round() * 5),
          ),
          const SizedBox(height: 12),

          // ── Plan mode ───────────────────────────────────────────
          Text(l.goalPlanModeLabel,
              style: Theme.of(context).textTheme.titleSmall,),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: [
            _chip(l.goalPlanModeAi, _planMode == GoalPlanMode.ai,
                () => setState(() => _planMode = GoalPlanMode.ai),),
            _chip(l.goalPlanModeMixed, _planMode == GoalPlanMode.mixed,
                () => setState(() => _planMode = GoalPlanMode.mixed),),
            _chip(l.goalPlanModeOwn, _planMode == GoalPlanMode.own,
                () => setState(() => _planMode = GoalPlanMode.own),),
          ],),
          const SizedBox(height: 32),

          HeroButton(
            label: l.goalCreateMakePlan,
            onPressed: () => _submit(title, description),
          ),
          const SizedBox(height: 16),
        ],
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

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  static IconData _iconFor(GoalArchetype a) => switch (a) {
        GoalArchetype.skillLearning => Icons.school_outlined,
        GoalArchetype.habitBuilding => Icons.repeat,
        GoalArchetype.fitnessHealth => Icons.fitness_center,
        GoalArchetype.projectCreation => Icons.architecture_outlined,
        GoalArchetype.moneyPurchase => Icons.savings_outlined,
        GoalArchetype.eventPreparation => Icons.event_outlined,
        GoalArchetype.relationshipGoal => Icons.favorite_outline,
        GoalArchetype.lifeChange => Icons.auto_awesome_outlined,
        GoalArchetype.custom => Icons.tune,
      };

  static String _labelFor(AppLocalizations l, GoalArchetype a) => switch (a) {
        GoalArchetype.skillLearning => l.goalArchetypeSkillLearning,
        GoalArchetype.habitBuilding => l.goalArchetypeHabitBuilding,
        GoalArchetype.fitnessHealth => l.goalArchetypeFitnessHealth,
        GoalArchetype.projectCreation => l.goalArchetypeProjectCreation,
        GoalArchetype.moneyPurchase => l.goalArchetypeMoneyPurchase,
        GoalArchetype.eventPreparation => l.goalArchetypeEventPreparation,
        GoalArchetype.relationshipGoal => l.goalArchetypeRelationshipGoal,
        GoalArchetype.lifeChange => l.goalArchetypeLifeChange,
        GoalArchetype.custom => l.goalArchetypeCustom,
      };
}

class _ArchetypeCard extends StatelessWidget {
  const _ArchetypeCard({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? accent : theme.dividerColor,
            width: selected ? 2 : 1,
          ),
          color: selected ? accent.withValues(alpha: 0.10) : null,
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 26, color: selected ? accent : null),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
