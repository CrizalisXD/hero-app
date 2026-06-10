-- ════════════════════════════════════════════════════════════════════
-- Hero — Phase 14 QA scripts (TZ §14.10 A-G)
--
-- USAGE
--   1. Run section [0] once to find your test user_id and store it.
--   2. Each scenario has a BEFORE check, an APP ACTION cue (what to tap
--      in the running app), and an AFTER check. Run BEFORE → tap → AFTER.
--   3. Scenarios D and E include a SIMULATE block: SQL that fakes time
--      progression so you don't have to actually wait 7 days.
--   4. Run these in Supabase Studio → SQL Editor with the dropdown set
--      to "service_role". With service_role, RLS is bypassed and we can
--      inspect any row regardless of policy.
--
-- IDs used in this file
--   seven_days_activity:  11111111-1111-1111-1111-100000000001
--   monthly_run / steps:  11111111-1111-1111-1111-100000000002
-- ════════════════════════════════════════════════════════════════════


-- ─── [0] FIND YOUR TEST USER ────────────────────────────────────────
-- Sign into the app first (email or guest). Then run this to pick up
-- your user_id. Copy the returned value and paste it in place of
-- '<USER_ID>' in every scenario below.

SELECT u.id                         AS user_id,
       p.email,
       p.is_guest,
       cs.level,
       cs.xp_total,
       ms.current_streak
  FROM public.users u
  JOIN public.profiles       p  ON p.id      = u.id
  JOIN public.character_stats cs ON cs.user_id = u.id
  JOIN public.meta_stats     ms ON ms.user_id = u.id
 ORDER BY p.updated_at DESC
 LIMIT 5;


-- ════════════════════════════════════════════════════════════════════
-- A) JOIN A CHALLENGE → unlocks challenge_first achievement
-- ════════════════════════════════════════════════════════════════════
-- BEFORE: no participant row, no challenge_first unlock
SELECT 'A:before:participants' AS check_,
       COUNT(*)                  AS count
  FROM public.challenge_participants
 WHERE user_id = '<USER_ID>'
UNION ALL
SELECT 'A:before:challenge_first_unlocked',
       (SELECT COUNT(*)
          FROM public.user_achievements
         WHERE user_id = '<USER_ID>' AND achievement_id = 'challenge_first');

-- ▶ APP ACTION
--   1. Open /challenges
--   2. Tab "All" → tap «Seven days of action»
--   3. Tap «Join»
--   4. Expect AchievementUnlockedSheet («Challenge Accepted»)

-- AFTER: exactly one participant row + challenge_first unlocked
SELECT 'A:after:participants' AS check_, * FROM (
  SELECT challenge_id, status, progress_value, streak_current, joined_at
    FROM public.challenge_participants
   WHERE user_id = '<USER_ID>'
) t
ORDER BY joined_at DESC;

SELECT 'A:after:challenge_first' AS check_, achievement_id, unlocked_at
  FROM public.user_achievements
 WHERE user_id = '<USER_ID>' AND achievement_id = 'challenge_first';


-- ════════════════════════════════════════════════════════════════════
-- B) TASK COMPLETION INCREMENTS PROGRESS
-- ════════════════════════════════════════════════════════════════════
-- Precondition: user is joined to seven_days_activity (run scenario A first).

-- BEFORE
SELECT 'B:before' AS check_,
       progress_value, streak_current, last_activity_date
  FROM public.challenge_participants
 WHERE user_id      = '<USER_ID>'
   AND challenge_id = '11111111-1111-1111-1111-100000000001';

-- ▶ APP ACTION
--   1. Create a task (any title)
--   2. Mark it complete (tap the circle)

-- AFTER: progress_value = 1, streak_current = 1, last_activity_date = today,
--        one new event row.
SELECT 'B:after:participant' AS check_,
       progress_value, streak_current, last_activity_date, status
  FROM public.challenge_participants
 WHERE user_id      = '<USER_ID>'
   AND challenge_id = '11111111-1111-1111-1111-100000000001';

SELECT 'B:after:events' AS check_, event_type, value_delta, created_at
  FROM public.challenge_events
 WHERE user_id      = '<USER_ID>'
   AND challenge_id = '11111111-1111-1111-1111-100000000001'
 ORDER BY created_at DESC
 LIMIT 5;


-- ════════════════════════════════════════════════════════════════════
-- C) REPEAT COMPLETION SAME DAY → NO INCREMENT
-- ════════════════════════════════════════════════════════════════════
-- activity_day metric is idempotent within the calendar day.

-- BEFORE: take note of progress_value from scenario B.

-- ▶ APP ACTION
--   1. Create another task
--   2. Complete it

-- AFTER: progress_value, streak_current, last_activity_date UNCHANGED.
--        challenge_events should have one MORE row, but participant row
--        progress is the same (this is the idempotency proof).
SELECT 'C:after:participant_should_be_unchanged' AS check_,
       progress_value, streak_current, last_activity_date
  FROM public.challenge_participants
 WHERE user_id      = '<USER_ID>'
   AND challenge_id = '11111111-1111-1111-1111-100000000001';
-- Expected: same numbers as scenario B AFTER. If progress_value changed,
-- the trigger is incorrectly double-counting.


-- ════════════════════════════════════════════════════════════════════
-- D) 7 DAYS IN A ROW → COMPLETION + reward + challenge_complete unlock
-- ════════════════════════════════════════════════════════════════════
-- SIMULATE: jump the participant to "6 days done, yesterday's date"
-- so one more task completion today brings them to 7.

-- ⚠️  Only run on test users.
UPDATE public.challenge_participants
   SET progress_value     = 6,
       streak_current     = 6,
       last_activity_date = CURRENT_DATE - INTERVAL '1 day',
       status             = 'joined',
       completed_at       = NULL
 WHERE user_id      = '<USER_ID>'
   AND challenge_id = '11111111-1111-1111-1111-100000000001';

-- BEFORE: capture XP & unlock state.
SELECT 'D:before:xp_total'  AS check_, xp_total::TEXT
  FROM public.character_stats WHERE user_id = '<USER_ID>'
UNION ALL
SELECT 'D:before:challenge_complete',
       (SELECT COUNT(*)::TEXT FROM public.user_achievements
         WHERE user_id = '<USER_ID>' AND achievement_id = 'challenge_complete');

-- ▶ APP ACTION
--   1. Create a task
--   2. Complete it (this is the 7th activity_day)
--   3. Expect AchievementUnlockedSheet («Challenge Victor»)

-- AFTER: status=completed, completed_at filled, xp_total += 200,
--        challenge_complete unlocked.
SELECT 'D:after:participant' AS check_,
       progress_value, status, completed_at
  FROM public.challenge_participants
 WHERE user_id      = '<USER_ID>'
   AND challenge_id = '11111111-1111-1111-1111-100000000001';

SELECT 'D:after:xp_total' AS check_, xp_total
  FROM public.character_stats WHERE user_id = '<USER_ID>';

SELECT 'D:after:achievements' AS check_, achievement_id, unlocked_at
  FROM public.user_achievements
 WHERE user_id = '<USER_ID>'
   AND achievement_id IN ('challenge_first', 'challenge_complete')
 ORDER BY unlocked_at;


-- ════════════════════════════════════════════════════════════════════
-- E) LEAVE + RE-JOIN → progress resets to 0
-- ════════════════════════════════════════════════════════════════════
-- Use a non-completed challenge (the monthly_run one is easiest).

-- Precondition: join monthly_run first via the app (or run scenario A's
-- query but for ...000002).

-- ▶ APP ACTION (Leave)
--   1. Open /challenges → Mine tab → tap «Monthly run»
--   2. Tap «Leave» → confirm

-- AFTER Leave: status=left, progress retained (audit).
SELECT 'E:after_leave' AS check_,
       status, progress_value
  FROM public.challenge_participants
 WHERE user_id      = '<USER_ID>'
   AND challenge_id = '11111111-1111-1111-1111-100000000002';

-- ▶ APP ACTION (Re-join)
--   1. Same screen → tap «Join» again

-- AFTER Re-join: status=joined, progress_value=0, joined_at updated.
SELECT 'E:after_rejoin' AS check_,
       status, progress_value, streak_current,
       last_activity_date, joined_at, completed_at
  FROM public.challenge_participants
 WHERE user_id      = '<USER_ID>'
   AND challenge_id = '11111111-1111-1111-1111-100000000002';
-- Expected: status='joined', progress_value=0, streak_current=0,
-- last_activity_date=NULL, completed_at=NULL, joined_at=just now.


-- ════════════════════════════════════════════════════════════════════
-- F) MONTHLY_RUN PROGRESS DOESN'T MOVE FROM TASKS (Phase 15 prerequisite)
-- ════════════════════════════════════════════════════════════════════
-- Precondition: scenario E left the user re-joined to monthly_run at 0.

-- ▶ APP ACTION
--   1. Create a task and complete it.

-- AFTER: monthly_run progress STAYS at 0 (only metric_type='distance'
--        events from Phase 15 health_daily_summaries trigger increments).
SELECT 'F:after' AS check_, progress_value, status
  FROM public.challenge_participants
 WHERE user_id      = '<USER_ID>'
   AND challenge_id = '11111111-1111-1111-1111-100000000002';
-- Expected: progress_value = 0. If non-zero, the metric_type dispatch
-- in process_challenge_progress is incorrectly counting task events
-- toward distance challenges.


-- ════════════════════════════════════════════════════════════════════
-- G) PRIVACY — foreign user's challenges are NOT in their public profile
-- ════════════════════════════════════════════════════════════════════
-- This is verified by what get_public_profile DOESN'T return.

-- Pick a second user (or USE user_b's id if you have two test accounts).
-- Below runs from user_a's perspective trying to read user_b's profile.

-- The RPC returns a fixed shape: username, display_name, public_level,
-- streak, achievements_count. challenges are intentionally absent.
SELECT public.get_public_profile('<USER_B_ID>'::uuid) AS profile_payload;
-- Expected JSON keys: user_id, username, display_name, avatar_preview_url,
-- public_title, public_level, streak, achievements_count.
-- ❌ Must NOT contain: challenges, tasks, goals, ai_messages, health data.


-- ────────────────────────────────────────────────────────────────────
-- TEARDOWN (optional) — clean test state after QA
-- ────────────────────────────────────────────────────────────────────
-- ⚠️  Only for test users. Remove participant rows + dependent events.
-- DELETE FROM public.challenge_participants WHERE user_id = '<USER_ID>';
-- DELETE FROM public.user_achievements
--  WHERE user_id = '<USER_ID>'
--    AND achievement_id IN ('challenge_first','challenge_complete');
