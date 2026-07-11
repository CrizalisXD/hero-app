-- Модули Social / Challenges / Rewards / Notes / Siri давно живые и
-- используются, но feature_flags остались false с начального сида.
-- Теперь флаги реально гейтят и роуты (router redirect), и орбиту Home,
-- поэтому выключенный флаг прячет раздел целиком — включаем канонично.
-- Health и Calendar интеграции тоже включены по решению продукта.
-- ВНИМАНИЕ (аудит P1-010): двусторонняя синхронизация календаря может
-- удалять Hero-задачи при исчезновении события. Флаг открывает экран,
-- но сам тумблер two-way внутри держать выключенным до режимов P2.9.
-- Health дополнительно требует Dart-флаг HERO_HEALTH_ENABLED (резолвер:
-- фича включена только когда И БД, И Dart разрешают).
UPDATE public.feature_flags
SET enabled = true
WHERE key IN (
  'social_enabled',
  'challenges_enabled',
  'rewards_enabled',
  'notes_enabled',
  'siri_shortcuts_enabled',
  'health_integration_enabled',
  'calendar_integration_enabled'
);
