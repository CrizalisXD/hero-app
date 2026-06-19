import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hero/app/theme/app_colors.dart';
import 'package:hero/core/widgets/animated_fill_bar.dart';
import 'package:hero/core/widgets/hero_button.dart';
import 'package:hero/core/widgets/hero_card.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  testWidgets('AnimatedFillBar usages', (t) async {
    await t.pumpWidget(_wrap(
      Column(mainAxisSize: MainAxisSize.min, children: const [
        AnimatedFillBar(
            progress: 0.5, height: 10, gradient: AppColors.xpGradient),
        Row(children: [
          Expanded(
              child: AnimatedFillBar(
                  progress: 0.3, height: 6, color: AppColors.warning)),
        ]),
      ]),
    ));
    await t.pump(const Duration(milliseconds: 800));
    expect(t.takeException(), isNull);
  });

  testWidgets('HeroButton fullWidth:true in Column', (t) async {
    await t.pumpWidget(_wrap(
      Column(mainAxisSize: MainAxisSize.min, children: [
        for (final v in HeroButtonVariant.values)
          HeroButton(label: 'Action', variant: v, onPressed: () {}),
      ]),
    ));
    expect(t.takeException(), isNull);
  });

  testWidgets('HeroButton fullWidth:true in UNBOUNDED Row (stress)', (t) async {
    await t.pumpWidget(_wrap(
      Row(children: [
        HeroButton(label: 'Action', onPressed: () {}),
      ]),
    ));
    expect(t.takeException(), isNull);
  });

  testWidgets('HeroButton ghost sm fullWidth:false in Row after Spacer',
      (t) async {
    await t.pumpWidget(_wrap(
      Row(children: [
        const Expanded(child: Text('Title')),
        const Spacer(),
        HeroButton(
          label: 'More',
          variant: HeroButtonVariant.ghost,
          size: HeroButtonSize.sm,
          fullWidth: false,
          onPressed: () {},
        ),
      ]),
    ));
    expect(t.takeException(), isNull);
  });

  testWidgets('HeroButton as ListTile.trailing', (t) async {
    await t.pumpWidget(_wrap(
      ListTile(
        title: const Text('habit'),
        trailing: HeroButton(
          label: 'Check-in',
          variant: HeroButtonVariant.ghost,
          size: HeroButtonSize.sm,
          fullWidth: false,
          onPressed: () {},
        ),
      ),
    ));
    expect(t.takeException(), isNull);
  });

  testWidgets('HeroCard default + hero with onTap', (t) async {
    await t.pumpWidget(_wrap(
      Column(mainAxisSize: MainAxisSize.min, children: [
        const HeroCard(child: Text('flat')),
        HeroCard.hero(onTap: () {}, child: const Text('hero')),
        HeroCard(
          child: Row(children: [
            const Expanded(child: Text('row in card')),
            HeroButton(
              label: 'Add',
              variant: HeroButtonVariant.ghost,
              size: HeroButtonSize.sm,
              fullWidth: false,
              onPressed: () {},
            ),
          ]),
        ),
      ]),
    ));
    await t.pump(const Duration(milliseconds: 300));
    expect(t.takeException(), isNull);
  });
}
