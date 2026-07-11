import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

const STARTER_HABITS: Record<string, {
  title: string;
  main_category: string;
  difficulty: string;
  duration: string;
  importance: string;
  xp_reward: number;
  discipline_xp_reward: number;
}> = {
  drink_water: {
    title: 'Пить воду утром',
    main_category: 'health',
    difficulty: 'easy',
    duration: 'short',
    importance: 'normal',
    xp_reward: 15,
    discipline_xp_reward: 4,
  },
  read_10_pages: {
    title: 'Читать 10 страниц',
    main_category: 'mind',
    difficulty: 'easy',
    duration: 'short',
    importance: 'normal',
    xp_reward: 15,
    discipline_xp_reward: 4,
  },
  walk_10_min: {
    title: 'Прогулка 10 минут',
    main_category: 'endurance',
    difficulty: 'easy',
    duration: 'short',
    importance: 'normal',
    xp_reward: 15,
    discipline_xp_reward: 4,
  },
  // Онбординг v2: динамический каталог по выбранным направлениям.
  morning_stretch: {
    title: 'Разминка 5 минут',
    main_category: 'strength',
    difficulty: 'easy',
    duration: 'short',
    importance: 'normal',
    xp_reward: 15,
    discipline_xp_reward: 4,
  },
  track_expenses: {
    title: 'Записать расходы',
    main_category: 'finance',
    difficulty: 'easy',
    duration: 'short',
    importance: 'normal',
    xp_reward: 15,
    discipline_xp_reward: 4,
  },
  call_close_person: {
    title: 'Позвонить близкому',
    main_category: 'social',
    difficulty: 'easy',
    duration: 'short',
    importance: 'normal',
    xp_reward: 15,
    discipline_xp_reward: 4,
  },
  sketch_10_min: {
    title: 'Скетч 10 минут',
    main_category: 'creativity',
    difficulty: 'easy',
    duration: 'short',
    importance: 'normal',
    xp_reward: 15,
    discipline_xp_reward: 4,
  },
};

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: CORS_HEADERS });
  }

  try {
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: 'Missing authorization header' }),
        { status: 401, headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' } },
      );
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_ANON_KEY')!,
      { global: { headers: { Authorization: authHeader } } },
    );

    const { data: { user }, error: userErr } = await supabase.auth.getUser();
    if (userErr || !user) {
      return new Response(
        JSON.stringify({ error: 'Unauthorized' }),
        { status: 401, headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' } },
      );
    }

    const body = await req.json();

    // The payload is client-controlled — validate/clamp every field before
    // it reaches the DB (and, later, the AI system prompt).
    const asStringArray = (v: unknown, max = 20): string[] =>
      Array.isArray(v)
        ? v
            .filter((x): x is string => typeof x === 'string')
            .map((x) => x.slice(0, 100))
            .slice(0, max)
        : [];
    const asIntInRange = (
      v: unknown,
      min: number,
      max: number,
      dflt: number,
    ): number => {
      const n = typeof v === 'number' ? Math.round(v) : NaN;
      return Number.isFinite(n) ? Math.min(max, Math.max(min, n)) : dflt;
    };
    // Полный набор, который умеет слать клиент (экран стиля коучинга) +
    // legacy-значения из ai-chat.
    const ALLOWED_SUPPORT_STYLES = [
      'direct', 'gentle', 'humorous', 'neutral', 'strict', 'analytical',
    ];

    const life_change_areas = asStringArray(body.life_change_areas);
    const main_obstacle =
      typeof body.main_obstacle === 'string'
        ? body.main_obstacle.slice(0, 500)
        : '';
    const energy_level = asIntInRange(body.energy_level, 1, 5, 3);
    const time_commitment_minutes = asIntInRange(
      body.time_commitment_minutes,
      5,
      240,
      15,
    );
    const failure_reasons = asStringArray(body.failure_reasons);
    const support_style =
      typeof body.support_style === 'string' &&
      ALLOWED_SUPPORT_STYLES.includes(body.support_style)
        ? body.support_style
        : '';
    const starter_habits = asStringArray(body.starter_habits, 10);
    // Онбординг v2: имя героя и предпочитаемое время (дефолт напоминаний).
    const display_name =
      typeof body.display_name === 'string'
        ? body.display_name.trim().slice(0, 30)
        : '';
    const ALLOWED_TIMES = ['morning', 'afternoon', 'evening'];
    const preferred_time =
      typeof body.preferred_time === 'string' &&
      ALLOWED_TIMES.includes(body.preferred_time)
        ? body.preferred_time
        : null;

    // 1. Update current_* columns on public.users (not profiles)
    const { error: usersErr } = await supabase
      .from('users')
      .update({
        current_life_change_areas: life_change_areas,
        current_main_obstacle: main_obstacle,
        current_energy_level: energy_level,
        current_time_commitment_minutes: time_commitment_minutes,
        current_failure_reasons: failure_reasons,
        current_support_style: support_style,
        profile_updated_at: new Date().toISOString(),
      })
      .eq('id', user.id);

    if (usersErr) {
      console.error('users update error:', usersErr);
      return new Response(
        JSON.stringify({ ok: false, error: 'Failed to update user' }),
        { status: 500, headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' } },
      );
    }

    // 1b. Онбординг v2 — best-effort, отдельными апдейтами: имя пишется
    // всегда (колонка есть), preferred_focus_time может отсутствовать до
    // применения миграции 20260705000001 — это не должно валить онбординг.
    if (display_name) {
      const { error: nameErr } = await supabase
        .from('users')
        .update({ display_name })
        .eq('id', user.id);
      if (nameErr) console.error('display_name update error:', nameErr);
    }
    if (preferred_time) {
      const { error: timeErr } = await supabase
        .from('users')
        .update({ preferred_focus_time: preferred_time })
        .eq('id', user.id);
      if (timeErr) console.error('preferred_focus_time update error:', timeErr);
    }

    // 2. Create profile snapshot
    const { error: snapErr } = await supabase
      .from('user_profile_snapshots')
      .insert({
        user_id: user.id,
        life_change_areas,
        main_obstacle,
        energy_level,
        time_commitment_minutes,
        failure_reasons,
        support_style,
        source: 'onboarding',
      });

    if (snapErr) {
      console.error('snapshot insert error:', snapErr);
    }

    // 3. Create starter habits
    let habitsCreated = 0;
    for (const habitKey of starter_habits) {
      const template = STARTER_HABITS[habitKey];
      if (!template) continue;

      const { error: habitErr } = await supabase
        .from('habits')
        .insert({
          user_id: user.id,
          title: template.title,
          main_category: template.main_category,
          difficulty: template.difficulty,
          duration: template.duration,
          importance: template.importance,
          xp_reward: template.xp_reward,
          discipline_xp_reward: template.discipline_xp_reward,
          type: 'good',
          recurrence: 'daily',
        });

      if (!habitErr) {
        habitsCreated++;
      } else {
        console.error(`habit insert error for ${habitKey}:`, habitErr);
      }
    }

    // 4. Mark onboarding done — only after all steps succeed
    const { error: doneErr } = await supabase
      .from('profiles')
      .update({ onboarding_done: true })
      .eq('id', user.id);

    if (doneErr) {
      console.error('onboarding_done update error:', doneErr);
      return new Response(
        JSON.stringify({ ok: false, error: 'Failed to finalize onboarding' }),
        { status: 500, headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' } },
      );
    }

    return new Response(
      JSON.stringify({
        ok: true,
        user_id: user.id,
        onboarding_done: true,
        created: {
          starter_habits: habitsCreated,
          profile_snapshot: !snapErr,
        },
      }),
      { status: 200, headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' } },
    );
  } catch (err) {
    console.error('unexpected error:', err);
    return new Response(
      JSON.stringify({ ok: false, error: 'Internal server error' }),
      { status: 500, headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' } },
    );
  }
});
