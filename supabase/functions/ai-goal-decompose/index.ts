// deno-lint-ignore-file no-explicit-any
import { serve } from 'https://deno.land/std@0.224.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.45.0'
import { corsHeaders } from '../_shared/cors.ts'

const MODEL = 'llama-3.3-70b-versatile'

const ALLOWED_CATEGORIES = [
  'strength', 'mind', 'endurance', 'health', 'social', 'finance', 'creativity',
] as const

const ALLOWED_DIFFICULTY  = ['easy', 'normal', 'hard', 'epic'] as const
const ALLOWED_DURATION    = ['short', 'medium', 'long'] as const
const ALLOWED_IMPORTANCE  = ['low', 'normal', 'high'] as const
const ALLOWED_FREQUENCY   = ['daily', 'weekly'] as const
const ALLOWED_TYPE        = ['task', 'habit', 'milestone'] as const

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

function systemPrompt(locale: string, profile: any): string {
  const isRu = locale === 'ru'
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
      ? 'Ты — планировщик целей для Hero (RPG про реальную жизнь). Тебе дают цель — построй реалистичный план мягкого старта.'
      : 'You are a goal planner for Hero (a real-life RPG app). Given a goal, build a realistic gentle-start plan.',
    `User profile: ${profileLines}`,
    isRu
      ? 'Не перегружай план. Учитывай energy_level и time_per_day. Если obstacles содержит "lose_motivation" — включи quick wins в первую неделю.'
      : 'Do not overload. Respect energy_level and time_per_day. If obstacles include "lose_motivation" — add quick wins in week 1.',
    'Return STRICT JSON (no prose outside JSON):',
    '{ "summary": string, "main_category": string, "secondary_categories": string[], "estimated_weeks": int, "steps": Step[], "warnings": string[] }',
    `main_category ∈ {${ALLOWED_CATEGORIES.join(',')}}. NEVER use intellect/discipline/balance/other.`,
    'Each Step: { "type": string, "title": string, "description": string, "main_category": string, "secondary_categories": string[], "difficulty": string, "duration": string, "importance": string, "xp_reward": int, "discipline_xp_reward": int, "enabled": true }',
    `type ∈ {task,habit,milestone}.`,
    `task: may include "due_days_from_now": int (1..365).`,
    `habit: must include "frequency" ∈ {daily,weekly}.`,
    `milestone: must include "target_days_from_now": int (1..730).`,
    `difficulty ∈ {${ALLOWED_DIFFICULTY.join(',')}}; duration ∈ {${ALLOWED_DURATION.join(',')}}; importance ∈ {${ALLOWED_IMPORTANCE.join(',')}}.`,
    `xp_reward: 5..150. discipline_xp_reward: 0..10.`,
    `estimated_weeks: 1..52. Total steps: 3..7. enabled must be true.`,
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
  const apiKey     = Deno.env.get('GROQ_API_KEY')
  if (!supabaseUrl || !anonKey || !apiKey) return bad('server_misconfigured', 500)

  const client = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: auth } },
    auth:   { persistSession: false, autoRefreshToken: false },
  })

  let payload: any
  try { payload = await req.json() } catch { return bad('invalid_json') }

  const title = (payload.goal_title ?? '').toString().trim().slice(0, 200)
  if (title.length < 2) return bad('title_too_short')

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

  // ── Groq API call (OpenAI-compatible) ────────────────────────────
  let aiJson: string
  try {
    const r = await fetch('https://api.groq.com/openai/v1/chat/completions', {
      method: 'POST',
      headers: {
        Authorization:  `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model:           MODEL,
        temperature:     0.4,
        max_tokens:      1500,
        response_format: { type: 'json_object' },
        messages: [
          { role: 'system', content: systemPrompt(locale, profile) },
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
      console.error('groq error', r.status, errText)
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
  try { parsed = JSON.parse(aiJson) } catch { return bad('ai_returned_invalid_json', 502) }

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
