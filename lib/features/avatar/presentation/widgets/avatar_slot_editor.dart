import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/l10n/l10n.dart';
import '../../application/avatar_draft_notifier.dart';
import '../../data/supabase_avatar_repository.dart';
import '../../domain/models/avatar.dart';
import '../../domain/models/avatar_asset.dart';
import '../../domain/models/avatar_slot.dart';

/// Единый редактор слотов: вкладки доступных слотов + сетка предметов.
///
/// Используется и в онбординге (быстрый первичный проход), и в полном
/// Character Editor — отличается только обвязкой вокруг. Всё пишется в
/// черновик, поэтому изменения видны до сохранения и отменяются уходом.
///
/// Вкладка показывается только если под слот есть хоть один предмет,
/// подходящий полу. Пустых вкладок не бывает — это ответ на то, что часть
/// каталога заведена заранее и пока выключена.
class AvatarSlotEditor extends ConsumerStatefulWidget {
  const AvatarSlotEditor({super.key, this.slots});

  /// Ограничить набор слотов (онбординг показывает только базовые).
  /// null — все доступные для текущего пола.
  final List<AvatarSlot>? slots;

  @override
  ConsumerState<AvatarSlotEditor> createState() => _AvatarSlotEditorState();
}

class _AvatarSlotEditorState extends ConsumerState<AvatarSlotEditor> {
  AvatarSlot? _active;

  String _slotLabel(BuildContext context, AvatarSlot slot) {
    final l = context.l10n;
    return switch (slot) {
      AvatarSlot.hair => l.avatarSlotHair,
      AvatarSlot.skin => l.avatarSlotSkin,
      AvatarSlot.outfit => l.avatarSlotOutfit,
      AvatarSlot.top => l.avatarSlotTop,
      AvatarSlot.bottom => l.avatarSlotBottom,
      AvatarSlot.shoes => l.avatarSlotShoes,
      AvatarSlot.body || AvatarSlot.face => '',
    };
  }

  IconData _slotIcon(AvatarSlot slot) => switch (slot) {
        AvatarSlot.hair => Icons.content_cut_rounded,
        AvatarSlot.skin => Icons.palette_rounded,
        AvatarSlot.outfit => Icons.checkroom_rounded,
        AvatarSlot.top => Icons.dry_cleaning_rounded,
        AvatarSlot.bottom => Icons.airline_seat_legroom_normal_rounded,
        AvatarSlot.shoes => Icons.ice_skating_rounded,
        AvatarSlot.body || AvatarSlot.face => Icons.person_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(avatarDraftProvider);
    final catalogAsync = ref.watch(avatarCatalogProvider);

    if (draft == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return catalogAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      // Каталог не загрузился — редактировать нечем, но экран не должен
      // становиться тупиком: пользователь просто идёт дальше с базовым видом.
      error: (_, __) => _EmptyState(),
      data: (catalog) {
        var slots = catalog.availableSlots(draft.gender);
        if (widget.slots != null) {
          slots = slots.where(widget.slots!.contains).toList();
        }
        // Верх и низ прячем, когда надет цельный образ — иначе пользователь
        // выберет вещь, которая никогда не появится на модели.
        if (draft.hasOutfit) {
          slots = slots
              .where((s) => s != AvatarSlot.top && s != AvatarSlot.bottom)
              .toList();
        }
        if (slots.isEmpty) return _EmptyState();

        final active = slots.contains(_active) ? _active! : slots.first;
        final assets = catalog.forSlot(active, draft.gender);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: slots.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => _SlotTab(
                  label: _slotLabel(context, slots[i]),
                  icon: _slotIcon(slots[i]),
                  isActive: slots[i] == active,
                  onTap: () => setState(() => _active = slots[i]),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _AssetGrid(
              assets: assets,
              selectedId: draft.slotValue(active),
              onPick: (id) =>
                  ref.read(avatarDraftProvider.notifier).setSlot(active, id),
            ),
          ],
        );
      },
    );
  }
}

class _SlotTab extends StatelessWidget {
  const _SlotTab({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.accent.withValues(alpha: 0.18)
              : AppColors.bgElevated.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? AppColors.accent
                : Colors.white.withValues(alpha: 0.06),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? AppColors.accent : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssetGrid extends StatelessWidget {
  const _AssetGrid({
    required this.assets,
    required this.selectedId,
    required this.onPick,
  });

  final List<AvatarAsset> assets;
  final String selectedId;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.85,
      children: [
        for (final asset in assets)
          _AssetCard(
            asset: asset,
            isSelected: asset.id == selectedId,
            // Запертые показываем, но не применяем (ТЗ §5).
            onTap: asset.isLocked ? null : () => onPick(asset.id),
          ),
      ],
    );
  }
}

class _AssetCard extends StatelessWidget {
  const _AssetCard({
    required this.asset,
    required this.isSelected,
    required this.onTap,
  });

  final AvatarAsset asset;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: asset.isLocked ? 0.45 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.bgElevated.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? AppColors.accent
                  : Colors.white.withValues(alpha: 0.06),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: _AssetPreview(asset: asset)),
              if (asset.isLocked)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.lock_rounded,
                        size: 11,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l.avatarLocked,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                )
              else
                const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

/// Картинка предмета в карточке.
///
/// Приоритет — превью из бандла: они рендерятся из тех же FBX, которые грузит
/// Unity (`Hero ▸ Avatar ▸ Render Previews`), лежат в `assets/avatars/` под
/// именем `unity_asset_id` и потому не могут разъехаться с моделью. Сеть —
/// запасной путь для предметов, у которых превью придёт из каталога позже.
class _AssetPreview extends StatelessWidget {
  const _AssetPreview({required this.asset});

  final AvatarAsset asset;

  @override
  Widget build(BuildContext context) {
    const fallback = Icon(
      Icons.checkroom_rounded,
      size: 30,
      color: AppColors.textMuted,
    );

    Widget network() => asset.previewUrl == null
        ? fallback
        : Image.network(
            asset.previewUrl!,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => fallback,
          );

    if (asset.unityAssetId == null) return network();

    return Image.asset(
      'assets/avatars/${asset.unityAssetId}.png',
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => network(),
    );
  }
}

/// Слотов с контентом нет вовсе — честно говорим об этом вместо пустой сетки.
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgElevated.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome, color: AppColors.accent, size: 28),
          const SizedBox(height: 12),
          Text(
            l.avatarNoItemsYet,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l.avatarNoItemsYetBody,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Утилита для экранов: черновик заводится от сохранённой конфигурации.
void ensureAvatarDraft(WidgetRef ref, Avatar? saved) {
  if (saved == null) return;
  if (ref.read(avatarDraftProvider) != null) return;
  ref.read(avatarDraftProvider.notifier).begin(saved);
}
