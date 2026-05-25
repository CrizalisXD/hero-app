// deno-lint-ignore-file no-explicit-any
import { serve } from 'https://deno.land/std@0.224.0/http/server.ts'
import { corsHeaders } from '../_shared/cors.ts'

// ── Allowlists (canonical Hero categories) ──────────────────────────
const ALLOWED_CATEGORIES = [
  'strength',
  'mind',
  'endurance',
  'health',
  'social',
  'finance',
  'creativity',
] as const

type Category = typeof ALLOWED_CATEGORIES[number]

const ALLOWED_DIFFICULTY = ['easy', 'normal', 'hard', 'epic'] as const
const ALLOWED_DURATION = ['short', 'medium', 'long'] as const
const ALLOWED_IMPORTANCE = ['low', 'normal', 'high'] as const

const MODEL = 'anthropic/claude-haiku-4-5-20251001'

interface RequestPayload {
  text?: string
  entity_type?: 'task' | 'habit' | 'goal'
  locale?: 'ru' | 'en'
}

interface ValidatedAiResponse {
  main_category: Category
  secondary_categories: Category[]
  difficulty: typeof ALLOWED_DIFFICULTY[number]
  duration: typeof ALLOWED_DURATION[number]
  importance: typeof ALLOWED_IMPORTANCE[number]
  discipline_xp_reward: number
  confidence: number
  reason: string
}

// ── Helpers ─────────────────────────────────────────────────────────
function bad(message: string, status = 400): Response {
  return new Response(
    JSON.stringify({ ok: false, error: message }),
    {
      status,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    },
  )
}

function ok(body: any): Response {
  return new Response(
    JSON.stringify(body),
    {
      status: 200,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    },
  )
}

function systemPrompt(locale: string): string {
  const ru = locale === 'ru'
  return [
    ru
      ? 'Ты классификатор задач для приложения Hero — RPG про реальную жизнь.'
      : 'You classify tasks for Hero — an RPG about real life.',
    ru
      ? 'Тебе дают короткий текст задачи, привычки или цели.'
      : 'You receive a short text for a task, habit, or goal.',
    ru
      ? 'Верни только JSON. Никакого текста вне JSON.'
      : 'Return JSON only. No text outside JSON.',
    'Required JSON fields: main_category, secondary_categories, difficulty, duration, importance, discipline_xp_reward, confidence, reason.',
    'main_category MUST be exactly one of: strength, mind, endurance, health, social, finance, creativity.',
    'There are NO categories named discipline, intellect, balance, other, productivity, learning, sport.',
    'secondary_categories: 0..2 values from the same allowed set, not duplicating main_category.',
    'difficulty must be one of: easy, normal, hard, epic.',
    'duration must be one of: short, medium, long.',
    'importance must be one of: low, normal, high.',
    'discipline_xp_reward must be an integer from 0 to 10.',
    'confidence must be a number from 0 to 1.',
    'reason must be short, max 120 chars.',
  ].join('\n')
}

function userPrompt(text: string, entityType: string, locale: string): string {
  return JSON.stringify({ text, entity_type: entityType, locale })
}

function parseJsonObject(raw: string): any | null {
  try {
    return JSON.parse(raw)
  } catch {
    // Fallback: model wrapped JSON in extra prose.
    const start = raw.indexOf('{')
    const end = raw.lastIndexOf('}')
    if (start < 0 || end <= start) return null
    try {
      return JSON.parse(raw.slice(start, end + 1))
    } catch {
      return null
    }
  }
}

function isAllowedCategory(value: unknown): value is Category {
  return typeof value === 'string' &&
    (ALLOWED_CATEGORIES as readonly string[]).includes(value)
}

function safeEnum<T extends readonly string[]>(
  value: unknown,
  allowed: T,
  fallback: T[number],
): T[number] {
  return typeof value === 'string' &&
      (allowed as readonly string[]).includes(value)
    ? (value as T[number])
    : fallback
}

function validateAiResponse(parsed: any): ValidatedAiResponse | null {
  if (!parsed || typeof parsed !== 'object') return null

  // CRITICAL: reject anything outside the 7 canonical categories.
  // `discipline` / `intellect` / `balance` / `other` etc. → null → 502 to caller.
  if (!isAllowedCategory(parsed.main_category)) return null

  const main = parsed.main_category

  const secondaries = Array.isArray(parsed.secondary_categories)
    ? parsed.secondary_categories
        .filter((x: unknown) => isAllowedCategory(x) && x !== main)
        .slice(0, 2)
    : []

  const disciplineXpRaw = Number.parseInt(
    String(parsed.discipline_xp_reward ?? '0'),
    10,
  )
  const disciplineXp = Number.isFinite(disciplineXpRaw)
    ? Math.max(0, Math.min(10, disciplineXpRaw))
    : 0

  const confidenceRaw = Number(parsed.confidence)
  const confidence = Number.isFinite(confidenceRaw)
    ? Math.max(0, Math.min(1, confidenceRaw))
    : 0.5

  return {
    main_category: main,
    secondary_categories: secondaries,
    difficulty: safeEnum(parsed.difficulty, ALLOWED_DIFFICULTY, 'normal'),
    duration: safeEnum(parsed.duration, ALLOWED_DURATION, 'medium'),
    importance: safeEnum(parsed.importance, ALLOWED_IMPORTANCE, 'normal'),
    discipline_xp_reward: disciplineXp,
    confidence,
    reason: String(parsed.reason ?? '').slice(0, 120),
  }
}

// ── Entry point ─────────────────────────────────────────────────────
serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  if (req.method !== 'POST') {
    return bad('method_not_allowed', 405)
  }

  const auth = req.headers.get('Authorization')
  if (!auth) {
    return bad('missing_auth', 401)
  }

  const apiKey = Deno.env.get('OPENROUTER_API_KEY')
  if (!apiKey) {
    return bad('server_misconfigured', 500)
  }

  let payload: RequestPayload
  try {
    payload = await req.json()
  } catch {
    return bad('invalid_json', 400)
  }

  const text = String(payload.text ?? '').trim().slice(0, 500)
  if (text.length < 2) {
    return bad('text_too_short', 400)
  }

  const entityType =
    payload.entity_type === 'habit' || payload.entity_type === 'goal'
      ? payload.entity_type
      : 'task'

  const locale = payload.locale === 'en' ? 'en' : 'ru'

  let aiContent = ''

  try {
    const response = await fetch(
      'https://openrouter.ai/api/v1/chat/completions',
      {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${apiKey}`,
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://hero.app',
          'X-Title': 'Hero Category Classifier',
        },
        body: JSON.stringify({
          model: MODEL,
          temperature: 0,
          max_tokens: 250,
          response_format: { type: 'json_object' },
          messages: [
            { role: 'system', content: systemPrompt(locale) },
            { role: 'user', content: userPrompt(text, entityType, locale) },
          ],
        }),
      },
    )

    if (!response.ok) {
      const providerText = await response.text()
      console.error('OpenRouter error', response.status, providerText)
      return bad(`ai_provider_${response.status}`, 502)
    }

    const data = await response.json()
    aiContent = data?.choices?.[0]?.message?.content ?? ''
  } catch (e) {
    console.error('AI provider unreachable', e)
    return bad('ai_provider_unreachable', 502)
  }

  const parsed = parseJsonObject(aiContent)
  if (!parsed) {
    return bad('ai_returned_invalid_json', 502)
  }

  const validated = validateAiResponse(parsed)
  if (!validated) {
    return bad('ai_returned_invalid_payload', 502)
  }

  return ok(validated)
})
