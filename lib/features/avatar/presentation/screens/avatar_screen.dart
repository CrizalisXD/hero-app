import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/widgets/hero_button.dart';
import '../../../home/application/home_notifier.dart';
import '../../application/avatar_notifier.dart';
import '../../domain/models/avatar.dart';
import '../widgets/avatar_preview.dart';
import '../widgets/color_picker_grid.dart';

class AvatarScreen extends ConsumerStatefulWidget {
  const AvatarScreen({super.key});

  @override
  ConsumerState<AvatarScreen> createState() => _AvatarScreenState();
}

class _AvatarScreenState extends ConsumerState<AvatarScreen> {
  String? _dirtyColor;
  bool _saving = false;

  Future<void> _save() async {
    final color = _dirtyColor;
    if (color == null || _saving) return;
    setState(() => _saving = true);

    final ok = await ref
        .read(avatarNotifierProvider.notifier)
        .updatePrimaryColor(color);

    if (!mounted) return;
    final l = context.l10n;
    if (ok) {
      // Обновляем Home чтобы HeroAvatarPanel показал новый цвет
      ref.invalidate(homeNotifierProvider);
      setState(() => _dirtyColor = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.avatarSaveSuccess)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.avatarSaveError)),
      );
    }
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final avatarAsync = ref.watch(avatarNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.avatarScreenTitle)),
      body: avatarAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => Center(child: Text('$e')),
        data: (Avatar avatar) {
          final currentColor = _dirtyColor ?? avatar.primaryColor;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            children: [
              Center(child: AvatarPreview(hex: currentColor)),
              const SizedBox(height: 32),
              Text(
                l.avatarColorPickerTitle,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              ColorPickerGrid(
                selectedHex: currentColor,
                onSelect: (String hex) => setState(() => _dirtyColor = hex),
              ),
              const SizedBox(height: 24),
              HeroButton(
                label: l.avatarSave,
                isLoading: _saving,
                onPressed: (_dirtyColor == null || _saving) ? null : _save,
              ),
            ],
          );
        },
      ),
    );
  }
}
