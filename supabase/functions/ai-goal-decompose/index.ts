// deno-lint-ignore-file no-explicit-any
import { serve } from 'https://deno.land/std@0.224.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.45.0'
import { corsHeaders } from '../_shared/cors.ts'

const MODEL = 'gemini-flash-latest'
// Gemini's OpenAI-compatible endpoint — drop-in for the old Groq URL.
const GEMINI_API_URL =
  'https://generativelanguage.googleapis.com/v1beta/openai/chat/completions'

const ALLOWED_CATEGORIES = [
  'strength', 'mind', 'endurance', 'health', 'social', 'finance', 'creativity',
] as const

const ALLOWED_DIFFICULTY  = ['easy', 'normal', 'hard', 'epic'] as const
const ALLOWED_DURATION    = ['short', 'medium', 'long'] as const
const ALLOWED_IMPORTANCE  = ['low', 'normal', 'high'] as const
const ALLOWED_FREQUENCY   = ['daily', 'weekly'] as const
const ALLOWED_TYPE        = ['task', 'habit', 'milestone'] as const

// Phase 19 — per-archetype guidance fed into the system prompt so the
// plan structure matches the kind of goal the user picked. Unknown /
// missing archetypes fall through to 'custom'.
const ARCHETYPE_INSTRUCTIONS: Record<string, string> = {
  skill_learning:    'Focus on progressive skill milestones. Include learning tasks and practice habits.',
  habit_building:    'Focus on daily habits with streaks. Minimize one-off tasks.',
  fitness_health:    'Include workout habits, recovery tasks, nutrition milestones.',
  project_creation:  'Include project phases as milestones. Tasks should be concrete deliverables.',
  money_purchase:    'Include savings habits, budget tracking tasks, milestone at target amount.',
  event_preparation: 'Work backwards from the event date. Include preparation milestones.',
  relationship_goal: 'Include communication habits and meaningful interaction tasks.',
  life_change:       'Include mindset habits, reflection tasks, lifestyle milestones.',
  custom:            'Use best judgment for goal structure.',
}

function bad(message: string, status = 400) {
  return new Response(
    JSON.stringify({ ok: false, error: message }),
    { status, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
  )
}

function ok(body: any) {
  return new Response(
    JSON.stringify(body),
    { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
  )
}

// Gemini sometimes wraps the JSON in a ```json fence or adds stray prose even
// with response_format set — pull out the bare object before parsing.
function extractJson(raw: string): string {
  let s = (raw ?? '').trim()
  const fence = s.match(/```(?:json)?\s*([\s\S]*?)```/i)
  if (fence) s = fence[1].trim()
  const first = s.indexOf('{')
  const last = s.lastIndexOf('}')
  if (first >= 0 && last > first) s = s.slice(first, last + 1)
  return s
}

function systemPrompt(locale: string, profile: any, archetype?: string): string {
  const isRu = locale === 'ru'
  const archetypeKey = archetype && archetype in ARCHETYPE_INSTRUCTIONS ? archetype : ''
  const archetypeHint = archetypeKey
    ? `\nGoal archetype: ${archetypeKey}. ${ARCHETYPE_INSTRUCTIONS[archetypeKey]} Tailor questions and plan structure accordingly.`
    : ''
  const hasProfile = profile && Object.keys(profile).length > 0
  const profileLines = hasProfile
    ? [
        `energy_level=${profile.current_energy_level}/5`,
        `time_per_day=${profile.current_time_commitment_minutes}min`,
        `support_style=${profile.current_support_style}`,
        `obstacles=${(profile.current_failure_reasons ?? []).join(', ')}`,
      ].join('; ')
    : 'unknown'

  return [
    isRu
      ? 'Ты — опытный планировщик целей и коуч в приложении Hero (RPG про реальную жизнь). Тебе дают цель пользователя — построй живой, продуманный план, который реально приведёт к результату.'
      : 'You are an experienced goal planner and coach in Hero (a real-life RPG app). Given a user goal, build a vivid, well-thought-out plan that will actually lead to the result.',
    `User profile: ${profileLines}${archetypeHint}`,
    isRu
      ? 'Принципы планирования:'
      : 'Planning principles:',
    isRu
      ? '• Шаги должны быть КОНКРЕТНЫЕ. Не "разминаться", а "10 приседаний и 10 отжиманий". Не "учить", а "30 новых слов из учебника".'
      : '• Steps must be CONCRETE. Not "warm up" but "10 squats and 10 push-ups". Not "study" but "30 new words from the textbook".',
    isRu
      ? '• Шаги должны быть РАЗНООБРАЗНЫЕ: первые недели — лёгкие quick wins, средние — основная работа, последние — кульминация.'
      : '• Steps must be DIVERSE: early weeks — easy quick wins, mid — main work, last — culmination.',
    isRu
      ? '• Описание каждого шага — 1-2 живых предложения объясняющих ЗАЧЕМ это нужно и КАК делать. Не сухо.'
      : '• Each step description — 1-2 vivid sentences explaining WHY it matters and HOW to do it. Not dry.',
    isRu
      ? '• Структура: 1-2 milestones (промежуточные победы), 2-3 habits (ежедневный/еженедельный ритуал), 3-5 tasks (одноразовые действия).'
      : '• Structure: 1-2 milestones (interim wins), 2-3 habits (daily/weekly ritual), 3-5 tasks (one-shot actions).',
    isRu
      ? '• Учитывай energy_level и time_per_day — план должен быть выполнимым именно ДЛЯ ЭТОГО пользователя.'
      : '• Respect energy_level and time_per_day — the plan must be achievable for THIS user.',
    isRu
      ? '• Если obstacles содержит "lose_motivation" — включи быстрые победы в первую неделю чтобы создать момент.'
      : '• If obstacles include "lose_motivation" — front-load quick wins to build momentum.',
    'Return STRICT JSON (no prose outside JSON):',
    '{ "summary": string, "main_category": string, "secondary_categories": string[], "estimated_weeks": int, "steps": Step[], "warnings": string[] }',
    isRu
      ? 'summary: 2-3 предложения о подходе. Не "займёмся" — реально описание стратегии.'
      : 'summary: 2-3 sentences about approach. Not generic — describe the strategy.',
    `main_category ∈ {${ALLOWED_CATEGORIES.join(',')}}. NEVER use intellect/discipline/balance/other.`,
    'Each Step: { "type": string, "title": string, "description": string, "main_category": string, "secondary_categories": string[], "difficulty": string, "duration": string, "importance": string, "xp_reward": int, "discipline_xp_reward": int, "enabled": true }',
    `type ∈ {task,habit,milestone}.`,
    `task: may include "due_days_from_now": int (1..365).`,
    `habit: must include "frequency" ∈ {daily,weekly}.`,
    `milestone: must include "target_days_from_now": int (1..730).`,
    `difficulty ∈ {${ALLOWED_DIFFICULTY.join(',')}}; duration ∈ {${ALLOWED_DURATION.join(',')}}; importance ∈ {${ALLOWED_IMPORTANCE.join(',')}}.`,
    `xp_reward: 5..150. discipline_xp_reward: 0..10.`,
    isRu
      ? 'estimated_weeks: 2..52. ОБЯЗАТЕЛЬНО 6-8 шагов (не 3 и не 10). enabled должно быть true.'
      : 'estimated_weeks: 2..52. REQUIRED 6-8 steps (not 3, not 10). enabled must be true.',
    `All titles and descriptions in locale=${locale}.`,
  ].join('\n')
}

serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders })
  if (req.method !== 'POST') return bad('method_not_allowed', 405)

  const auth = req.headers.get('Authorization')
  if (!auth) return bad('missing_auth', 401)

  const supabaseUrl = Deno.env.get('SUPABASE_URL')
  const anonKey    = Deno.env.get('SUPABASE_ANON_KEY')
  const apiKey     = Deno.env.get('GEMINI_API_KEY')
  if (!supabaseUrl || !anonKey || !apiKey) return bad('server_misconfigured', 500)

  const client = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: auth } },
    auth:   { persistSession: false, autoRefreshToken: false },
  })

  let payload: any
  try { payload = await req.json() } catch { return bad('invalid_json') }

  const title = (payload.goal_title ?? '').toString().trim().slice(0, 200)
  if (title.length < 2) return bad('title_too_short')

  // Phase 19 — archetype tailors the prompt; plan_mode='own' skips the AI
  // entirely and returns an empty plan for the user to fill in manually.
  const archetype = (payload.archetype ?? 'custom').toString()
  const planMode  = (payload.plan_mode ?? 'ai').toString()

  if (planMode === 'own') {
    return ok({
      ok: true,
      summary: '',
      main_category: 'mind',
      secondary_categories: [],
      estimated_weeks: null,
      steps: [],
      warnings: [],
    })
  }

  // Load user profile for personalisation.
  // Gated by ai_can_use_onboarding consent: opt-out default (default ON,
  // only stripped when user explicitly toggled it OFF). Same logic as
  // ai-chat — see that function for the rationale.
  const [profileRes, consentRes] = await Promise.all([
    client
      .from('users')
      .select('current_energy_level,current_time_commitment_minutes,current_support_style,current_failure_reasons')
      .single(),
    client
      .from('user_consents')
      .select('granted')
      .eq('consent_key', 'ai_can_use_onboarding')
      .maybeSingle(),
  ])
  const onboardingConsentGranted = consentRes.data?.granted !== false
  const profile = onboardingConsentGranted ? (profileRes.data ?? {}) : {}

  const locale = payload.locale === 'en' ? 'en' : 'ru'

  // ── Gemini API call (OpenAI-compatible) ────────────────────────────
  let aiJson: string
  try {
    const r = await fetch(GEMINI_API_URL, {
      method: 'POST',
      headers: {
        Authorization:  `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model:           MODEL,
        temperature:     0.4,
        max_tokens:      8192,
        response_format: { type: 'json_object' },
        messages: [
          { role: 'system', content: systemPrompt(locale, profile, archetype) },
          {
            role: 'user',
            content: JSON.stringify({
              goal_title:       title,
              goal_description: payload.goal_description ?? '',
              answers:          payload.answers ?? {},
              classification:   payload.classification ?? {},
            }),
          },
        ],
      }),
    })

    if (!r.ok) {
      const errText = await r.text()
      console.error('gemini error', r.status, errText)
      return bad(`ai_provider_${r.status}`, 502)
    }

    const data = await r.json()
    aiJson = data?.choices?.[0]?.message?.content ?? ''
  } catch (e) {
    console.error('ai call failed', e)
    return bad('ai_provider_unreachable', 502)
  }

  // ── Parse & validate ─────────────────────────────────────────────
  let parsed: any
  try {
    parsed = JSON.parse(extractJson(aiJson))
  } catch {
    console.error('decompose invalid json (first 800):', aiJson.slice(0, 800))
    return bad('ai_returned_invalid_json', 502)
  }

  // Top-level category
  if (!ALLOWED_CATEGORIES.includes(parsed.main_category)) {
    parsed.main_category = payload.classification?.main_category ?? 'mind'
    if (!ALLOWED_CATEGORIES.includes(parsed.main_category)) {
      parsed.main_category = 'mind'
    }
  }

  parsed.secondary_categories = ((parsed.secondary_categories ?? []) as string[])
    .filter(x => ALLOWED_CATEGORIES.includes(x as any) && x !== parsed.main_category)
    .slice(0, 2)

  parsed.estimated_weeks = Math.max(1, Math.min(52, parseInt(parsed.estimated_weeks ?? 4, 10) || 4))
  parsed.summary         = String(parsed.summary ?? '').slice(0, 500)
  parsed.warnings        = Array.isArray(parsed.warnings) ? parsed.warnings.slice(0, 5) : []

  // Steps
  const rawSteps: any[] = Array.isArray(parsed.steps) ? parsed.steps : []
  parsed.steps = rawSteps.map((s: any) => {
    if (!ALLOWED_TYPE.includes(s?.type)) return null

    if (!ALLOWED_CATEGORIES.includes(s?.main_category)) {
      s.main_category = parsed.main_category
    }
    s.secondary_categories = ((s.secondary_categories ?? []) as string[])
      .filter(x => ALLOWED_CATEGORIES.includes(x as any) && x !== s.main_category)
      .slice(0, 2)

    if (!ALLOWED_DIFFICULTY.includes(s.difficulty))  s.difficulty = s.type === 'habit' ? 'easy' : 'normal'
    if (!ALLOWED_DURATION.includes(s.duration))       s.duration   = s.type === 'habit' ? 'short' : 'medium'
    if (!ALLOWED_IMPORTANCE.includes(s.importance))   s.importance = 'normal'

    s.xp_reward            = Math.max(5,  Math.min(150, parseInt(s.xp_reward ?? 20, 10) || 20))
    s.discipline_xp_reward = Math.max(0,  Math.min(10,  parseInt(s.discipline_xp_reward ?? 0, 10) || 0))
    s.title                = String(s.title ?? '').slice(0, 200)
    s.description          = String(s.description ?? '').slice(0, 600)
    s.enabled              = s.enabled !== false

    if (s.type === 'habit') {
      if (!ALLOWED_FREQUENCY.includes(s.frequency)) s.frequency = 'daily'
    }
    if (s.type === 'task' && s.due_days_from_now != null) {
      s.due_days_from_now = Math.max(1, Math.min(365, parseInt(s.due_days_from_now, 10) || 1))
    }
    if (s.type === 'milestone') {
      s.target_days_from_now = Math.max(1, Math.min(730,
        parseInt(s.target_days_from_now ?? 14, 10) || 14))
    }
    return s
  }).filter(Boolean).slice(0, 8)

  if (parsed.steps.length === 0) return bad('plan_has_no_steps', 502)

  return ok({ ok: true, ...parsed })
})
