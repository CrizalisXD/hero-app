// deno-lint-ignore-file no-explicit-any
import { serve } from 'https://deno.land/std@0.224.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.45.0'
import { corsHeaders } from '../_shared/cors.ts'

const MODEL = 'llama-3.3-70b-versatile'
const GROQ_API_URL = 'https://api.groq.com/openai/v1/chat/completions'
const DAILY_LIMIT = 30
const HISTORY_LIMIT = 10
const MEMORY_LIMIT = 15
const ALLOWED_SUGGESTION_TYPES = ['task', 'habit']
const ALLOWED_CATEGORIES = ['strength', 'mind', 'endurance', 'health', 'social', 'finance', 'creativity']

interface RequestPayload {
  conversation_id?: string
  message: string
  locale?: 'ru' | 'en'
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

function buildSystemPrompt(
  locale: string,
  profile: any,
  goals: any[],
  tasks: any[],
  habits: any[],
  memory: any[],
  notes: any[],
): string {
  const isRu = locale === 'ru'
  const style = profile?.current_support_style ?? 'direct'
  const styleHint = ({
    direct: isRu ? 'Отвечай кратко, по делу, без воды.' : 'Be direct and concise, no fluff.',
    gentle: isRu ? 'Отвечай тепло и поддерживающе.' : 'Be warm and supportive.',
    strict: isRu ? 'Отвечай как строгий, требовательный коуч.' : 'Be a strict, demanding coach.',
    analytical: isRu ? 'Отвечай через цифры и аналитику.' : 'Rely on numbers and analysis.',
  } as any)[style] ?? (isRu ? 'Отвечай ясно.' : 'Be clear.')

  const lines: string[] = []
  lines.push(isRu
    ? 'Ты — AI-наставник в Hero, RPG про реальную жизнь пользователя.'
    : "You are the AI mentor in Hero, an RPG about the user's real life.")
  lines.push(`Answer ONLY in the user's language: ${locale}. Never switch language unless asked.`)
  lines.push(styleHint)

  // If the user revoked `ai_can_use_onboarding`, the caller passes
  // profile={} — skip the PROFILE block entirely so the model doesn't
  // see any onboarding-derived fields.
  if (profile && Object.keys(profile).length > 0) {
    lines.push('---PROFILE---')
    lines.push(JSON.stringify({
      energy: profile?.current_energy_level,
      time_per_day_min: profile?.current_time_commitment_minutes,
      main_obstacle: profile?.current_main_obstacle,
      failure_reasons: profile?.current_failure_reasons ?? [],
      support_style: style,
      life_areas: profile?.current_life_change_areas ?? [],
    }))
  }

  if (goals.length > 0) {
    lines.push('---ACTIVE GOALS---')
    for (const g of goals.slice(0, 3)) {
      lines.push(`- ${g.title} (cat=${g.main_category}, target=${g.target_date ?? 'none'})`)
    }
  }
  if (tasks.length > 0) {
    lines.push('---TODAY TASKS---')
    for (const t of tasks.slice(0, 5)) {
      lines.push(`- ${t.title} (cat=${t.main_category}, done=${t.is_done})`)
    }
  }
  if (habits.length > 0) {
    lines.push('---ACTIVE HABITS---')
    for (const h of habits.slice(0, 5)) {
      lines.push(`- ${h.title} (cat=${h.main_category}, streak=${h.current_streak})`)
    }
  }
  if (memory.length > 0) {
    lines.push('---MEMORY---')
    for (const m of memory) {
      lines.push(`- [${m.memory_type}] ${m.content}`)
    }
  }
  // Notes are only injected when the user has explicitly granted
  // ai_can_use_notes consent AND the note's visibility is 'ai_allowed'.
  // The fetch path guarantees both — but we re-check visibility here
  // as defense in depth.
  const aiNotes = notes.filter(n => n?.visibility === 'ai_allowed')
  if (aiNotes.length > 0) {
    lines.push('---USER NOTES (shared with you)---')
    aiNotes.slice(0, 10).forEach((n, i) => {
      const title = n.title ? `[${String(n.title).slice(0, 60)}] ` : ''
      lines.push(`note_${i + 1}: ${title}${String(n.content ?? '').slice(0, 400)}`)
    })
    lines.push(
      isRu
        ? 'ВАЖНО про заметки: это ОТДЕЛЬНЫЕ записи пользователя. Каждый раз когда юзер спрашивает «что мне нужно сделать / купить / напомни про X» — заново просмотри ВСЕ заметки выше и упомяни ВСЕ релевантные, не только одну. Если про X в заметках ничего нет — честно скажи «в заметках про это ничего». Никогда не цитируй ОДНУ ТУ ЖЕ заметку как ответ на несвязанные вопросы.'
        : 'IMPORTANT about notes: these are SEPARATE user records. Each time the user asks "what should I do / buy / remind me about X" — re-scan ALL notes above and list EVERY relevant one, not just one. If a topic isn\'t in any note, say so honestly. Never reuse the same note as the answer to unrelated questions.',
    )
  }

  lines.push('---OUTPUT FORMAT---')
  lines.push('Return STRICT JSON: { "reply": string, "suggestion": null | { "type": "task"|"habit", "title": string, "main_category": string } }')
  lines.push('"reply": your natural-language response to the user.')
  lines.push('"suggestion": null in 90% of replies. Only include when user explicitly asks for a task/habit to add.')
  lines.push(`"main_category" must be one of: ${ALLOWED_CATEGORIES.join(', ')}`)
  lines.push('NEVER create tasks/habits directly — only suggest. The user confirms.')
  lines.push('Output JSON only. No text outside the JSON object.')

  return lines.join('\n')
}

function validateSuggestion(s: any): any | null {
  if (!s || typeof s !== 'object') return null
  if (!ALLOWED_SUGGESTION_TYPES.includes(s.type)) return null
  if (typeof s.title !== 'string' || s.title.trim().length < 2) return null
  if (!ALLOWED_CATEGORIES.includes(s.main_category)) {
    s.main_category = 'mind'
  }
  return {
    type: s.type,
    title: String(s.title).slice(0, 200),
    main_category: s.main_category,
  }
}

serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders })
  if (req.method !== 'POST') return bad('method_not_allowed', 405)

  const auth = req.headers.get('Authorization')
  if (!auth) return bad('missing_auth', 401)

  const supabaseUrl = Deno.env.get('SUPABASE_URL')
  const anonKey = Deno.env.get('SUPABASE_ANON_KEY')
  const groqKey = Deno.env.get('GROQ_API_KEY')
  if (!supabaseUrl || !anonKey || !groqKey) return bad('server_misconfigured', 500)

  const client = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: auth } },
    auth: { persistSession: false, autoRefreshToken: false },
  })

  // Get user id for explicit inserts
  const { data: { user }, error: userErr } = await client.auth.getUser()
  if (userErr || !user) return bad('unauthorized', 401)
  const uid = user.id

  let payload: RequestPayload
  try {
    payload = await req.json()
  } catch {
    return bad('invalid_json')
  }

  const message = String(payload.message ?? '').slice(0, 2000).trim()
  if (message.length < 1) return bad('empty_message')
  const locale = payload.locale === 'en' ? 'en' : 'ru'

  // 1) Daily limit check — explicitly scoped to the caller. Never rely on
  //    RLS alone for the counting query: with a permissive policy the cap
  //    would silently become global across all users.
  const today = new Date().toISOString().slice(0, 10)
  const { count: requestsToday } = await client
    .from('ai_request_logs')
    .select('*', { count: 'exact', head: true })
    .eq('user_id', uid)
    .eq('feature', 'chat')
    .eq('request_date', today)
  if ((requestsToday ?? 0) >= DAILY_LIMIT) {
    return bad('daily_limit_reached', 429)
  }

  // 2) Ensure conversation. A client-supplied conversation_id must belong
  //    to the caller — otherwise messages could be appended into / read
  //    from another user's conversation wherever RLS is not airtight.
  let conversationId = payload.conversation_id
  if (conversationId) {
    const { data: conv } = await client
      .from('ai_conversations')
      .select('id')
      .eq('id', conversationId)
      .eq('user_id', uid)
      .maybeSingle()
    if (!conv) return bad('conversation_not_found', 404)
  } else {
    const { data: conv, error: convErr } = await client
      .from('ai_conversations')
      .insert({ user_id: uid, context_type: 'general' })
      .select('id')
      .single()
    if (convErr || !conv) {
      console.error('create conv err', convErr)
      return bad('conv_create_failed', 500)
    }
    conversationId = conv.id
  }

  // 3) Save user message FIRST (if AI fails, user message is still persisted)
  const { data: userMsg, error: userMsgErr } = await client
    .from('ai_messages')
    .insert({
      user_id: uid,
      conversation_id: conversationId,
      role: 'user',
      content: message,
    })
    .select('id, created_at')
    .single()
  if (userMsgErr || !userMsg) {
    console.error('insert user msg err', userMsgErr)
    return bad('save_user_msg_failed', 500)
  }

  // 4) Gather context in parallel
  const [profileRes, goalsRes, tasksRes, habitsRes, memoryRes, historyRes, consentsRes] =
    await Promise.all([
      client.from('users').select(
        'current_energy_level, current_time_commitment_minutes, current_main_obstacle, current_failure_reasons, current_support_style, current_life_change_areas',
      ).eq('id', uid).single(),
      client.from('goals').select('id, title, main_category, target_date').eq('status', 'active').limit(3),
      client.from('tasks').select('id, title, main_category, is_done').eq('is_done', false).limit(5),
      client.from('habits').select('id, title, main_category, current_streak').eq('is_archived', false).limit(5),
      client.from('ai_memory').select('memory_type, content').order('last_used_at', { ascending: false, nullsFirst: false }).limit(MEMORY_LIMIT),
      // Take the LAST HISTORY_LIMIT messages (newest), then reverse to
      // chronological order client-side. Previously this used ascending=true
      // which returned the OLDEST 10 — meaning growing conversations
      // locked the AI to whatever it said in the first turns and the
      // user's latest questions were silently dropped from context.
      client.from('ai_messages').select('role, content, created_at').eq('conversation_id', conversationId).order('created_at', { ascending: false }).limit(HISTORY_LIMIT),
      // Fetch both consents in one call — ai_can_use_notes (opt-in default
      // off) and ai_can_use_onboarding (opt-out default on).
      client.from('user_consents').select('consent_key, granted').in('consent_key', ['ai_can_use_notes', 'ai_can_use_onboarding']),
    ])

  // Build consent lookup with TZ-correct defaults:
  //   notes      → false if absent  (strict opt-in, privacy by default)
  //   onboarding → true  if absent  (implicit consent: user filled the form)
  const consentMap: Record<string, boolean> = {}
  for (const row of (consentsRes.data ?? []) as any[]) {
    consentMap[row.consent_key] = row.granted === true
  }
  const notesConsentGranted = consentMap['ai_can_use_notes'] === true
  const onboardingConsentGranted = consentMap['ai_can_use_onboarding'] !== false

  // Strip the entire profile context when the user explicitly opted out.
  // Empty object → buildSystemPrompt falls back to neutral style and skips
  // the ---PROFILE--- block.
  const profile = onboardingConsentGranted ? (profileRes.data ?? {}) : {}
  const goals = goalsRes.data ?? []
  const tasks = tasksRes.data ?? []
  const habits = habitsRes.data ?? []
  const memory = memoryRes.data ?? []
  // historyRes came back DESC (newest first). Reverse to chronological
  // ASC order before feeding into the LLM messages array.
  const history = ((historyRes.data ?? []) as any[]).slice().reverse()

  // Notes are gated by explicit consent. If the user hasn't granted
  // ai_can_use_notes, we don't fetch them at all — not even ai_allowed
  // ones. This guarantees that flipping the toggle off in Settings
  // takes effect on the very next chat turn.
  let notes: any[] = []
  if (notesConsentGranted) {
    const notesRes = await client
      .from('notes')
      .select('title, content, visibility')
      .eq('visibility', 'ai_allowed')
      .eq('is_deleted', false)
      .order('updated_at', { ascending: false })
      .limit(10)
    notes = notesRes.data ?? []
    if (notesRes.error) {
      console.error('notes fetch err', notesRes.error)
    }
  }
  console.log(`chat: notes_consent=${notesConsentGranted} onboarding_consent=${onboardingConsentGranted} notes=${notes.length}`)

  // 5) Build messages array for Groq
  const messages = [
    {
      role: 'system',
      content: buildSystemPrompt(locale, profile, goals, tasks, habits, memory, notes),
    },
    ...history.map((m: any) => ({
      role: m.role === 'system' ? 'system' : m.role,
      content: m.content,
    })),
  ]

  // 6) Call Groq
  let aiJson = ''
  let tokensIn = 0
  let tokensOut = 0
  try {
    const r = await fetch(GROQ_API_URL, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${groqKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: MODEL,
        temperature: 0.5,
        max_tokens: 700,
        response_format: { type: 'json_object' },
        messages,
      }),
    })
    if (!r.ok) {
      const errText = await r.text()
      console.error('groq error', r.status, errText)
      return bad(`ai_provider_${r.status}`, 502)
    }
    const data = await r.json()
    aiJson = data?.choices?.[0]?.message?.content ?? ''
    tokensIn = data?.usage?.prompt_tokens ?? 0
    tokensOut = data?.usage?.completion_tokens ?? 0
  } catch (e) {
    console.error('ai call failed', e)
    return bad('ai_provider_unreachable', 502)
  }

  let parsed: any
  try {
    parsed = JSON.parse(aiJson)
  } catch {
    console.error('AI returned non-JSON:', aiJson)
    return bad('ai_returned_invalid_json', 502)
  }

  const reply = String(parsed.reply ?? '').trim()
  if (reply.length < 1) return bad('ai_returned_empty_reply', 502)
  const suggestion = validateSuggestion(parsed.suggestion)

  // 7) Save assistant message
  const { data: asstMsg, error: asstMsgErr } = await client
    .from('ai_messages')
    .insert({
      user_id: uid,
      conversation_id: conversationId,
      role: 'assistant',
      content: reply,
      metadata: suggestion ? { suggestion } : {},
    })
    .select('id, created_at')
    .single()
  if (asstMsgErr || !asstMsg) {
    console.error('insert assistant msg err', asstMsgErr)
    return bad('save_assistant_msg_failed', 500)
  }

  // 8) Log request
  await client.from('ai_request_logs').insert({
    user_id: uid,
    feature: 'chat',
    tokens_input: tokensIn,
    tokens_output: tokensOut,
    request_date: today,
  })

  return ok({
    ok: true,
    conversation_id: conversationId,
    user_message: { id: userMsg.id, created_at: userMsg.created_at },
    assistant_message: { id: asstMsg.id, content: reply, created_at: asstMsg.created_at },
    suggestion,
  })
})
